import 'package:flutter/material.dart';

import '../data/duas_data.dart';
import 'dua_detail_screen.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const gold = Color(0xFFD4AF37);

    final mutedGold =
        isDark ? const Color(0xFFC9B896) : const Color(0xFF8A6A18);

    final card = theme.colorScheme.surface;
    final text = theme.colorScheme.onSurface;
    final secondary =
        theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'الأدعية المأثورة',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: mutedGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: mutedGold,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_rounded,
              color: mutedGold,
            ),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(
              'موسوعة شاملة للأدعية من القرآن والسنة',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: secondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allDuasCategories.length,
        itemBuilder: (context, index) {
          final category = allDuasCategories[index];

          return Card(
            color: card,
            elevation: isDark ? 0 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: mutedGold.withValues(alpha: 0.45),
              ),
            ),
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B342B)
                        : const Color(0xFFE8F0EC),
                    border: Border(
                      bottom: BorderSide(
                        color: mutedGold.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: isDark
                                ? const Color(0xFFF0E0B5)
                                : const Color(0xFF345447),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${category.duas.length}',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: isDark
                                ? gold
                                : const Color(0xFF7A5C10),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...category.duas.map(
                  (dua) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DuaDetailScreen(
                              title: dua.title,
                              content: dua.arabic,
                              virtue: dua.virtue,
                              repeatCount: dua.repeatCount,
                              source: dua.source,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  mutedGold.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    gold.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: mutedGold,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dua.title,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: isDark
                                          ? const Color(
                                              0xFFF0E0B5,
                                            )
                                          : text,
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        color: gold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'التكرار: ${dua.repeatCount}',
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          color: isDark
                                              ? gold
                                              : const Color(
                                                  0xFF7A5C10,
                                                ),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: secondary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          dua.source,
                                          style: TextStyle(
                                            fontFamily:
                                                'Amiri',
                                            color: secondary,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: mutedGold,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}