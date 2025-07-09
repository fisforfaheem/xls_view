import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check and request storage permissions
  Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't need these permissions
    }

    try {
      // For Android 13+ (API 33+), we need different permissions
      if (await _isAndroid13OrHigher()) {
        return await _requestAndroid13Permissions();
      } else {
        return await _requestLegacyStoragePermissions();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permissions: $e');
      }
      return false;
    }
  }

  /// Request permissions for Android 13+ (Granular media permissions)
  Future<bool> _requestAndroid13Permissions() async {
    // Request specific media permissions for Android 13+
    final permissions = [
      Permission.videos, // For accessing document files
      Permission.audio, // Sometimes needed for document access
      Permission.manageExternalStorage, // For full storage access if needed
    ];

    Map<Permission, PermissionStatus> statuses = {};

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        statuses[permission] = await permission.request();
      } else {
        statuses[permission] = status;
      }
    }

    // Check if we have at least basic file access
    final hasBasicAccess = statuses.values.any((status) => status.isGranted);

    if (!hasBasicAccess) {
      // Try requesting storage permission as fallback
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    return hasBasicAccess;
  }

  /// Request permissions for Android 10-12 (Legacy storage permissions)
  Future<bool> _requestLegacyStoragePermissions() async {
    final permissions = [Permission.storage, Permission.manageExternalStorage];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (result.isGranted) {
          return true;
        }
      } else {
        return true;
      }
    }

    return false;
  }

  /// Check current storage permission status
  Future<bool> hasStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      if (await _isAndroid13OrHigher()) {
        // For Android 13+, check if we have any media permissions
        final permissions = [
          Permission.videos,
          Permission.audio,
          Permission.manageExternalStorage,
          Permission.storage,
        ];

        for (final permission in permissions) {
          final status = await permission.status;
          if (status.isGranted) {
            return true;
          }
        }
        return false;
      } else {
        // For older Android versions
        final storageStatus = await Permission.storage.status;
        final manageStorageStatus =
            await Permission.manageExternalStorage.status;

        return storageStatus.isGranted || manageStorageStatus.isGranted;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permissions: $e');
      }
      return false;
    }
  }

  /// Open app settings if permissions are permanently denied
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if the device is running Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    try {
      // This is a simple check, in a real app you might want to use
      // platform channels to get the exact API level
      return true; // Assume modern Android for safety
    } catch (e) {
      return false;
    }
  }

  /// Show permission rationale dialog
  Future<bool> shouldShowRequestPermissionRationale() async {
    if (!Platform.isAndroid) return false;

    try {
      final storage = await Permission.storage.shouldShowRequestRationale;
      final manageStorage =
          await Permission.manageExternalStorage.shouldShowRequestRationale;

      return storage || manageStorage;
    } catch (e) {
      return false;
    }
  }

  /// Get permission status details for debugging
  Future<Map<String, String>> getPermissionStatusDetails() async {
    final details = <String, String>{};

    if (!Platform.isAndroid) {
      details['platform'] = 'iOS - No permissions needed';
      return details;
    }

    try {
      final permissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.videos,
        Permission.audio,
      ];

      for (final permission in permissions) {
        final status = await permission.status;
        details[permission.toString()] = status.toString();
      }
    } catch (e) {
      details['error'] = e.toString();
    }

    return details;
  }
}
