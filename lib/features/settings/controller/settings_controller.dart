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

      final futures = await Future.wait([
        _discoverWifiNetworks(),
        _discoverBluetoothDevices(),
      ]);

      final devices = futures.expand((list) => list).toList();

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
      state = state.copyWith(
        isScanning: false,
        error: 'Scan failed: ${error.toString()}',
        clearError: false,
      );
    }
  }

  Future<bool> _ensurePermissions() async {
    final permissions = <Permission>[
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      if (Platform.isAndroid) Permission.nearbyWifiDevices,
    ];

    final results = await Future.wait(
      permissions.map((p) => p.request()),
    );
    return results.every((status) => status.isGranted);
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
    return latest
        .where((result) {
          final id = result.device.remoteId.str;
          if (seenIds.contains(id)) return false;
          seenIds.add(id);
          return true;
        })
        .map(
          (result) => NetworkDevice(
            id: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty
                ? result.device.platformName
                : 'Bluetooth device',
            address: result.device.remoteId.str,
            type: NetworkDeviceType.bluetooth,
          ),
        )
        .toList();
  }
}

class SettingsException implements Exception {
  const SettingsException(this.message);
  final String message;

  @override
  String toString() => message;
}
