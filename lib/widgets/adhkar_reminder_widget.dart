import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarReminderWidget extends StatefulWidget {
  const AdhkarReminderWidget({Key? key}) : super(key: key);

  @override
  State<AdhkarReminderWidget> createState() => _AdhkarReminderWidgetState();
}

class _AdhkarReminderWidgetState extends State<AdhkarReminderWidget> {
  final Color goldColor = const Color(0xFFD4AF37);
  bool isReminderOn = false;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isReminderOn = prefs.getBool('adhkarReminderOn') ?? false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      isReminderOn = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhkarReminderOn', value);

    if (value) {
      // TODO: قم باستدعاء دالة جدولة الإشعار هنا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تفعيل تذكير الأذكار'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      // TODO: قم باستدعاء دالة إلغاء الإشعار هنا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إيقاف تذكير الأذكار'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF1B342B), // ✅ إضافة لون متناسق مع التطبيق
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: goldColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active,
                      color: Color(0xFFD4AF37), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تذكير الأذكار',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Amiri')),
                    SizedBox(height: 4),
                    Text('تنبيه يومي للأذكار',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'Amiri')),
                  ],
                ),
              ],
            ),
            // ✅ تم الإصلاح: activeColor -> activeThumbColor
            // ✅ تم الإصلاح: withOpacity -> withValues
            Switch(
              value: isReminderOn,
              onChanged: _toggleReminder,
              activeThumbColor: const Color(0xFFD4AF37),
              activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
