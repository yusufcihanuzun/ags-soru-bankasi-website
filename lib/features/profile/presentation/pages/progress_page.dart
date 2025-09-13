import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'profile_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  // İstatistikler
  int totalTests = 0;
  int totalQuestions = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  int totalPoints = 0;
  int currentLevel = 1;
  bool isLoading = true;
  String username = 'Kullanıcı';
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> categoryProgress = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final databaseHelper = getIt<DatabaseHelper>();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;
      final userName = prefs.getString('user_name') ?? 'Kullanıcı';

      final stats = await databaseHelper.getUserStats(userId);
      final activities =
          await databaseHelper.getRecentActivities(userId, limit: 3);
      final categories = await databaseHelper.getCategoryProgress(userId);

      if (mounted) {
        setState(() {
          username = userName;
          totalTests = stats['total_tests'] as int;
          totalQuestions = stats['total_questions'] as int;
          totalCorrect = stats['total_correct'] as int;
          totalWrong = stats['total_wrong'] as int;
          totalPoints = totalCorrect * 25; // Her doğru cevap 25 puan
          currentLevel =
              (totalPoints / 100).floor() + 1; // Her 100 puan 1 level
          recentActivities = activities;
          categoryProgress = categories;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user stats: $e');
      if (mounted) {
        setState(() {
          totalTests = 0;
          totalQuestions = 0;
          totalCorrect = 0;
          totalWrong = 0;
          totalPoints = 0;
          currentLevel = 1;
          recentActivities = [];
          categoryProgress = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveHelper.getHorizontalPadding(context) * 1.2,
                      ResponsiveHelper.getVerticalPadding(context),
                      ResponsiveHelper.getHorizontalPadding(context) * 1.2,
                      ResponsiveHelper.getVerticalPadding(context) * 0.8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFF6D79EC).withOpacity(0.03),
                          const Color(0xFF8B5CF6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D79EC).withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            width: ResponsiveHelper.isSmallScreen(context)
                                ? 30
                                : 40), // Sol boşluk
                        Expanded(
                          child: Text(
                            'İlerleme',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.getHeaderFontSize(context),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6D79EC),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.isSmallScreen(context)
                                ? 30
                                : 40), // Sağ boşluk
                      ],
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getContentPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall Progress Section
                        FadeTransition(
                          opacity: _fadeController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genel İlerleme',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getHeaderFontSize(
                                          context) *
                                      0.75,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D131C),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      totalTests.toString(),
                                      'Tamamlanan Quiz',
                                      const Color(0xFF6D79EC),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 8
                                          : 12),
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      totalPoints.toString(),
                                      'Kazanılan Puan',
                                      const Color(0xFF6D79EC),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 8
                                          : 12),
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      currentLevel.toString(),
                                      'Seviye',
                                      const Color(0xFF6D79EC),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      totalQuestions.toString(),
                                      'Toplam Soru',
                                      const Color(0xFF3B82F6),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 8
                                          : 12),
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      totalCorrect.toString(),
                                      'Doğru Cevap',
                                      const Color(0xFF10B981),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 8
                                          : 12),
                                  Expanded(
                                    child: _buildOverallProgressCard(
                                      totalWrong.toString(),
                                      'Yanlış Cevap',
                                      const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context)),

                        // Category Progress Section
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kategori İlerlemesi',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getHeaderFontSize(
                                          context) *
                                      0.75,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D131C),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              ...categoryProgress.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildCategoryProgressCard(
                                    category['subject_name'],
                                    _getCategoryIcon(category['subject_name']),
                                    _getCategoryColor(category['subject_name']),
                                    (category['progress'] as double),
                                    category['completed_tests'],
                                    category['total_tests'],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context)),

                        // Streaks & Milestones Section
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Başarılar ve Kilometre Taşları',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getHeaderFontSize(
                                          context) *
                                      0.75,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D131C),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              _buildStreakCard(
                                '3-Günlük Seri',
                                Icons.local_fire_department_rounded,
                                Colors.orange,
                                '🔥',
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              _buildStreakCard(
                                'Rozet: Quiz Ustası',
                                Icons.emoji_events_rounded,
                                Colors.amber,
                                '🏆',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context)),

                        // Recent Activity Section
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.elasticOut,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son Aktiviteler',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getHeaderFontSize(
                                          context) *
                                      0.75,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D131C),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              ...recentActivities.isEmpty
                                  ? [
                                      Container(
                                        width: double.infinity,
                                        padding:
                                            ResponsiveHelper.getContentPadding(
                                                context),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.quiz_outlined,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                            SizedBox(
                                                height: ResponsiveHelper
                                                        .isSmallScreen(context)
                                                    ? 8
                                                    : 12),
                                            Text(
                                              'Henüz test çözmediniz',
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper
                                                    .getBodyFontSize(context),
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            SizedBox(
                                                height: ResponsiveHelper
                                                        .isSmallScreen(context)
                                                    ? 3
                                                    : 4),
                                            Text(
                                              'İlk testinizi çözdükten sonra burada görünecek',
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper
                                                    .getSubheaderFontSize(
                                                        context),
                                                color: Colors.grey.shade500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  : recentActivities.map((activity) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildRecentActivityCard(
                                          '${activity['subject_name']} - ${activity['topic_name']} (${activity['test_order']}. Test)',
                                          '${activity['correct_answers']}/${activity['total_questions']}',
                                          _formatDate(activity['completed_at']),
                                          _getActivityIcon(
                                              activity['correct_answers'],
                                              activity['total_questions']),
                                          _getActivityColor(
                                              activity['correct_answers'],
                                              activity['total_questions']),
                                        ),
                                      );
                                    }).toList(),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 80
                                : 100), // Nav bar için boşluk
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Nav Bar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFF6D79EC).withOpacity(0.03),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D79EC).withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Ana Sayfa
                      _buildFloatingNavItem(
                        icon: Icons.home_rounded,
                        isActive: false,
                        isPrimary: false,
                        onTap: () {
                          // Ana sayfaya smooth animasyonla dön
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      HomePage(username: username),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // Merkeze doğru scale + fade animasyonu
                                const curve = Curves.easeInOutCubic;

                                var scaleAnimation = animation.drive(
                                  Tween<double>(begin: 0.8, end: 1.0).chain(
                                    CurveTween(curve: curve),
                                  ),
                                );

                                var fadeAnimation = animation.drive(
                                  Tween<double>(begin: 0.0, end: 1.0).chain(
                                    CurveTween(curve: Curves.easeIn),
                                  ),
                                );

                                var slideAnimation = animation.drive(
                                  Tween<Offset>(
                                          begin: const Offset(0.0, -0.3),
                                          end: Offset.zero)
                                      .chain(
                                    CurveTween(curve: curve),
                                  ),
                                );

                                return SlideTransition(
                                  position: slideAnimation,
                                  child: ScaleTransition(
                                    scale: scaleAnimation,
                                    child: FadeTransition(
                                      opacity: fadeAnimation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                            (route) => false, // Tüm route'ları temizle
                          );
                        },
                      ),
                      // Profil
                      _buildFloatingNavItem(
                        icon: Icons.person_rounded,
                        isActive: false,
                        isPrimary: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ProfilePage(username: username),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // Soldan sağa slide animasyonu
                                const begin = Offset(-1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutCubic;

                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );

                                var offsetAnimation = animation.drive(tween);

                                // Fade effect de ekleyelim
                                var fadeAnimation = animation.drive(
                                  Tween<double>(begin: 0.0, end: 1.0).chain(
                                    CurveTween(curve: Curves.easeIn),
                                  ),
                                );

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: fadeAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      // İlerleme (Aktif)
                      _buildFloatingNavItem(
                        icon: Icons.trending_up_rounded,
                        isActive: true,
                        isPrimary: true,
                        onTap: () {
                          // Zaten progress sayfasında, hiçbir şey yapma
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(String value, String label, Color color) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.isSmallScreen(context)
                  ? 26
                  : (ResponsiveHelper.isMediumScreen(context) ? 29 : 32),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 3 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getSubheaderFontSize(context) * 0.85,
              color: const Color(0xFF49699C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Kategori ikonu ve rengi belirle (ana sayfayla aynı)
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'tarih':
        return Icons.history_edu_rounded;
      case 'coğrafya':
        return Icons.public_rounded;
      case 'eğitim':
        return Icons.school_rounded;
      case 'mevzuat':
        return Icons.gavel_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'tarih':
        return const Color(0xFF10B981); // Yeşil
      case 'coğrafya':
        return const Color(0xFF3B82F6); // Mavi
      case 'eğitim':
        return const Color(0xFFF59E0B); // Turuncu
      case 'mevzuat':
        return const Color(0xFFEF4444); // Kırmızı
      default:
        return const Color(0xFF6D79EC); // Varsayılan mor
    }
  }

  Widget _buildCategoryProgressCard(String category, IconData icon,
      Color categoryColor, double progress, int completed, int total) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: categoryColor,
              size: 24,
            ),
          ),
          SizedBox(width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D131C),
                  ),
                ),
                Text(
                  '$completed/$total test tamamlandı',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getSubheaderFontSize(context) * 0.85,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7ECF4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: ResponsiveHelper.getSubheaderFontSize(context),
              fontWeight: FontWeight.w600,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı methodlar
  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Bugün';
      } else if (difference.inDays == 1) {
        return 'Dün';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Bilinmeyen tarih';
    }
  }

  IconData _getActivityIcon(int correct, int total) {
    final percentage = (correct / total) * 100;
    if (percentage >= 80) {
      return Icons.check_circle_rounded;
    } else if (percentage >= 60) {
      return Icons.check_circle_outline_rounded;
    } else {
      return Icons.cancel_rounded;
    }
  }

  Color _getActivityColor(int correct, int total) {
    final percentage = (correct / total) * 100;
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildStreakCard(
      String title, IconData icon, Color iconColor, String emoji) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0D131C),
              ),
            ),
          ),
          Text(
            emoji,
            style: TextStyle(
                fontSize: ResponsiveHelper.getHeaderFontSize(context) * 0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(
      String title, String score, String date, IconData icon, Color iconColor) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D131C),
                  ),
                ),
                Text(
                  'Skor: $score',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                    color: const Color(0xFF49699C),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getSubheaderFontSize(context) * 0.85,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isPrimary ? 48 : 40,
        height: isPrimary ? 48 : 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : isActive
                  ? const Color(0xFF6D79EC).withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(isPrimary ? 24 : 20),
          border: isPrimary
              ? Border.all(
                  color: const Color(0xFF6D79EC).withOpacity(0.1),
                  width: 1,
                )
              : isActive
                  ? Border.all(
                      color: const Color(0xFF6D79EC).withOpacity(0.2),
                      width: 1,
                    )
                  : null,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF6D79EC).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isPrimary ? 24 : 20,
          color: isPrimary
              ? const Color(0xFF6D79EC)
              : isActive
                  ? const Color(0xFF6D79EC)
                  : const Color(0xFF6D79EC).withOpacity(0.4),
        ),
      ),
    );
  }
}
