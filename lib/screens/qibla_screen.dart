import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'dart:async';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaAngle;
  double _deviceDirection = 0;
  bool _isLoading = true;
  String _locationStatus = 'جاري تحديد موقعك بدقة...';
  int _selectedStyle = 0;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _distanceToMakkah = 0;

  final List<Map<String, dynamic>> _compassStyles = [
    {
      'name': 'الأزرق الكلاسيكي',
      'icon': Icons.compass_calibration,
      'color': Colors.blue,
      'premium': false
    },
    {
      'name': 'الذهبي الفخم',
      'icon': Icons.star,
      'color': Colors.amber,
      'premium': true
    },
    {
      'name': 'الأخضر الإسلامي',
      'icon': Icons.auto_awesome,
      'color': Colors.green,
      'premium': false
    },
    {
      'name': 'الفضي العصري',
      'icon': Icons.explore,
      'color': Colors.grey,
      'premium': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _getLocationAndCalculate();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getLocationAndCalculate() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'يرجى تفعيل خدمات الموقع من إعدادات الجهاز';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'تم رفض إذن الموقع، يرجى السماح به من الإعدادات';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'تم رفض إذن الموقع بشكل دائم';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double angle = _calculateQibla(position.latitude, position.longitude);
      double distance = _calculateDistance(
          position.latitude, position.longitude, 21.4225, 39.8262);

      setState(() {
        _qiblaAngle = angle;
        _distanceToMakkah = distance;
        _locationStatus = 'تم تحديد الموقع بنجاح ✅';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'حدث خطأ في تحديد الموقع، تأكد من اتصال الإنترنت';
        _isLoading = false;
      });
    }
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent? event) {
      if (event != null && event.heading != null) {
        setState(() {
          _deviceDirection = event.heading!;
        });
      }
    });
  }

  double _calculateQibla(double lat, double lon) {
    const double meccaLat = 21.4225;
    const double meccaLon = 39.8262;
    double phiK = meccaLat * math.pi / 180.0;
    double lambdaK = meccaLon * math.pi / 180.0;
    double phi = lat * math.pi / 180.0;
    double lambda = lon * math.pi / 180.0;
    double y = math.sin(lambdaK - lambda);
    double x = math.cos(phi) * math.tan(phiK) -
        math.sin(phi) * math.cos(lambdaK - lambda);
    double qibla = math.atan2(y, x) * 180.0 / math.pi;
    return (qibla + 360.0) % 360.0;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    double dLat = (lat2 - lat1) * math.pi / 180.0;
    double dLon = (lon2 - lon1) * math.pi / 180.0;
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text('اتجاه القبلة',
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.palette, color: Colors.white),
              tooltip: 'تغيير التصميم',
              onPressed: _showStyleSelector),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(
                      color: Color(0xFF009688), strokeWidth: 3),
                  SizedBox(height: 20),
                  Text('جاري تحديد موقعك وبدء البوصلة...',
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: Colors.white70))
                ]))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2))),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard(
                                  'المسافة من مكة',
                                  '${_distanceToMakkah.toStringAsFixed(1)} كم',
                                  Icons.location_on),
                              _buildInfoCard(
                                  'زاوية القبلة',
                                  '${_qiblaAngle!.toStringAsFixed(1)}°',
                                  Icons.explore)
                            ]),
                        const SizedBox(height: 10),
                        Text(_locationStatus,
                            style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInteractiveCompass(),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xFF009688).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xFF009688)
                                .withValues(alpha: 0.3))),
                    child: const Row(children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF009688), size: 30),
                      SizedBox(width: 15),
                      Expanded(
                          child: Text(
                              'أدر هاتفك ببطء حتى تشير أيقونة الكعبة إلى الأعلى تماماً',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center))
                    ]),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: const Color(0xFF009688), size: 30),
      const SizedBox(height: 5),
      Text(value,
          style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
      Text(title,
          style: const TextStyle(
              fontFamily: 'Amiri', fontSize: 12, color: Colors.white70))
    ]);
  }

  Widget _buildInteractiveCompass() {
    final selectedStyle = _compassStyles[_selectedStyle];
    final compassColor = selectedStyle['color'] as Color;

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          compassColor.withValues(alpha: 0.3),
          compassColor.withValues(alpha: 0.1),
          Colors.transparent
        ]),
        border: Border.all(color: compassColor, width: 4),
        boxShadow: [
          BoxShadow(
              color: compassColor.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5)
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
              top: 15,
              child: Text('N',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          const Positioned(
              bottom: 15,
              child: Text('S',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          const Positioned(
              left: 20,
              child: Text('W',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          const Positioned(
              right: 20,
              child: Text('E',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          Transform.rotate(
            angle: ((_qiblaAngle! - _deviceDirection) * math.pi / 180),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 35,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ]),
                  child: const Center(
                      child: Text('🕋', style: TextStyle(fontSize: 18)))),
              Container(
                  width: 3,
                  height: 80,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Colors.amber,
                    Colors.amber.withValues(alpha: 0.2)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            ]),
          ),
          Transform.rotate(
            angle: -_deviceDirection * math.pi / 180,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.north, color: compassColor, size: 40),
              Container(
                  width: 3,
                  height: 100,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    compassColor,
                    compassColor.withValues(alpha: 0.2)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            ]),
          ),
          Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: compassColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 5)
                  ])),
        ],
      ),
    );
  }

  void _showStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 20),
          const Text('اختر تصميم البوصلة',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1),
            itemCount: _compassStyles.length,
            itemBuilder: (context, index) {
              final style = _compassStyles[index];
              final isSelected = _selectedStyle == index;
              return GestureDetector(
                onTap: style['premium'] as bool
                    ? () => _showPremiumDialog()
                    : () {
                        setState(() => _selectedStyle = index);
                        Navigator.pop(context);
                      },
                child: Container(
                  decoration: BoxDecoration(
                      color: (style['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: isSelected
                              ? style['color'] as Color
                              : Colors.white24,
                          width: isSelected ? 3 : 2)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(style['icon'] as IconData,
                            size: 50, color: style['color'] as Color),
                        const SizedBox(height: 10),
                        Text(style['name'] as String,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                color: isSelected
                                    ? style['color'] as Color
                                    : Colors.white,
                                fontWeight: FontWeight.bold)),
                        if (style['premium'] as bool)
                          Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text('مميز',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))),
                      ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF009688))),
        title: const Text('تصميم مميز',
            style: TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFF009688),
                fontWeight: FontWeight.bold)),
        content: const Text(
            'هذا التصميم متاح حالياً في النسخة المميزة من التطبيق.',
            style: TextStyle(fontFamily: 'Amiri', color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً',
                  style: TextStyle(color: Colors.white, fontFamily: 'Amiri')))
        ],
      ),
    );
  }
}
