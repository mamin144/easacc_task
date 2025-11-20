import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsState {
  const PermissionsState({
    required this.hasAllPermissions,
    required this.isChecking,
    this.error,
  });

  final bool hasAllPermissions;
  final bool isChecking;
  final String? error;

  PermissionsState copyWith({
    bool? hasAllPermissions,
    bool? isChecking,
    String? error,
    bool clearError = false,
  }) {
    return PermissionsState(
      hasAllPermissions: hasAllPermissions ?? this.hasAllPermissions,
      isChecking: isChecking ?? this.isChecking,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final permissionsControllerProvider =
    StateNotifierProvider<PermissionsController, PermissionsState>((ref) {
  return PermissionsController();
});

class PermissionsController extends StateNotifier<PermissionsState> {
  PermissionsController()
      : super(const PermissionsState(
          hasAllPermissions: false,
          isChecking: true,
        )) {
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    state = state.copyWith(isChecking: true, clearError: true);
    final permissions = _getRequiredPermissions();
    final statuses = await Future.wait(
      permissions.map((p) => p.status),
    );

    final hasAll = statuses.every((status) => status.isGranted);

    if (!hasAll) {
      // Find missing permissions
      final missingPermissions = <String>[];
      for (int i = 0; i < permissions.length; i++) {
        if (!statuses[i].isGranted) {
          missingPermissions.add(_getPermissionName(permissions[i]));
        }
      }

      final missingList = missingPermissions.join(', ');
      state = state.copyWith(
        hasAllPermissions: false,
        isChecking: false,
        error:
            'Missing permissions: $missingList. Please grant all permissions to continue.',
      );
    } else {
      state = state.copyWith(
        hasAllPermissions: true,
        isChecking: false,
      );
    }
  }

  List<Permission> _getRequiredPermissions() {
    return [
      // Location is required for Wi-Fi scanning on older Android versions
      Permission.locationWhenInUse,
      // Bluetooth runtime permissions (Android 12+ granular permissions)
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      // Android 13+ permission for nearby Wi-Fi devices
      if (Platform.isAndroid) Permission.nearbyWifiDevices,
    ];
  }

  String _getPermissionName(Permission permission) {
    if (permission == Permission.locationWhenInUse) {
      return 'Location';
    } else if (permission == Permission.bluetoothScan) {
      return 'Bluetooth Scan';
    } else if (permission == Permission.bluetoothConnect) {
      return 'Bluetooth Connect';
    } else if (permission == Permission.bluetoothAdvertise) {
      return 'Bluetooth Advertise';
    } else if (permission == Permission.bluetooth) {
      return 'Bluetooth';
    } else if (permission == Permission.nearbyWifiDevices) {
      return 'Nearby Wi-Fi Devices';
    }
    return permission.toString();
  }

  /// Requests each required permission sequentially and returns a map of
  /// permission name -> [PermissionStatus]. This is useful when you want to
  /// present system dialogs one-by-one and report granular results to the UI.
  Future<Map<String, PermissionStatus>> requestAllPermissions() async {
    state = state.copyWith(isChecking: true, clearError: true);
    final permissions = _getRequiredPermissions();
    final Map<String, PermissionStatus> results = {};

    try {
      for (final p in permissions) {
        final status = await p.request();
        results[_getPermissionName(p)] = status;
      }

      final allGranted = results.values.every((s) => s.isGranted);
      state = state.copyWith(hasAllPermissions: allGranted, isChecking: false);
      return results;
    } catch (e) {
      state = state.copyWith(
        hasAllPermissions: false,
        isChecking: false,
        error: 'Failed to request permissions: ${e.toString()}',
      );
      return results;
    }
  }

  Future<void> requestPermissions() async {
    state = state.copyWith(isChecking: true, clearError: true);

    try {
      final permissions = _getRequiredPermissions();
      final results = await Future.wait(
        permissions.map((p) => p.request()),
      );

      final allGranted = results.every((status) => status.isGranted);

      if (!allGranted) {
        // Check current statuses to identify missing permissions
        final statuses = await Future.wait(
          permissions.map((p) => p.status),
        );

        // Find missing permissions
        final missingPermissions = <String>[];
        for (int i = 0; i < permissions.length; i++) {
          if (!statuses[i].isGranted) {
            missingPermissions.add(_getPermissionName(permissions[i]));
          }
        }

        final permanentlyDenied =
            statuses.any((status) => status.isPermanentlyDenied);

        final missingList = missingPermissions.join(', ');

        if (permanentlyDenied) {
          state = state.copyWith(
            hasAllPermissions: false,
            isChecking: false,
            error:
                'Missing permissions: $missingList. Some are permanently denied. Please enable them in app settings.',
          );
        } else {
          state = state.copyWith(
            hasAllPermissions: false,
            isChecking: false,
            error:
                'Missing permissions: $missingList. All permissions are required for the app to function. Please grant all permissions.',
          );
        }
      } else {
        state = state.copyWith(
          hasAllPermissions: true,
          isChecking: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        hasAllPermissions: false,
        isChecking: false,
        error: 'Failed to request permissions: ${e.toString()}',
      );
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  void recheckPermissions() {
    _checkPermissions();
  }
}
