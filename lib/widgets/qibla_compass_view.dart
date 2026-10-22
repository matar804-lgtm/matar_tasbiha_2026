import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_compass/flutter_device_compass.dart';

class QiblaCompassView extends StatefulWidget {
  const QiblaCompassView({
    super.key,
    required this.qiblaBearing,
    required this.isDark,
    this.size = 350,
  });

  final double qiblaBearing;
  final bool isDark;
  final double size;

  @override
  State<QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<QiblaCompassView>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSubscription;

  double _heading = 0;
  double _accuracy = 0;

  bool _hasSensor = true;
  bool _isAligned = false;
  bool _manualMode = false;

  double _manualHeading = 0;

  DateTime? _lastVibration;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startCompass();
  }

  Future<void> _startCompass() async {
    try {
      final bool? hasSensors = await FlutterCompass.hasSensors;

      if (!mounted) {
        return;
      }

      if (hasSensors != true) {
        setState(() {
          _hasSensor = false;
          _manualMode = true;
        });
        return;
      }

      final Stream<CompassEvent>? stream = FlutterCompass.events;

      if (stream == null) {
        setState(() {
          _hasSensor = false;
          _manualMode = true;
        });
        return;
      }

      await _compassSubscription?.cancel();

      _compassSubscription = stream.listen(
        _onCompassEvent,
        onError: (_) {
          if (!mounted) {
            return;
          }

          setState(() {
            _hasSensor = false;
            _manualMode = true;
          });
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasSensor = false;
        _manualMode = true;
      });
    }
  }

  void _onCompassEvent(CompassEvent event) {
    final double? value = event.heading;

    if (value == null || !value.isFinite) {
      return;
    }

    final double normalizedHeading = _normalize(value);
    final double? accuracy = event.accuracy;

    if (!mounted) {
      return;
    }

    setState(() {
      _heading = normalizedHeading;

      if (accuracy != null && accuracy.isFinite) {
        _accuracy = accuracy;
      }

      _hasSensor = true;
      _manualMode = false;
    });

    _checkAlignment(normalizedHeading);
  }

  void _checkAlignment(double heading) {
    final double difference = _shortestAngleDifference(
      heading,
      widget.qiblaBearing,
    );

    final bool aligned = difference.abs() <= 3.0;

    if (aligned != _isAligned) {
      if (mounted) {
        setState(() {
          _isAligned = aligned;
        });
      }

      if (aligned) {
        final DateTime now = DateTime.now();

        if (_lastVibration == null ||
            now.difference(_lastVibration!) >
                const Duration(milliseconds: 900)) {
          _lastVibration = now;
          HapticFeedback.mediumImpact();
        }
      }
    }
  }

  double get _effectiveHeading {
    return _manualMode ? _manualHeading : _heading;
  }

  double get _relativeQibla {
    return _normalize(widget.qiblaBearing - _effectiveHeading);
  }

  String get _statusText {
    if (_manualMode) {
      return 'الوضع اليدوي – اسحب البوصلة لتعيين الاتجاه';
    }

    if (_isAligned) {
      return 'تمت محاذاة القبلة';
    }

    return 'حرّك الهاتف حتى يتجه السهم إلى القبلة';
  }

  Color get _gold => const Color(0xFFD4AF37);
  Color get _goldLight => const Color(0xFFF0D875);
  Color get _goldDark => const Color(0xFF9A7B0A);
  Color get _background => const Color(0xFF06080F);
  Color get _textPrimary => const Color(0xFFE8DCC8);
  Color get _textSecondary => const Color(0xFF7A6F5E);

  @override
  void didUpdateWidget(covariant QiblaCompassView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.qiblaBearing != widget.qiblaBearing) {
      _checkAlignment(_effectiveHeading);
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = math.min(widget.size, 350);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: diameter,
          height: diameter + 34,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: _manualMode ? _handleManualDrag : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StarBackgroundPainter(
                      dark: widget.isDark,
                    ),
                  ),
                ),
                _buildTopPointer(diameter),
                SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size.square(diameter),
                            painter: _CompassFacePainter(
                              heading: _effectiveHeading,
                              gold: _gold,
                              goldLight: _goldLight,
                              goldDark: _goldDark,
                              background: _background,
                            ),
                          );
                        },
                      ),
                      CustomPaint(
                        size: Size.square(diameter),
                        painter: _QiblaNeedlePainter(
                          relativeBearing: _relativeQibla,
                          gold: _gold,
                          goldLight: _goldLight,
                          goldDark: _goldDark,
                          aligned: _isAligned,
                        ),
                      ),
                      _buildCenterHub(diameter),
                      if (_isAligned)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final double opacity =
                                0.16 + (_pulseController.value * 0.14);

                            return Container(
                              width: diameter - 8,
                              height: diameter - 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _gold.withValues(alpha: opacity),
                                  width: 3,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildStatus(),
        const SizedBox(height: 8),
        _buildSensorInfo(),
      ],
    );
  }

  Widget _buildTopPointer(double diameter) {
    return Positioned(
      top: 0,
      child: CustomPaint(
        size: const Size(30, 22),
        painter: _TopPointerPainter(
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildCenterHub(double diameter) {
    return Container(
      width: math.min(58, diameter * 0.18),
      height: math.min(58, diameter * 0.18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF10131B),
        border: Border.all(
          color: _gold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(28, 28),
          painter: _KaabaPainter(),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final Color statusColor = _isAligned ? const Color(0xFF4CAF50) : _gold;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.55),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _statusText,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: _isAligned ? const Color(0xFF81C784) : _textPrimary,
              fontSize: 12.5,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorInfo() {
    final String headingText = '${_effectiveHeading.toStringAsFixed(1)}°';

    final String accuracyText =
        _accuracy > 0 ? '±${_accuracy.toStringAsFixed(1)}°' : '—';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _smallInfo(
          Icons.explore_outlined,
          headingText,
        ),
        const SizedBox(width: 18),
        _smallInfo(
          Icons.gps_fixed_rounded,
          _hasSensor ? accuracyText : 'غير متاح',
        ),
      ],
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: _textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleManualDrag(DragUpdateDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    if (box == null) {
      return;
    }

    final Offset center = box.size.center(Offset.zero);
    final Offset point = details.localPosition;

    final double dx = point.dx - center.dx;
    final double dy = point.dy - center.dy;

    if (dx.abs() < 2 && dy.abs() < 2) {
      return;
    }

    double angle = math.atan2(dx, -dy);
    double degrees = angle * 180 / math.pi;

    if (degrees < 0) {
      degrees += 360;
    }

    setState(() {
      _manualHeading = degrees;
    });

    _checkAlignment(degrees);
  }

  double _normalize(double value) {
    double result = value % 360;

    if (result < 0) {
      result += 360;
    }

    return result;
  }

  double _shortestAngleDifference(double a, double b) {
    double difference = _normalize(a - b);

    if (difference > 180) {
      difference -= 360;
    }

    return difference;
  }
}

// -----------------------------------------------------------------------------
// Compass face
// -----------------------------------------------------------------------------

class _CompassFacePainter extends CustomPainter {
  const _CompassFacePainter({
    required this.heading,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.background,
  });

  final double heading;
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2;

    // Outer gold ring.
    final Paint outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          goldDark,
          goldLight,
          gold,
          goldDark,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius * 0.44,
        ),
      );

    canvas.drawCircle(
      center,
      radius * 0.44,
      outerRing,
    );

    canvas.save();

    canvas.translate(center.dx, center.dy);

    // This is the important part:
    // the physical compass face rotates opposite to the device heading.
    canvas.rotate(-heading * math.pi / 180);

    canvas.translate(-center.dx, -center.dy);

    // Main disc.
    final Paint discPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1B1D25),
          const Color(0xFF0E1118),
          background,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius * 0.41,
        ),
      );

    canvas.drawCircle(
      center,
      radius * 0.405,
      discPaint,
    );

    // Inner rings.
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gold.withValues(alpha: 0.20);

    canvas.drawCircle(
      center,
      radius * 0.37,
      ringPaint,
    );

    canvas.drawCircle(
      center,
      radius * 0.30,
      ringPaint,
    );

    // Degree ticks.
    for (int degree = 0; degree < 360; degree += 5) {
      final bool major = degree % 30 == 0;
      final bool medium = degree % 10 == 0;

      final double outer = radius * 0.405;
      final double inner = major
          ? radius * 0.345
          : medium
              ? radius * 0.365
              : radius * 0.382;

      final double radians = degree * math.pi / 180;

      final Offset p1 = Offset(
        center.dx + math.sin(radians) * inner,
        center.dy - math.cos(radians) * inner,
      );

      final Offset p2 = Offset(
        center.dx + math.sin(radians) * outer,
        center.dy - math.cos(radians) * outer,
      );

      final Paint tickPaint = Paint()
        ..color = major
            ? goldLight
            : gold.withValues(
                alpha: medium ? 0.65 : 0.34,
              )
        ..strokeWidth = major ? 2.2 : 1
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, tickPaint);
    }

    // Cardinal directions.
    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'N',
      goldLight,
      0,
      true,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'E',
      gold,
      90,
      false,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'S',
      gold,
      180,
      false,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'W',
      gold,
      270,
      false,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'NE',
      gold.withValues(alpha: 0.55),
      45,
      false,
      small: true,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'SE',
      gold.withValues(alpha: 0.55),
      135,
      false,
      small: true,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'SW',
      gold.withValues(alpha: 0.55),
      225,
      false,
      small: true,
    );

    _drawDirection(
      canvas,
      center,
      radius * 0.275,
      'NW',
      gold.withValues(alpha: 0.55),
      315,
      false,
      small: true,
    );

    // Degree numbers every 30 degrees.
    for (int degree = 0; degree < 360; degree += 30) {
      final double radians = degree * math.pi / 180;

      final Offset position = Offset(
        center.dx + math.sin(radians) * radius * 0.335,
        center.dy - math.cos(radians) * radius * 0.335,
      );

      final String label = degree.toString();

      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: gold.withValues(alpha: 0.55),
            fontSize: radius * 0.042,
            fontFamily: 'Amiri',
              fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        position -
            Offset(
              painter.width / 2,
              painter.height / 2,
            ),
      );
    }

    canvas.restore();
  }

  void _drawDirection(
    Canvas canvas,
    Offset center,
    double distance,
    String label,
    Color color,
    double degrees,
    bool bold, {
    bool small = false,
  }) {
    final double radians = degrees * math.pi / 180;

    final Offset position = Offset(
      center.dx + math.sin(radians) * distance,
      center.dy - math.cos(radians) * distance,
    );

    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 14,
          fontFamily: 'Amiri',
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      position -
          Offset(
            painter.width / 2,
            painter.height / 2,
          ),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassFacePainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}

// -----------------------------------------------------------------------------
// Qibla needle
// -----------------------------------------------------------------------------

class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter({
    required this.relativeBearing,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.aligned,
  });

  final double relativeBearing;
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(relativeBearing * math.pi / 180);

    // Glow behind the needle.
    if (aligned) {
      final Paint glow = Paint()
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        Offset(0, -radius * 0.24),
        radius * 0.12,
        glow,
      );
    }

    // Gold Qibla arrow.
    final Path arrow = Path()
      ..moveTo(0, -radius * 0.335)
      ..lineTo(-radius * 0.052, -radius * 0.13)
      ..lineTo(0, -radius * 0.17)
      ..lineTo(radius * 0.052, -radius * 0.13)
      ..close();

    final Paint arrowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          goldLight,
          gold,
          goldDark,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(0, -radius * 0.22),
          width: radius * 0.12,
          height: radius * 0.24,
        ),
      );

    canvas.drawPath(arrow, arrowPaint);

    // Red tail.
    final Path tail = Path()
      ..moveTo(0, radius * 0.30)
      ..lineTo(-radius * 0.04, radius * 0.10)
      ..lineTo(0, radius * 0.15)
      ..lineTo(radius * 0.04, radius * 0.10)
      ..close();

    final Paint tailPaint = Paint()..color = const Color(0xFF8B0000);

    canvas.drawPath(tail, tailPaint);

    // Tiny tip.
    final Paint tipPaint = Paint()
      ..color = aligned ? const Color(0xFF81C784) : goldLight
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(0, -radius * 0.34),
      radius * 0.018,
      tipPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) {
    return oldDelegate.relativeBearing != relativeBearing ||
        oldDelegate.aligned != aligned;
  }
}

// -----------------------------------------------------------------------------
// Top fixed pointer
// -----------------------------------------------------------------------------

class _TopPointerPainter extends CustomPainter {
  const _TopPointerPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          const Color(0xFF9A7B0A),
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// -----------------------------------------------------------------------------
// Kaaba icon
// -----------------------------------------------------------------------------

class _KaabaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint black = Paint()..color = const Color(0xFF080808);

    final Paint gold = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Rect body = Rect.fromLTWH(
      w * 0.18,
      h * 0.24,
      w * 0.64,
      h * 0.58,
    );

    canvas.drawRect(body, black);

    canvas.drawLine(
      Offset(w * 0.18, h * 0.42),
      Offset(w * 0.82, h * 0.42),
      gold,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        w * 0.25,
        h * 0.38,
        w * 0.50,
        h * 0.10,
      ),
      gold,
    );

    final Path roof = Path()
      ..moveTo(w * 0.18, h * 0.24)
      ..lineTo(w * 0.50, h * 0.10)
      ..lineTo(w * 0.82, h * 0.24)
      ..close();

    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFF141414),
    );

    canvas.drawPath(
      roof,
      gold,
    );
  }

  @override
  bool shouldRepaint(covariant _KaabaPainter oldDelegate) {
    return false;
  }
}

// -----------------------------------------------------------------------------
// Background stars
// -----------------------------------------------------------------------------

class _StarBackgroundPainter extends CustomPainter {
  const _StarBackgroundPainter({
    required this.dark,
  });

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(
        alpha: dark ? 0.10 : 0.05,
      );

    final List<Offset> stars = [
      Offset(size.width * 0.12, size.height * 0.16),
      Offset(size.width * 0.86, size.height * 0.13),
      Offset(size.width * 0.08, size.height * 0.53),
      Offset(size.width * 0.91, size.height * 0.49),
      Offset(size.width * 0.20, size.height * 0.82),
      Offset(size.width * 0.78, size.height * 0.84),
      Offset(size.width * 0.33, size.height * 0.07),
      Offset(size.width * 0.67, size.height * 0.09),
    ];

    for (final Offset star in stars) {
      canvas.drawCircle(
        star,
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarBackgroundPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

