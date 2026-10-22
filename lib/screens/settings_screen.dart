import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_theme_controller.dart';
import 'login_screen.dart';
import '../services/prayer_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _lightGold = Color(0xFFF0E0B5);
  static const Color _darkBackground = Color(0xFF0A201A);
  static const Color _darkCard = Color(0xFF132A22);
  static const Color _darkGreen = Color(0xFF1B342B);
  static const Color _mutedDark = Color(0xFF9AB09F);
  static const Color _danger = Color(0xFFE8837C);

  final AppThemeController _themeController = AppThemeController.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isDarkMode = true;
  bool _enableVibration = true;
  bool _enableSounds = false;
  bool _enableNotifications = true;
  bool _showArabicNumbers = true;
  bool _enableAdhan = true;

  String _selectedSoundId = 'adhan_makkah';
  String? _userEmail;

  bool _isPlayingPreview = false;
  String? _playingSoundId;
  bool _isAdhanDropdownOpen = false;

  final List<AdhanSoundOption> _adhanSounds = const [
    AdhanSoundOption(
      id: 'adhan_makkah',
      name: 'أذان مكة',
      subtitle: 'أذان مكة المكرمة',
      asset: 'adhan_makkah.mp3',
      icon: Icons.mosque_rounded,
    ),
    AdhanSoundOption(
      id: 'almadenh',
      name: 'أذان المدينة',
      subtitle: 'أذان المدينة المنورة',
      asset: 'almadenh.mp3',
      icon: Icons.mosque_rounded,
    ),
    AdhanSoundOption(
      id: 'alquds',
      name: 'أذان القدس',
      subtitle: 'أذان القدس الشريف',
      asset: 'alquds.mp3',
      icon: Icons.account_balance_rounded,
    ),
    AdhanSoundOption(
      id: 'mshary',
      name: 'مشاري العفاسي',
      subtitle: 'أذان بصوت مشاري العفاسي',
      asset: 'mshary.mp3',
      icon: Icons.record_voice_over_rounded,
    ),
    AdhanSoundOption(
      id: 'abd_albaset',
      name: 'عبد الباسط',
      subtitle: 'أذان بصوت عبد الباسط',
      asset: 'abd_albaset.mp3',
      icon: Icons.record_voice_over_rounded,
    ),
    AdhanSoundOption(
      id: 'takbeer',
      name: 'التكبير',
      subtitle: 'تكبير فقط وليس الأذان الكامل',
      asset: 'takbeer.mp3',
      icon: Icons.volume_up_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlayingPreview = state == PlayerState.playing;
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          _playingSoundId = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      _enableVibration = prefs.getBool('enable_vibration') ?? true;
      _enableSounds = prefs.getBool('enable_sounds') ?? false;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _showArabicNumbers = prefs.getBool('show_arabic_numbers') ?? true;
      _userEmail = prefs.getString('user_email');
      _enableAdhan = prefs.getBool('enable_adhan') ?? true;
      _selectedSoundId =
          prefs.getString('selected_app_sound_id') ?? 'adhan_makkah';
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _setDarkMode(bool enabled) async {
    setState(() => _isDarkMode = enabled);

    await _themeController.setDarkMode(enabled);
    await _setBool('is_dark_mode', enabled);

    if (!mounted) return;
    _showMessage(
      enabled ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع النهاري',
    );
  }

  Future<void> _setSoundsEnabled(bool enabled) async {
    setState(() => _enableSounds = enabled);
    await _setBool('enable_sounds', enabled);

    if (!enabled) await _stopPreview();
    _showMessage(enabled ? 'تم تشغيل الأصوات' : 'تم كتم أصوات التطبيق');
  }

  Future<void> _setVibrationEnabled(bool enabled) async {
    setState(() => _enableVibration = enabled);
    await _setBool('enable_vibration', enabled);
    if (enabled) HapticFeedback.lightImpact();
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    setState(() => _enableNotifications = enabled);
    await _setBool('enable_notifications', enabled);
    await PrayerNotificationService.schedulePrayerNotifications();
    _showMessage(enabled ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات');
  }

  Future<void> _setArabicNumbers(bool enabled) async {
    setState(() => _showArabicNumbers = enabled);
    await _setBool('show_arabic_numbers', enabled);
  }

  Future<void> _setAdhanEnabled(bool enabled) async {
    setState(() => _enableAdhan = enabled);
    await _setBool('enable_adhan', enabled);

    if (!enabled) await _stopPreview();

    // تطبيق اختيار المستخدم على الأذانات التي سبق جدولتها.
    await PrayerNotificationService.schedulePrayerNotifications();

    if (!mounted) return;
    _showMessage(
      enabled
          ? 'تم تفعيل صوت الأذان'
          : 'تم إيقاف صوت الأذان مع الإبقاء على تنبيه الصلاة',
    );
  }

  Future<void> _selectAdhanSound(AdhanSoundOption sound) async {
    await _stopPreview();

    setState(() {
      _selectedSoundId = sound.id;
      _isAdhanDropdownOpen = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_app_sound_id', sound.id);

    _showMessage('تم اختيار ${sound.name}');
  }

  Future<void> _previewSound(AdhanSoundOption sound) async {
    if (!_enableAdhan || !_enableSounds) {
      _showMessage(
        !_enableSounds ? 'الأصوات مكتومة حالياً' : 'صوت الأذان متوقف',
      );
      return;
    }

    try {
      if (_playingSoundId == sound.id && _isPlayingPreview) {
        await _stopPreview();
        return;
      }

      await _stopPreview();

      if (!mounted) return;

      setState(() {
        _playingSoundId = sound.id;
        _isPlayingPreview = true;
      });

      await _audioPlayer.play(AssetSource('audio/${sound.asset}'));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPlayingPreview = false;
        _playingSoundId = null;
      });

      _showErrorMessage(
        'تعذر تشغيل الصوت. تأكد من وجود الملف:\nassets/audio/${sound.asset}',
      );
    }
  }

  Future<void> _stopPreview() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isPlayingPreview = false;
      _playingSoundId = null;
    });
  }

  // المشاركة الحالية بدون QR حتى التحديث القادم.
  Future<void> _shareApp() async {
    const message = '🌙 تطبيق تسبيحة\n\n'
        'رفيقك الهادئ للعبادة اليومية 🤍\n\n'
        'يضم القرآن الكريم، الأذكار، الأدعية، مواقيت الصلاة، '
        'اتجاه القبلة وغيرها من الأدوات الإسلامية المفيدة.\n\n'
        'شاركه مع من تحب وكن سبباً في نشر الخير.';

    try {
      await Share.share(
        message,
        subject: 'تطبيق تسبيحة',
      );
    } catch (_) {
      if (!mounted) return;
      _showErrorMessage('تعذر فتح نافذة المشاركة');
    }
  }

  Future<void> _rateApp() async {
    const String storeUrl = String.fromEnvironment(
      'APP_STORE_URL',
      defaultValue:
          'https://play.google.com/store/apps/details?id=com.appnest.tasbiha',
    );

    try {
      final bool opened = await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage('تعذر فتح صفحة المتجر حالياً');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('تعذر فتح صفحة المتجر حالياً');
      }
    }
  }

  Future<void> _contactUs() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'appnest.studio01@gmail.com',
      queryParameters: const {
        'subject': 'استفسار حول تطبيق تسبيحة',
        'body': 'السلام عليكم ورحمة الله،\n\nلدي استفسار حول تطبيق تسبيحة:',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } else if (mounted) {
        _showMessage('البريد: appnest.studio01@gmail.com');
      }
    } catch (_) {
      if (mounted) _showMessage('البريد: appnest.studio01@gmail.com');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> _resetAllData() async {
    final prefs = await SharedPreferences.getInstance();

    const keys = [
      'tasbih_count',
      'tasbih_total_count',
      'total_tasbih',
      'today_tasbih',
      'tasbih_history',
      'bookmarks',
      'quran_bookmarks_list',
      'saved_azkar',
      'saved_duas',
      'selected_app_sound_id',
    ];

    for (final key in keys) {
      await prefs.remove(key);
    }

    await prefs.setBool('is_dark_mode', true);
    await prefs.setBool('enable_vibration', true);
    await prefs.setBool('enable_sounds', false);
    await prefs.setBool('enable_notifications', true);
    await prefs.setBool('show_arabic_numbers', true);
    await prefs.setBool('enable_adhan', true);
    await prefs.setString('selected_app_sound_id', 'adhan_makkah');

    await _themeController.setDarkMode(true);

    if (!mounted) return;

    await _loadSettings();
    _showMessage(
      'تم إعادة الإعدادات والبيانات بنجاح',
      icon: Icons.check_circle_rounded,
      backgroundColor: Colors.green.shade700,
    );
  }

  void _showResetDialog() {
    final scheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: _danger,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تأكيد إعادة التعيين',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: scheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم حذف العدادات والإشارات المرجعية والإعدادات المخصصة.\n\nلا يمكن التراجع عن هذه العملية.',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: scheme.onSurface,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: scheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _resetAllData();
              },
              child: const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: _danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedSound = _adhanSounds.firstWhere(
      (sound) => sound.id == _selectedSoundId,
      orElse: () => _adhanSounds.first,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? _darkGreen : Colors.white,
        foregroundColor: isDark ? _gold : _darkGreen,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإعدادات',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: isDark ? _gold : _darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? _gold : _darkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(context),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'المظهر والتخصيص',
            Icons.palette_rounded,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            [
              _buildSwitchTile(
                context: context,
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF7C4DFF),
                title: 'الوضع الليلي',
                subtitle: _isDarkMode
                    ? 'المظهر الداكن مفعل على كامل التطبيق'
                    : 'المظهر النهاري مفعل على كامل التطبيق',
                value: _isDarkMode,
                onChanged: _setDarkMode,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.text_fields_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'الأرقام العربية',
                subtitle: 'عرض الأرقام بالأرقام العربية',
                value: _showArabicNumbers,
                onChanged: _setArabicNumbers,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'التفضيلات',
            Icons.tune_rounded,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            [
              _buildSwitchTile(
                context: context,
                icon: Icons.vibration_rounded,
                iconColor: const Color(0xFFE91E63),
                title: 'الاهتزاز',
                subtitle: 'اهتزاز خفيف عند الضغط',
                value: _enableVibration,
                onChanged: _setVibrationEnabled,
              ),
              _buildSwitchTile(
                context: context,
                icon: _enableSounds
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                iconColor: const Color(0xFFFF9800),
                title: 'أصوات التطبيق',
                subtitle:
                    _enableSounds ? 'الأصوات مفعلة' : 'تم كتم أصوات التطبيق',
                value: _enableSounds,
                onChanged: _setSoundsEnabled,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: 'الإشعارات',
                subtitle: 'تذكيرات الأذكار ومواقيت الصلاة',
                value: _enableNotifications,
                onChanged: _setNotificationsEnabled,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'الأذان',
            Icons.mosque_rounded,
          ),
          const SizedBox(height: 10),
          _buildAdhanCard(context, selectedSound),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'البيانات',
            Icons.storage_rounded,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            [
              _buildActionTile(
                context: context,
                icon: Icons.delete_sweep_rounded,
                iconColor: _danger,
                title: 'إعادة تعيين البيانات',
                subtitle: 'حذف العدادات والإشارات المرجعية والإعدادات',
                onTap: _showResetDialog,
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'التواصل والدعم',
            Icons.support_agent_rounded,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            [
              _buildActionTile(
                context: context,
                icon: Icons.email_rounded,
                iconColor: _gold,
                title: 'تواصل معنا',
                subtitle: 'appnest.studio01@gmail.com',
                onTap: _contactUs,
              ),
              _buildActionTile(
                context: context,
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'مشاركة التطبيق',
                subtitle: 'مشاركة التطبيق عبر تطبيقات الهاتف',
                onTap: _shareApp,
              ),
              _buildActionTile(
                context: context,
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFC107),
                title: 'تقييم التطبيق',
                subtitle: 'ساعدنا بتقييم التطبيق',
                onTap: _rateApp,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'عن التطبيق',
            Icons.info_outline_rounded,
          ),
          const SizedBox(height: 10),
          _buildAboutCard(context),
          const SizedBox(height: 30),
          _buildFooter(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLoggedIn = _userEmail?.trim().isNotEmpty ?? false;
    final rawName = isLoggedIn ? _userEmail!.split('@').first : 'زائرنا الكريم';

    final displayName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1)
        : rawName;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [_darkGreen, Color(0xFF2A4A3D)]
              : [scheme.primary, scheme.primary.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_gold, Color(0xFFB8860B)],
                  ),
                  border: Border.all(
                    color: _lightGold,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isLoggedIn
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  color: _darkBackground,
                  size: 31,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? 'مرحباً بك، $displayName' : 'زائرنا الكريم',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: _gold,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isLoggedIn
                          ? 'شكراً لاستخدامك تطبيق تسبيحة'
                          : 'يمكنك تسجيل الدخول لحفظ حسابك',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(height: 3),
                      Text(
                        _userEmail!,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: _gold.withValues(alpha: 0.3),
            height: 1,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: isLoggedIn
                ? OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _danger,
                      side: const BorderSide(color: _danger),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? _gold
        : scheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: titleColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: _gold.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    List<Widget> children,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.88 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _gold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconContainer(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: scheme.onSurface.withValues(alpha: 0.62),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _gold,
            activeTrackColor: _gold.withValues(alpha: 0.35),
            inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanCard(
    BuildContext context,
    AdhanSoundOption selectedSound,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = _playingSoundId == selectedSound.id && _isPlayingPreview;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _gold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildIconContainer(Icons.mosque_rounded, _gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صوت الأذان',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: scheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تشغيل الأذان عند دخول وقت الصلاة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: scheme.onSurface.withValues(alpha: 0.62),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enableAdhan,
                  onChanged: _setAdhanEnabled,
                  activeThumbColor: _gold,
                  activeTrackColor: _gold.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: _gold.withValues(alpha: 0.18),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.library_music_rounded,
                      color: _gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الصوت المستخدم',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: _gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!_enableSounds)
                      const Icon(
                        Icons.volume_off_rounded,
                        color: _danger,
                        size: 19,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _enableAdhan
                      ? () {
                          setState(() {
                            _isAdhanDropdownOpen = !_isAdhanDropdownOpen;
                          });
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _enableAdhan
                          ? _gold.withValues(alpha: isDark ? 0.05 : 0.08)
                          : scheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            selectedSound.icon,
                            color: _gold,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedSound.name,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: scheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                selectedSound.subtitle,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.62),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isAdhanDropdownOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _gold,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isAdhanDropdownOpen && _enableAdhan) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF10251E) : scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      children:
                          _adhanSounds.map(_buildDropdownSoundItem).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _enableAdhan && _enableSounds
                        ? () => _previewSound(selectedSound)
                        : null,
                    icon: Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      isPlaying ? 'إيقاف التجربة' : 'تجربة الصوت',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _gold,
                      side: BorderSide(
                        color: _gold.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSoundItem(AdhanSoundOption sound) {
    final scheme = Theme.of(context).colorScheme;
    final selected = sound.id == _selectedSoundId;
    final playing = sound.id == _playingSoundId && _isPlayingPreview;

    return InkWell(
      onTap: () => _selectAdhanSound(sound),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: selected ? _gold.withValues(alpha: 0.10) : Colors.transparent,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  selected ? _gold : scheme.onSurface.withValues(alpha: 0.35),
              size: 21,
            ),
            const SizedBox(width: 10),
            Icon(
              sound.icon,
              color:
                  selected ? _gold : scheme.onSurface.withValues(alpha: 0.65),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.name,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: selected ? _gold : scheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sound.subtitle,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: scheme.onSurface.withValues(alpha: 0.62),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: playing ? 'إيقاف' : 'تجربة',
              onPressed: _enableSounds ? () => _previewSound(sound) : null,
              icon: Icon(
                playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color:
                    playing ? _gold : scheme.onSurface.withValues(alpha: 0.62),
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildIconContainer(
              icon,
              isDestructive ? _danger : iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: isDestructive ? _danger : scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: scheme.onSurface.withValues(alpha: 0.62),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: scheme.onSurface.withValues(alpha: 0.35),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [_darkGreen, Color(0xFF2A4A3D)]
              : [scheme.primary, scheme.primary.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_gold, Color(0xFFB8860B)],
              ),
              border: Border.all(
                color: _lightGold,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: _darkBackground,
              size: 38,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'تطبيق التسبيح',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: _gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'رفيقك الهادئ للعبادة اليومية',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              color: _mutedDark,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: _gold.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 14),
          Text(
            'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأدعية، '
            'مواقيت الصلاة، اتجاه القبلة، والرقية الشرعية في تصميم أنيق وسهل الاستخدام.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              color: Colors.white,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                Icons.code_rounded,
                'الإصدار',
                '1.5.6',
              ),
              _buildInfoItem(
                Icons.calendar_today_rounded,
                'التحديث',
                'أغسطس 2026',
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: _gold.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildIconContainer(
                Icons.developer_mode_rounded,
                _gold,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تطوير وتصميم',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: _mutedDark,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'محمد مطر',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: _gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AppNest Studio',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: _mutedDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: _gold,
          size: 21,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Amiri',
            color: _mutedDark,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Amiri',
            color: _gold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 35,
              height: 1,
              color: _gold.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.star_rounded,
              color: _gold,
              size: 14,
            ),
            const SizedBox(width: 8),
            Container(
              width: 35,
              height: 1,
              color: _gold.withValues(alpha: 0.35),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          'صُنع بـ ❤️ لخدمة الإسلام والمسلمين',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Theme.of(context).brightness == Brightness.dark
                ? _mutedDark
                : scheme.onSurface.withValues(alpha: 0.60),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 AppNest Studio - جميع الحقوق محفوظة',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Theme.of(context).brightness == Brightness.dark
                ? _mutedDark
                : scheme.onSurface.withValues(alpha: 0.50),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showMessage(
    String message, {
    IconData icon = Icons.check_circle_outline_rounded,
    Color? backgroundColor,
  }) {
    if (!mounted) return;

    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: _gold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: scheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? scheme.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
            ),
          ),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}

class AdhanSoundOption {
  final String id;
  final String name;
  final String subtitle;
  final String asset;
  final IconData icon;

  const AdhanSoundOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.asset,
    required this.icon,
  });
}
