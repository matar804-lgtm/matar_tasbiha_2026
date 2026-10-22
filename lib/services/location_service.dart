import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:huawei_location/huawei_location.dart' as huawei;

class AppLocation {
  final double latitude;
  final double longitude;

  const AppLocation({
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static Future<AppLocation?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    // Android: use the existing Google/geolocator path first.
    // This preserves the current Samsung/Google behavior.
    if (Platform.isAndroid) {
      try {
        final location = await _getGeolocatorLocation(timeout: timeout);
        if (location != null) {
          return location;
        }
      } catch (_) {
        // On Huawei devices without GMS, geolocator may fail.
        // Fall through to Huawei Location Kit.
      }

      try {
        return await _getHuaweiLocation(timeout: timeout);
      } catch (_) {
        return null;
      }
    }

    // Keep the existing geolocator behavior on other platforms.
    try {
      return await _getGeolocatorLocation(timeout: timeout);
    } catch (_) {
      return null;
    }
  }

  static Future<AppLocation?> _getGeolocatorLocation({
    required Duration timeout,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(timeout);

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static Future<AppLocation?> _getHuaweiLocation({
    required Duration timeout,
  }) async {
    final huawei.FusedLocationProviderClient client =
        huawei.FusedLocationProviderClient();

    await client.initFusedLocationService();

    final huawei.LocationRequest request = huawei.LocationRequest()
      ..priority = huawei.LocationRequest.PRIORITY_HIGH_ACCURACY
      ..interval = 2000
      ..fastestInterval = 1000
      ..smallestDisplacement = 0;

    // First try the cached location.
    try {
      final huawei.Location last = await client.getLastLocation();

      if (_isValidHuaweiLocation(last)) {
        return AppLocation(
          latitude: last.latitude!,
          longitude: last.longitude!,
        );
      }
    } catch (_) {
      // No usable cached location; request a fresh one below.
    }

    final Stream<huawei.Location>? stream = client.onLocationData;

    if (stream == null) {
      return null;
    }

    int? requestCode;

    try {
      requestCode = await client.requestLocationUpdates(request);

      final huawei.Location location = await stream
          .firstWhere(_isValidHuaweiLocation)
          .timeout(timeout);

      return AppLocation(
        latitude: location.latitude!,
        longitude: location.longitude!,
      );
    } finally {
      if (requestCode != null) {
        try {
          await client.removeLocationUpdates(requestCode);
        } catch (_) {
          // Ignore cleanup errors.
        }
      }
    }
  }

  static bool _isValidHuaweiLocation(huawei.Location location) {
    final double? latitude = location.latitude;
    final double? longitude = location.longitude;

    if (latitude == null || longitude == null) {
      return false;
    }

    if (latitude == 0.0 && longitude == 0.0) {
      return false;
    }

    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }
}


