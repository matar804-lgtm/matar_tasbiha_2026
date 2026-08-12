import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class DuaDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String virtue;
  final int repeatCount;
  final String source;

  const DuaDetailScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.virtue,
    required this.repeatCount,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            color: Color(0xFFC9B896),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFC9B896)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Color(0xFFC9B896)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ الدعاء',
                      style: TextStyle(fontFamily: 'Amiri')),
                  backgroundColor: Color(0xFF1B342B),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFC9B896)),
            onPressed: () {
              Share.share(
                '$title\n\n$content\n\n($source)',
                subject: title,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ===== الختم المائي =====
          Positioned.fill(
            child: Center(
              child: Transform.rotate(
                angle: -0.2,
                child: Text(
                  'بسم الله',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.03),
                    fontSize: 80,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // ===== المحتوى الرئيسي =====
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== بطاقة العنوان =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B342B),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFC9B896).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFC9B896).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFFC9B896), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFF0E0B5),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ===== بطاقة الفضل =====
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFD4AF37), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الفضل:',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: Color(0xFFD4AF37),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              virtue,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                color: Color(0xFFF0E0B5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ===== بطاقة عدد التكرار =====
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A22),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFC9B896).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFC9B896).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.repeat_rounded,
                            color: Color(0xFFC9B896), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'عدد التكرار المستحب:',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: Color(0xFF9AB09F),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$repeatCount ${repeatCount == 1 ? 'مرة' : repeatCount == 2 ? 'مرتان' : repeatCount == 3 ? 'مرات' : 'مرة'}',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                color: Color(0xFFF0E0B5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$repeatCount',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFD4AF37),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ===== بطاقة محتوى الدعاء =====
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC9B896).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 40,
                              height: 1,
                              color: const Color(0xFFC9B896)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFC9B896), size: 14),
                          const SizedBox(width: 8),
                          Container(
                              width: 40,
                              height: 1,
                              color: const Color(0xFFC9B896)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFFF0E0B5),
                          fontSize: 22,
                          height: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 40,
                              height: 1,
                              color: const Color(0xFFC9B896)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFC9B896), size: 14),
                          const SizedBox(width: 8),
                          Container(
                              width: 40,
                              height: 1,
                              color: const Color(0xFFC9B896)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ===== بطاقة المصدر =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B342B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC9B896).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.book_rounded,
                          color: Color(0xFFC9B896), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'المصدر: $source',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFF9AB09F),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ===== زر النسخ الكبير =====
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم نسخ الدعاء بنجاح',
                            style: TextStyle(fontFamily: 'Amiri')),
                        backgroundColor: Color(0xFF1B342B),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEAD79F), Color(0xFFC9A86A)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_rounded,
                            color: Color(0xFF2C1E08), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'نسخ الدعاء',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFF2C1E08),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
