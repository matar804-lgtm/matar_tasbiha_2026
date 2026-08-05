import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _enableVibration = true;
  bool _enableSounds = false;
  bool _enableNotifications = true;
  bool _showArabicNumbers = true;
  double _defaultFontSize = 26;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      _enableVibration = prefs.getBool('enable_vibration') ?? true;
      _enableSounds = prefs.getBool('enable_sounds') ?? false;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _showArabicNumbers = prefs.getBool('show_arabic_numbers') ?? true;
      _defaultFontSize = prefs.getDouble('default_font_size') ?? 26;
      _userEmail = prefs.getString('user_email');
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B342B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE8837C), size: 28),
            SizedBox(width: 10),
            Text('تأكيد إعادة التعيين',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من إعادة تعيين جميع البيانات؟\n\nسيتم حذف:\n• جميع عدادات التسبيح\n• الإشارات المرجعية\n• الإعدادات المخصصة\n\n⚠️ لا يمكن التراجع عن هذه العملية',
          style: TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 15,
              height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFD4AF37),
                    fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
            },
            child: const Text('تأكيد الحذف',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFE8837C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _saveSetting('is_dark_mode', true);
    await _saveSetting('enable_vibration', true);
    await _saveSetting('enable_sounds', false);
    await _saveSetting('enable_notifications', true);
    await _saveSetting('show_arabic_numbers', true);
    await _saveSetting('default_font_size', 26.0);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('تم إعادة تعيين جميع البيانات بنجاح',
                style: TextStyle(fontFamily: 'Amiri', fontSize: 16))
          ]),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
      );
      _loadSettings();
    }
  }

  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'appnest.studio01@gmail.com',
      query: 'subject=استفسار حول تطبيق التسبيح&body=السلام عليكم ورحمة الله،',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('البريد: appnest.studio01@gmail.com',
                style: TextStyle(fontFamily: 'Amiri')),
            backgroundColor: Color(0xFF1B342B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('تم نسخ رابط التطبيق!', style: TextStyle(fontFamily: 'Amiri')),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('شكراً لتقييمك! ✨', style: TextStyle(fontFamily: 'Amiri')),
        backgroundColor: Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A201A), Color(0xFF132A22), Color(0xFF0A201A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('المظهر والتخصيص', Icons.palette_rounded),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF7C4DFF),
                title: 'الوضع الليلي',
                subtitle: 'تفعيل المظهر الداكن للتطبيق',
                value: _isDarkMode,
                onChanged: (v) {
                  setState(() => _isDarkMode = v);
                  _saveSetting('is_dark_mode', v);
                },
              ),
              _buildSwitchTile(
                icon: Icons.text_fields_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'الأرقام العربية',
                subtitle: 'عرض الأرقام بالأرقام العربية (١، ٢، ٣)',
                value: _showArabicNumbers,
                onChanged: (v) {
                  setState(() => _showArabicNumbers = v);
                  _saveSetting('show_arabic_numbers', v);
                },
              ),
              _buildSliderTile(
                icon: Icons.format_size_rounded,
                iconColor: const Color(0xFF00BCD4),
                title: 'حجم الخط الافتراضي',
                value: _defaultFontSize,
                min: 16,
                max: 40,
                divisions: 12,
                onChanged: (v) {
                  setState(() => _defaultFontSize = v);
                  _saveSetting('default_font_size', v);
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('التفضيلات', Icons.tune_rounded),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.vibration_rounded,
                iconColor: const Color(0xFFE91E63),
                title: 'الاهتزاز',
                subtitle: 'تفعيل الاهتزاز عند الضغط على الأزرار',
                value: _enableVibration,
                onChanged: (v) {
                  setState(() => _enableVibration = v);
                  _saveSetting('enable_vibration', v);
                  if (v) HapticFeedback.lightImpact();
                },
              ),
              _buildSwitchTile(
                icon: Icons.volume_up_rounded,
                iconColor: const Color(0xFFFF9800),
                title: 'الأصوات',
                subtitle: 'تفعيل الأصوات عند العد والإكمال',
                value: _enableSounds,
                onChanged: (v) {
                  setState(() => _enableSounds = v);
                  _saveSetting('enable_sounds', v);
                },
              ),
              _buildSwitchTile(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: 'الإشعارات',
                subtitle: 'تفعيل تذكيرات الأذكار ومواقيت الصلاة',
                value: _enableNotifications,
                onChanged: (v) {
                  setState(() => _enableNotifications = v);
                  _saveSetting('enable_notifications', v);
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('البيانات', Icons.storage_rounded),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: const Color(0xFFE8837C),
                title: 'إعادة تعيين جميع البيانات',
                subtitle: 'حذف جميع العدادات والإشارات المرجعية',
                onTap: _showResetDialog,
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('التواصل والدعم', Icons.support_agent_rounded),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.email_rounded,
                iconColor: const Color(0xFFD4AF37),
                title: 'تواصل معنا',
                subtitle: 'appnest.studio01@gmail.com',
                onTap: _contactUs,
              ),
              _buildActionTile(
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق مع أصدقائك وأحبابك',
                onTap: _shareApp,
              ),
              _buildActionTile(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFC107),
                title: 'تقييم التطبيق',
                subtitle: 'شاركنا رأيك لتحسين التطبيق',
                onTap: _rateApp,
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('عن التطبيق', Icons.info_outline_rounded),
            const SizedBox(height: 10),
            _buildAboutCard(),
            const SizedBox(height: 30),
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final bool isSubscribed = _userEmail != null && _userEmail!.isNotEmpty;

    // استخراج الاسم من الإيميل وتكبير الحرف الأول بأمان بدون extension
    final String rawName =
        isSubscribed ? _userEmail!.split('@').first : 'زائرنا الكريم';
    final String displayName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1)
        : rawName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B342B), Color(0xFF2A4A3D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                  ),
                  border: Border.all(color: const Color(0xFFF0E0B5), width: 2),
                ),
                child: Icon(
                  isSubscribed
                      ? Icons.person_rounded
                      : Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF0A201A),
                  size: 35,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSubscribed
                          ? 'مرحباً بك، $displayName'
                          : 'انضم لعائلتنا',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSubscribed
                          ? 'شكراً لثقتك واختيارك تطبيق التسبيح'
                          : 'سجل بريدك الإلكتروني لتكون جزءاً منا',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    if (isSubscribed) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              color: Color(0xFF9AB09F), size: 14),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _userEmail!,
                              style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  color: Color(0xFF9AB09F),
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFD4AF37), height: 1, thickness: 0.5),
          const SizedBox(height: 10),
          if (!isSubscribed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('اشترك الآن',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A201A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8837C),
                  side: const BorderSide(color: Color(0xFFE8837C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
              height: 1, color: const Color(0xFFD4AF37).withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF132A22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFD4AF37),
            inactiveTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('الحجم الحالي: ${value.toInt()}',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFD4AF37),
              inactiveTrackColor: const Color(0xFFD4AF37).withOpacity(0.2),
              thumbColor: const Color(0xFFD4AF37),
              overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              label: '${value.toInt()}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFE8837C).withOpacity(0.15)
                    : iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isDestructive ? const Color(0xFFE8837C) : iconColor,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          color: isDestructive
                              ? const Color(0xFFE8837C)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.4), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B342B), Color(0xFF2A4A3D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
              ),
              border: Border.all(color: const Color(0xFFF0E0B5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.mosque_rounded,
                color: Color(0xFF0A201A), size: 45),
          ),
          const SizedBox(height: 15),
          const Text(
            'تطبيق التسبيح',
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'رفيقك الهادئ للعبادة اليومية',
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                color: Color(0xFF9AB09F),
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 15),
          Container(height: 1, color: const Color(0xFFD4AF37).withOpacity(0.3)),
          const SizedBox(height: 15),
          const Text(
            'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأدعية، مواقيت الصلاة، اتجاه القبلة، والرقية الشرعية، في تصميم أنيق وسهل الاستخدام.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                color: Colors.white,
                height: 1.8),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(Icons.code_rounded, 'الإصدار', '1.1.0'),
              _buildInfoItem(
                  Icons.calendar_today_rounded, 'التحديث', 'أغسطس 2026'),
              _buildInfoItem(Icons.star_rounded, 'التقييم', '4.9'),
            ],
          ),
          const SizedBox(height: 15),
          Container(height: 1, color: const Color(0xFFD4AF37).withOpacity(0.3)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.developer_mode_rounded,
                    color: Color(0xFFD4AF37), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تطوير وتصميم',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFF9AB09F),
                            fontSize: 12)),
                    Text('محمد مطر',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFD4AF37),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('AppNest Studio',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFF9AB09F),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Amiri', color: Color(0xFF9AB09F), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFFD4AF37),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 40,
                height: 1,
                color: const Color(0xFFD4AF37).withOpacity(0.4)),
            const SizedBox(width: 10),
            const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 14),
            const SizedBox(width: 10),
            Container(
                width: 40,
                height: 1,
                color: const Color(0xFFD4AF37).withOpacity(0.4)),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'صُنع بـ ❤️ لخدمة الإسلام والمسلمين',
          style: TextStyle(
              fontFamily: 'Amiri',
              color: Color(0xFF9AB09F),
              fontSize: 13,
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 5),
        const Text(
          '© 2026 AppNest Studio - جميع الحقوق محفوظة',
          style: TextStyle(
              fontFamily: 'Amiri', color: Color(0xFF9AB09F), fontSize: 11),
        ),
      ],
    );
  }
}
