import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MafatehScreen extends StatefulWidget {
  const MafatehScreen({Key? key}) : super(key: key);

  @override
  State<MafatehScreen> createState() => _MafatehScreenState();
}

class _MafatehScreenState extends State<MafatehScreen> {
  final List<int> _counters = [];

  // ===== القسم الأول: مفاتيح الفرج الأساسية =====
  final List<Map<String, dynamic>> _mainKeys = [
    {
      'title': '- الفاتحة',
      'content':
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَٰنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (7)',
      'target': 1,
      'reference': 'سورة الفاتحة',
    },
    {
      'title': '٢- الله الله ربي',
      'content': 'اللَّهُ اللَّهُ رَبِّي لَا أُشْرِكُ بِهِ شَيْئًا',
      'target': 1,
      'reference': 'رواه أبو داود',
    },
    {
      'title': '٣- لا إله إلا أنت',
      'content':
          'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'target': 1,
      'reference': 'سورة الأنبياء - آية 87',
    },
    {
      'title': '٤- حسبنا الله ونعم الوكيل',
      'content': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'target': 1,
      'reference': 'رواه البخاري',
    },
    {
      'title': '- لا حول ولا قوة إلا بالله',
      'content':
          'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      'target': 1,
      'reference': 'متفق عليه',
    },
    {
      'title': '- أستغفر الله العظيم',
      'content':
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
      'target': 1,
      'reference': 'رواه أبو داود والترمذي',
    },
    {
      'title': '٧- لا إله إلا الله العظيم الحليم',
      'content':
          'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَالْأَرْضِ رَبُّ الْعَرْشِ الْكَرِيمِ',
      'target': 1,
      'reference': 'متفق عليه',
    },
    {
      'title': '٨- اللهم إني أعوذ بك من الهم والحزن',
      'content':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
      'target': 1,
      'reference': 'رواه البخاري',
    },
    {
      'title': '٩- يا حي يا قيوم',
      'content':
          'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      'target': 1,
      'reference': 'رواه الحاكم',
    },
    {
      'title': '١٠- اللهم رحمتك أرجو',
      'content':
          'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      'target': 1,
      'reference': 'رواه أبو داود',
    },
    {
      'title': '١١- حسبنا الله سيؤتينا الله من فضله',
      'content':
          'حَسْبُنَا اللَّهُ سَيُؤْتِينَا اللَّهُ مِنْ فَضْلِهِ إِنَّا إِلَى اللَّهِ لَرَاغِبُونَ',
      'target': 1,
      'reference': 'سورة التوبة - آية 59',
    },
    {
      'title': '١٢- ربي إني لما أنزلت إلي من خير فقير',
      'content': 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      'target': 1,
      'reference': 'سورة القصص - آية 24',
    },
  ];

  // ===== القسم الثاني: أذكار تُقال 3 مرات =====
  final List<Map<String, dynamic>> _threeTimesDhikr = [
    {
      'title': 'ولم أكن بدعائك رب شقياً',
      'content': 'وَلَمْ أَكُنْ بِدُعَائِكَ رَبِّ شَقِيًّا',
      'target': 3,
      'reference': 'سورة طه - آية 74',
    },
    {
      'title': 'اللهم إنك عفو تحب العفو فاعف عنا',
      'content': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنَّا',
      'target': 3,
      'reference': 'رواه الترمذي',
    },
    {
      'title': 'حسبي الله لا إله إلا هو',
      'content':
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      'target': 3,
      'reference': 'سورة التوبة - آية 129',
    },
    {
      'title': 'سبحان الله وبحمده عدد خلقه',
      'content':
          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
      'target': 3,
      'reference': 'رواه مسلم',
    },
    {
      'title': 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
      'content':
          'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'target': 3,
      'reference': 'دعوة ذي النون',
    },
    {
      'title': 'لا إله إلا الله وحده لا شريك له',
      'content':
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'target': 3,
      'reference': 'متفق عليه',
    },
    {
      'title': 'اللهم صل على سيدنا محمد',
      'content':
          'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ فِي كُلِّ وَقْتٍ وَحِينٍ',
      'target': 3,
      'reference': 'الصلاة على النبي',
    },
    {
      'title': 'يا حي يا قيوم برحمتك أستغيث',
      'content':
          'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      'target': 3,
      'reference': 'رواه الحاكم',
    },
    {
      'title': 'لا حول ولا قوة إلا بالله',
      'content':
          'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      'target': 3,
      'reference': 'متفق عليه',
    },
    {
      'title': 'أستغفر الله الذي لا إله إلا هو',
      'content':
          'أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
      'target': 3,
      'reference': 'رواه أبو داود',
    },
    {
      'title': 'سورة الإخلاص',
      'content':
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ (1) اللَّهُ الصَّمَدُ (2) لَمْ يَلِدْ وَلَمْ يُولَدْ (3) وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ (4)',
      'target': 3,
      'reference': 'سورة الإخلاص',
    },
    {
      'title': 'اللهم أرني عجائب قدرتك',
      'content':
          'اللَّهُمَّ أَرِنِي عَجَائِبَ قُدْرَتِكَ فِي تَحْقِيقِ مَا أَتَمَنَّى',
      'target': 3,
      'reference': 'دعاء الفرج',
    },
    {
      'title': 'اللهم ارزقني بما لا أعرف كيف أطلبه منك',
      'content':
          'اللَّهُمَّ ارْزُقْنِي بِمَا لَا أَعْرِفُ كَيْفَ أَطْلُبُهُ مِنْكَ، فَأَنْتَ أَعْلَمُ بِمَا تَحْتَاجُهُ نَفْسِي',
      'target': 3,
      'reference': 'دعاء الرزق',
    },
    {
      'title': 'سبحان الله وبحمده سبحان الله العظيم',
      'content': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'target': 3,
      'reference': 'متفق عليه',
    },
  ];

  @override
  void initState() {
    super.initState();
    final totalItems = _mainKeys.length + _threeTimesDhikr.length;
    _counters.addAll(List.filled(totalItems, 0));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final totalItems = _mainKeys.length + _threeTimesDhikr.length;
      for (int i = 0; i < totalItems; i++) {
        _counters[i] = prefs.getInt('mafateh_$i') ?? 0;
      }
    });
  }

  Future<void> _saveProgress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mafateh_$index', _counters[index]);
  }

  void _increment(int index) {
    final allItems = [..._mainKeys, ..._threeTimesDhikr];
    final target = allItems[index]['target'] as int;
    setState(() {
      if (_counters[index] < target) {
        _counters[index]++;
      }
    });
    _saveProgress(index);
    HapticFeedback.lightImpact();
  }

  void _reset(int index) {
    setState(() {
      _counters[index] = 0;
    });
    _saveProgress(index);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'مفاتيح الفرج',
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
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== عنوان القسم الأول =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.vpn_key,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'مفاتيح الفرج الأساسية',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== مفاتيح الفرج الأساسية =====
            ...List.generate(_mainKeys.length, (index) {
              return _buildDhikrCard(index, _mainKeys[index], _counters[index]);
            }),

            const SizedBox(height: 20),

            // ===== عنوان القسم الثاني =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.repeat, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'أذكار تُقال 3 مرات',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== أذكار تُقال 3 مرات =====
            ...List.generate(_threeTimesDhikr.length, (index) {
              final globalIndex = _mainKeys.length + index;
              return _buildDhikrCard(
                globalIndex,
                _threeTimesDhikr[index],
                _counters[globalIndex],
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCard(
      int index, Map<String, dynamic> item, int currentCount) {
    final targetCount = item['target'] as int;
    final isCompleted = currentCount >= targetCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.15),
            const Color(0xFFB8860B).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50)
              : const Color(0xFFD4AF37).withOpacity(0.5),
          width: isCompleted ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.vpn_key,
                    color: Color(0xFFD4AF37), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 19,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFD4AF37).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isCompleted ? '✓ تم' : '$currentCount / $targetCount',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFD4AF37), thickness: 1),
          const SizedBox(height: 12),
          Text(
            item['content'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: Colors.white,
              height: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['reference'] as String,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      color: Color(0xFFD4AF37),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!isCompleted)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _increment(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'اضغط للعد',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _reset(index),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
