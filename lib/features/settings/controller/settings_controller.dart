import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../models/network_device.dart';
import '../state/settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(SettingsState.initial());

  void updateTargetUrl(String url) {
    final sanitized = url.trim();
    final fallback = sanitized.isEmpty ? state.targetUrl : sanitized;
    state = state.copyWith(targetUrl: fallback);
  }

  void selectDevice(NetworkDevice? device) {
    state = state.copyWith(selectedDevice: device);
  }

  Future<void> scanForDevices() async {
    state = state.copyWith(isScanning: true, error: null, clearError: true);

    try {
      final granted = await _ensurePermissions();
      if (!granted) {
        throw const SettingsException(
          'Permissions are required to scan for network devices. Please grant location, Bluetooth, and Wi-Fi permissions.',
        );
      }

      // Use try-catch for each discovery method to prevent one from crashing the other
      List<NetworkDevice> wifiDevices = [];
      List<NetworkDevice> bluetoothDevices = [];

      try {
        wifiDevices = await _discoverWifiNetworks();
      } catch (e) {
        // Log error but continue with Bluetooth scanning
        wifiDevices = [];
      }

      try {
        bluetoothDevices = await _discoverBluetoothDevices();
      } catch (e) {
        // Log error but continue
        bluetoothDevices = [];
      }

      final devices = [...wifiDevices, ...bluetoothDevices];

      if (devices.isEmpty) {
        throw const SettingsException(
          'No devices found. Make sure Bluetooth is enabled and Wi-Fi is on. Try moving closer to devices.',
        );
      }

      state = state.copyWith(
        devices: devices,
        isScanning: false,
        selectedDevice: devices.isEmpty ? null : devices.first,
      );
    } on SettingsException catch (error) {
      state = state.copyWith(
        isScanning: false,
        error: error.message,
        clearError: false,
      );
    } catch (error) {
      // Catch any null check errors or other exceptions
      state = state.copyWith(
        isScanning: false,
        error: 'Scan failed: ${error.toString()}',
        clearError: false,
      );
    }
  }

  Future<bool> _ensurePermissions() async {
    final requiredPermissions = <Permission>[
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];

    final optionalPermissions = <Permission>[
      // nearbyWifiDevices is optional (Android 13+ only)
      if (Platform.isAndroid) Permission.nearbyWifiDevices,
    ];

    // Request required permissions
    final requiredResults = await Future.wait(
      requiredPermissions.map((p) => p.request()),
    );

    // Check if all required permissions are granted
    final allRequiredGranted =
        requiredResults.every((status) => status.isGranted);

    // Try to request optional permissions, but don't fail if they're not granted
    for (final permission in optionalPermissions) {
      try {
        final status = await permission.status;
        if (!status.isGranted) {
          await permission.request();
        }
      } catch (e) {
        // Ignore errors for optional permissions
      }
    }

    return allRequiredGranted;
  }

  Future<List<NetworkDevice>> _discoverWifiNetworks() async {
    if (!Platform.isAndroid) {
      return [];
    }

    try {
      final isEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isEnabled) {
        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
        // Wait a bit for Wi-Fi to enable
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      final networks = await WiFiForIoTPlugin.loadWifiList();
      if (networks.isEmpty) {
        return [];
      }

      // Deduplicate by SSID
      final seenSsids = <String>{};
      return networks
          .where((network) {
            final ssid = network.ssid ?? '';
            if (ssid.isEmpty || seenSsids.contains(ssid)) return false;
            seenSsids.add(ssid);
            return true;
          })
          .map(
            (network) => NetworkDevice(
              id: network.bssid ??
                  network.ssid ??
                  DateTime.now().toIso8601String(),
              name: network.ssid ?? 'Wi-Fi device',
              address: network.bssid,
              type: NetworkDeviceType.wifi,
            ),
          )
          .toList();
    } catch (e) {
      // Wi-Fi scanning might fail due to permissions or platform limitations
      // Return empty list instead of throwing to allow Bluetooth scanning to continue
      return [];
    }
  }

  Future<List<NetworkDevice>> _discoverBluetoothDevices() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return [];
    }

    final isOn = await FlutterBluePlus.isOn;
    if (!isOn) {
      throw const SettingsException('Bluetooth is turned off.');
    }

    final scanDuration = const Duration(seconds: 4);
    List<ScanResult> latest = [];

    final subscription = FlutterBluePlus.scanResults.listen((event) {
      latest = event;
    });

    await FlutterBluePlus.startScan(timeout: scanDuration);
    // Wait for the full scan duration to collect results
    await Future<void>.delayed(scanDuration);
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    // Deduplicate devices by ID
    final seenIds = <String>{};
    return latest.where((result) {
      try {
        final id = result.device.remoteId.str;
        if (id.isEmpty || seenIds.contains(id)) return false;
        seenIds.add(id);
        return true;
      } catch (e) {
        // Skip devices with invalid IDs - catch any null check errors
        return false;
      }
    }).map(
      (result) {
        try {
          // Safely access device properties with try-catch to handle any null issues
          final id = result.device.remoteId.str;
          final platformName = result.device.platformName;

          return NetworkDevice(
            id: id.isNotEmpty ? id : DateTime.now().toIso8601String(),
            name: platformName.isNotEmpty ? platformName : 'Bluetooth device',
            address: id.isNotEmpty ? id : null,
            type: NetworkDeviceType.bluetooth,
          );
        } catch (e) {
          // Return a default device if there's any error accessing device properties
          // This catches null check operator errors and other exceptions
          return NetworkDevice(
            id: DateTime.now().toIso8601String(),
            name: 'Bluetooth device',
            address: null,
            type: NetworkDeviceType.bluetooth,
          );
        }
      },
    ).toList();
  }
}

class SettingsException implements Exception {
  const SettingsException(this.message);
  final String message;

  @override
  String toString() => message;
}
