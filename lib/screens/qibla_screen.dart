import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/qibla_compass_view.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  Timer? _recalculationTimer;
  StreamSubscription<Position>? _positionSubscription;

  double? _latitude;
  double? _longitude;
  double _qiblaBearing = 0;

  bool _loading = true;
  bool _usingSavedLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  @override
  void dispose() {
    _recalculationTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final bool loadedSaved = await _loadSavedLocation();

      if (!loadedSaved) {
        await _loadCurrentGpsLocation();
      }

      _calculateQibla();

      _positionSubscription?.cancel();

      if (!_usingSavedLocation) {
        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            if (!mounted) {
              return;
            }

            _latitude = position.latitude;
            _longitude = position.longitude;

            _calculateQibla();
          },
        );
      }

      _recalculationTimer?.cancel();
      _recalculationTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) {
          _calculateQibla();
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'تعذر تحديد موقعك الحالي.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<bool> _loadSavedLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    double? latitude = prefs.getDouble('prayer_latitude');
    double? longitude = prefs.getDouble('prayer_longitude');

    latitude ??= double.tryParse(
      prefs.getString('prayer_latitude') ?? '',
    );

    longitude ??= double.tryParse(
      prefs.getString('prayer_longitude') ?? '',
    );

    if (latitude == null || longitude == null) {
      return false;
    }

    if (!_isValidCoordinate(latitude, longitude)) {
      return false;
    }

    _latitude = latitude;
    _longitude = longitude;
    _usingSavedLocation = true;

    return true;
  }

  Future<void> _loadCurrentGpsLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _latitude = position.latitude;
    _longitude = position.longitude;
    _usingSavedLocation = false;
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  void _calculateQibla() {
    final double? latitude = _latitude;
    final double? longitude = _longitude;

    if (latitude == null || longitude == null) {
      return;
    }

    final double lat1 = _degreesToRadians(latitude);
    final double lat2 = _degreesToRadians(_kaabaLatitude);

    final double deltaLongitude =
        _degreesToRadians(_kaabaLongitude - longitude);

    final double y = math.sin(deltaLongitude);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);

    double bearing = math.atan2(y, x);
    bearing = _radiansToDegrees(bearing);

    if (bearing < 0) {
      bearing += 360;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _qiblaBearing = bearing;
    });
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  String _directionText(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) {
      return 'الشمال';
    }
    if (bearing < 67.5) {
      return 'الشمال الشرقي';
    }
    if (bearing < 112.5) {
      return 'الشرق';
    }
    if (bearing < 157.5) {
      return 'الجنوب الشرقي';
    }
    if (bearing < 202.5) {
      return 'الجنوب';
    }
    if (bearing < 247.5) {
      return 'الجنوب الغربي';
    }
    if (bearing < 292.5) {
      return 'الغرب';
    }

    return 'الشمال الغربي';
  }

  String get _locationText {
    if (_latitude == null || _longitude == null) {
      return 'جاري تحديد الموقع...';
    }

    return '°، '
        '°';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اتجاه القبلة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initializeQibla,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildHeaderCard(isDark),
              const SizedBox(height: 16),
              _buildCompassCard(isDark),
              const SizedBox(height: 16),
              _buildInfoCard(isDark),
              const SizedBox(height: 16),
              _buildLocationCard(isDark),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [
                  Color(0xFF173A34),
                  Color(0xFF0F2622),
                ]
              : const [
                  Color(0xFFE9FFF7),
                  Color(0xFFD8F7EC),
                ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
            ),
            child: const Icon(
              Icons.explore_rounded,
              size: 32,
              color: Color(0xFF0A8F62),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدد اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF17352D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'تتجه البوصلة إلى الكعبة المشرفة من موقعك الحالي.',
                  style: TextStyle(
                    height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF48655D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C19) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(
              alpha: isDark ? 0.18 : 0.07,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'البوصلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF20342F),
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const SizedBox(
              height: 350,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            QiblaCompassView(
              qiblaBearing: _qiblaBearing,
              isDark: isDark,
              size: 350,
            ),
          const SizedBox(height: 6),
          Text(
                '°',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF17352D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _directionText(_qiblaBearing),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF62746F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C19) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE4ECE9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0A8F62).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sync_rounded,
              color: Color(0xFF0A8F62),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'يتم إعادة حساب زاوية القبلة كل ثانيتين مع تحديث الموقع عند تحركك.',
              style: TextStyle(
                height: 1.5,
                color: isDark ? Colors.white70 : const Color(0xFF526761),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C19) : Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF0A8F62),
              ),
              const SizedBox(width: 8),
              Text(
                'موقعك',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF20342F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _locationText,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64756F),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _usingSavedLocation
                    ? Icons.bookmark_rounded
                    : Icons.gps_fixed_rounded,
                size: 18,
                color: const Color(0xFF0A8F62),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _usingSavedLocation
                      ? 'الموقع المحفوظ من إعدادات مواقيت الصلاة'
                      : 'الموقع الحالي عبر GPS',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF7A8A85),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: _initializeQibla,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}



