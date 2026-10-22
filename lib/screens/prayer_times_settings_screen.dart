import 'package:flutter/material.dart';

import '../models/prayer_settings_model.dart';
import '../services/prayer_settings_service.dart';
import '../services/prayer_notification_service.dart';

class PrayerTimesSettingsScreen extends StatefulWidget {
  final PrayerSettings initialSettings;
  final Function(PrayerSettings) onSettingsSaved;

  const PrayerTimesSettingsScreen({
    super.key,
    required this.initialSettings,
    required this.onSettingsSaved,
  });

  @override
  State<PrayerTimesSettingsScreen> createState() =>
      _PrayerTimesSettingsScreenState();
}

class _PrayerTimesSettingsScreenState extends State<PrayerTimesSettingsScreen>
    with SingleTickerProviderStateMixin {
  late PrayerSettings _currentSettings;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.initialSettings;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ========================================
  // حفظ الإعدادات
  // ========================================

  Future<void> _saveSettings() async {
    final bool saved = await PrayerSettingsService.savePrayerSettings(
      _currentSettings,
    );

    if (!saved) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ إعدادات الصلاة'),
          backgroundColor: Color(0xFFE8837C),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // إعادة جدولة إشعارات الصلاة فورًا حتى تستخدم الإعدادات الجديدة.
    try {
      await PrayerNotificationService.schedulePrayerNotifications();
    } catch (e) {
      debugPrint('تعذر إعادة جدولة إشعارات الصلاة بعد الحفظ: $e');
    }

    widget.onSettingsSaved(_currentSettings);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إعدادات الصلاة وإعادة جدولة التنبيهات ✅'),
        backgroundColor: Color(0xFF22C55E),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: const Text(
          'إعدادات مواقيت الصلاة',
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
      body: Column(
        children: [
          // ================================
          // التبويبات
          // ================================

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B342B),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: const Color(0xFFD4AF37),
              labelColor: const Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: '📍 الموقع', icon: Icon(Icons.location_on)),
                Tab(text: '🕌 المذهب', icon: Icon(Icons.book)),
                Tab(text: '⏰ الجهة', icon: Icon(Icons.business)),
                Tab(text: '⚙️ التعديل', icon: Icon(Icons.tune)),
              ],
            ),
          ),

          // ================================
          // محتوى التبويبات
          // ================================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ========== تبويب الموقع ==========
                _buildLocationTab(),

                // ========== تبويب المذهب ==========
                _buildSchoolTab(),

                // ========== تبويب الجهة ==========
                _buildAuthorityTab(),

                // ========== تبويب التعديل ==========
                _buildAdjustmentTab(),
              ],
            ),
          ),

          // ================================
          // زر الحفظ
          // ================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0A201A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حفظ الإعدادات',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // تبويب الموقع (اختيار الدول والمدن)
  // ================================================================

  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ================================
        // اختيار الدولة
        // ================================

        _buildSectionTitle('اختر الدولة'),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF162447).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<ArabCountry>(
            isExpanded: true,
            value: _currentSettings.selectedCountry,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1B342B),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: Colors.white,
            ),
            items: ArabCountry.values.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country.label),
              );
            }).toList(),
            onChanged: (newCountry) {
              if (newCountry != null) {
                final cities = arabCitiesByCountry[newCountry] ?? [];
                if (cities.isNotEmpty) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(
                      selectedCountry: newCountry,
                      selectedCity: cities[0],
                      selectedAuthority:
                          PrayerSettingsService.defaultAuthorityForCountry(
                        newCountry,
                      ),
                    );
                  });
                }
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // ================================
        // اختيار المدينة
        // ================================
        _buildSectionTitle('اختر المدينة'),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF162447).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<CityInfo>(
            isExpanded: true,
            value: _currentSettings.selectedCity,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1B342B),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: Colors.white,
            ),
            items: (arabCitiesByCountry[_currentSettings.selectedCountry] ?? [])
                .map((city) {
              return DropdownMenuItem(value: city, child: Text(city.name));
            }).toList(),
            onChanged: (newCity) {
              if (newCity != null) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(
                    selectedCity: newCity,
                  );
                });
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // ================================
        // معلومات الموقع
        // ================================
        _buildInfoCard(
          title: 'معلومات الموقع المختار',
          children: [
            _buildInfoRow('الدولة', _currentSettings.selectedCountry.label),
            _buildInfoRow('المدينة', _currentSettings.selectedCity.name),
            _buildInfoRow(
              'خط العرض',
              _currentSettings.selectedCity.latitude.toStringAsFixed(4),
            ),
            _buildInfoRow(
              'خط الطول',
              _currentSettings.selectedCity.longitude.toStringAsFixed(4),
            ),
            _buildInfoRow(
              'فارق التوقيت',
              'UTC + ${(_currentSettings.selectedCity.timeZoneOffset / 60).toStringAsFixed(0)} ساعات',
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // تبويب المذهب الفقهي
  // ================================================================

  Widget _buildSchoolTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('اختر المذهب الفقهي'),
        const SizedBox(height: 16),
        ...IslamicSchool.values.map((school) {
          final isSelected = _currentSettings.selectedSchool == school;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentSettings = _currentSettings.copyWith(
                  selectedSchool: school,
                );
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                    : const Color(0xFF162447).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF0A201A),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      school.label,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color:
                            isSelected ? const Color(0xFFD4AF37) : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        _buildInfoCard(
          title: 'حول المذهب المختار',
          children: [
            Text(
              _getSchoolDescription(_currentSettings.selectedSchool),
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // تبويب جهة الاعتماد
  // ================================================================

  Widget _buildAuthorityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('اختر جهة الاعتماد'),
        const SizedBox(height: 16),
        ...PrayerAuthority.values.map((authority) {
          final isSelected = _currentSettings.selectedAuthority == authority;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentSettings = _currentSettings.copyWith(
                  selectedAuthority: authority,
                );
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                    : const Color(0xFF162447).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF0A201A),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authority.label,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authority.country,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ================================================================
  // تبويب التعديل على الأوقات
  // ================================================================

  Widget _buildAdjustmentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('تعديل أوقات الصلاة'),
        const SizedBox(height: 16),

        _buildAdjustmentSlider(
          title: '🌅 الفجر',
          value: _currentSettings.fajrAdjustmentMinutes.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                fajrAdjustmentMinutes: value.toInt(),
              );
            });
          },
        ),

        const SizedBox(height: 20),

        _buildAdjustmentSlider(
          title: '🌤️ الظهر',
          value: _currentSettings.dhuhrAdjustmentMinutes.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                dhuhrAdjustmentMinutes: value.toInt(),
              );
            });
          },
        ),

        const SizedBox(height: 20),

        _buildAdjustmentSlider(
          title: '☁️ العصر',
          value: _currentSettings.asrAdjustmentMinutes.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                asrAdjustmentMinutes: value.toInt(),
              );
            });
          },
        ),

        const SizedBox(height: 20),

        _buildAdjustmentSlider(
          title: '🌅 المغرب',
          value: _currentSettings.maghribAdjustmentMinutes.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                maghribAdjustmentMinutes: value.toInt(),
              );
            });
          },
        ),

        const SizedBox(height: 20),

        _buildAdjustmentSlider(
          title: '🌙 العشاء',
          value: _currentSettings.ishaAdjustmentMinutes.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                ishaAdjustmentMinutes: value.toInt(),
              );
            });
          },
        ),

        const SizedBox(height: 24),

        // ================================
        // التوقيت الصيفي
        // ================================
        _buildSectionTitle('التوقيت الصيفي'),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF162447).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تفعيل التوقيت الصيفي',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _currentSettings.isDaylightSavingEnabled,
                onChanged: (value) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(
                      isDaylightSavingEnabled: value,
                    );
                  });
                },
                activeColor: const Color(0xFFD4AF37),
                activeTrackColor:
                    const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            ),
          ),
          child: const Text(
            'ℹ️ عند تفعيل التوقيت الصيفي، يتم إضافة ساعة واحدة إلى جميع أوقات الصلاة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // دوال مساعدة
  // ================================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 18,
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B342B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSlider({
    required String title,
    required double value,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162447).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()} دقائق',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: -30,
            max: 30,
            divisions: 60,
            activeColor: const Color(0xFFD4AF37),
            inactiveColor: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _getSchoolDescription(IslamicSchool school) {
    switch (school) {
      case IslamicSchool.hanafi:
        return 'المذهب الحنفي: يتبع الآراء الاجتهادية للإمام أبي حنيفة، وهو المذهب الأكثر اتباعاً في العالم الإسلامي.';

      case IslamicSchool.maliki:
        return 'المذهب المالكي: يتبع آراء الإمام مالك بن أنس، وينتشر في المغرب العربي والأندلس.';

      case IslamicSchool.shafi:
        return 'المذهب الشافعي: يتبع آراء الإمام محمد بن إدريس الشافعي، وينتشر في الشام والجزيرة العربية وآسيا الصغرى.';

      case IslamicSchool.hanbali:
        return 'المذهب الحنبلي: يتبع آراء الإمام أحمد بن حنبل، وهو المذهب السائد في المملكة العربية السعودية.';
    }
  }
}
