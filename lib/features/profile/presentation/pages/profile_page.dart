import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  // İstatistikler
  int totalTests = 0;
  int totalQuestions = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  int allTestsInDB = 0;
  bool isLoading = true;

  // Performans için cache'lenen değerler
  late String _successPercentage;

  @override
  void initState() {
    super.initState();
    // String işlemlerini cache'le
    _updateCachedValues();

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

  void _updateCachedValues() {
    _successPercentage = totalQuestions > 0
        ? '${((totalCorrect / totalQuestions) * 100).round()}%'
        : '0%';
  }

  // didChangeDependencies kaldırıldı - gereksiz rebuild'leri önlemek için

  Future<void> _loadUserStats() async {
    try {
      final databaseHelper = getIt<DatabaseHelper>();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1; // Varsayılan olarak 1

      final stats = await databaseHelper.getUserStats(userId);

      if (mounted) {
        setState(() {
          totalTests = stats['total_tests'] as int;
          totalQuestions = stats['total_questions'] as int;
          totalCorrect = stats['total_correct'] as int;
          totalWrong = stats['total_wrong'] as int;
          allTestsInDB = stats['all_tests_in_db'] as int;
          isLoading = false;
        });
        _updateCachedValues();
      }
    } catch (e) {
      print('Error loading user stats: $e');
      // Hata durumunda varsayılan değerler
      if (mounted) {
        setState(() {
          totalTests = 0;
          totalQuestions = 0;
          totalCorrect = 0;
          totalWrong = 0;
          allTestsInDB = 0;
          isLoading = false;
        });
        _updateCachedValues();
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

  Future<void> _onLogoutPressed() async {
    HapticFeedback.lightImpact();

    // SharedPreferences'dan kullanıcı verilerini temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_id');

    // Ana sayfaya dön
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ana sayfadaki arka plan rengi
      body: Stack(
        children: [
          Column(
            children: [
              // Sticky Header
              Container(
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
                child: SafeArea(
                  child: Padding(
                    padding: ResponsiveHelper.getHeaderPadding(context),
                    child: Row(
                      children: [
                        SizedBox(
                            width: ResponsiveHelper.isSmallScreen(context)
                                ? 36
                                : 48), // Spacer
                        Expanded(
                          child: Text(
                            'Profil',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.getHeaderFontSize(context),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6D79EC),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SettingsPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOutCubic;
                                  var tween =
                                      Tween(begin: begin, end: end).chain(
                                    CurveTween(curve: curve),
                                  );
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                                ResponsiveHelper.isSmallScreen(context)
                                    ? 6
                                    : 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Color(0xFF7081EB),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context)),

                      // Profile Info Section
                      FadeTransition(
                        opacity: _fadeController,
                        child: Center(
                          child: Text(
                            widget.username,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.isSmallScreen(context)
                                  ? 24
                                  : (ResponsiveHelper.isMediumScreen(context)
                                      ? 28
                                      : 32),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F131A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context) *
                              1.3),

                      // Stats Grid
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModernStatCard(
                                totalTests.toString(),
                                'Quiz Çözüldü',
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveHelper.isSmallScreen(context)
                                    ? 8
                                    : 12),
                            Expanded(
                              child: _buildModernStatCard(
                                _successPercentage,
                                'Ortalama Skor',
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveHelper.isSmallScreen(context)
                                    ? 8
                                    : 12),
                            Expanded(
                              child: _buildModernStatCard(
                                '${(totalTests / 10).ceil()}', // Simple badge calculation
                                'Rozetler',
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context)),

                      // Progress Section
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
                              'İlerleme',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getHeaderFontSize(
                                        context) *
                                    0.75,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F131A),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveHelper.isSmallScreen(context)
                                    ? 12
                                    : 16),
                            Container(
                              padding:
                                  ResponsiveHelper.getContentPadding(context),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF6D79EC).withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6D79EC)
                                        .withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Test İlerlemesi',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getBodyFontSize(
                                                  context),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0F131A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 8
                                          : 12),
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: allTestsInDB > 0
                                          ? (totalTests / allTestsInDB)
                                              .clamp(0.0, 1.0)
                                          : 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF10B981),
                                              const Color(0xFF059669),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 6
                                          : 8),
                                  Text(
                                    '$totalTests/${allTestsInDB > 0 ? allTestsInDB : 1} Test Tamamlandı',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.getSubheaderFontSize(
                                              context),
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context)),

                      // Account Section
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
                              'Hesap',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getHeaderFontSize(
                                        context) *
                                    0.75,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F131A),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveHelper.isSmallScreen(context)
                                    ? 12
                                    : 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF6D79EC).withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6D79EC)
                                        .withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildAccountMenuItem(
                                    Icons.settings_rounded,
                                    'Ayarlar',
                                    () {
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SettingsPage(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOutCubic;
                                            var tween =
                                                Tween(begin: begin, end: end)
                                                    .chain(
                                              CurveTween(curve: curve),
                                            );
                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(
                                      color: const Color(0xFFE2E8F0),
                                      height: 1),
                                  _buildAccountMenuItem(
                                    Icons.notifications_rounded,
                                    'Bildirimler',
                                    () {
                                      HapticFeedback.lightImpact();
                                      // Notifications action
                                    },
                                  ),
                                  Divider(
                                      color: const Color(0xFFE2E8F0),
                                      height: 1),
                                  _buildAccountMenuItem(
                                    Icons.feedback_rounded,
                                    'Geri Bildirim',
                                    () {
                                      HapticFeedback.lightImpact();
                                      // Feedback action
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context)),

                      // Logout Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getHorizontalPadding(context),
                            vertical: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFEF4444),
                                const Color(0xFFDC2626),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _onLogoutPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 12
                                          : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(
                                    width:
                                        ResponsiveHelper.isSmallScreen(context)
                                            ? 6
                                            : 8),
                                Text(
                                  'Çıkış Yap',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getBodyFontSize(
                                        context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      HomePage(username: widget.username),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // Soldan sağa slide + scale animasyonu
                                const curve = Curves.easeInOutCubic;

                                var slideAnimation = animation.drive(
                                  Tween<Offset>(
                                          begin: const Offset(-1.0, 0.0),
                                          end: Offset.zero)
                                      .chain(
                                    CurveTween(curve: curve),
                                  ),
                                );

                                var scaleAnimation = animation.drive(
                                  Tween<double>(begin: 0.9, end: 1.0).chain(
                                    CurveTween(curve: curve),
                                  ),
                                );

                                var fadeAnimation = animation.drive(
                                  Tween<double>(begin: 0.0, end: 1.0).chain(
                                    CurveTween(curve: Curves.easeIn),
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
                      // Profil (Aktif)
                      _buildFloatingNavItem(
                        icon: Icons.person_rounded,
                        isActive: true,
                        isPrimary: true,
                        onTap: () {
                          // Zaten profil sayfasında, hiçbir şey yapma
                        },
                      ),
                      // İlerleme (Progress)
                      _buildFloatingNavItem(
                        icon: Icons.trending_up_rounded,
                        isActive: false,
                        isPrimary: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ProgressPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // Sağdan sola slide animasyonu
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutCubic;

                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );

                                var offsetAnimation = animation.drive(tween);

                                // Scale effect de ekleyelim
                                var scaleAnimation = animation.drive(
                                  Tween<double>(begin: 0.95, end: 1.0).chain(
                                    CurveTween(curve: Curves.easeOut),
                                  ),
                                );

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: ScaleTransition(
                                    scale: scaleAnimation,
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

  Widget _buildModernStatCard(String value, String label) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6D79EC).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D79EC).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.isSmallScreen(context)
                  ? 22
                  : (ResponsiveHelper.isMediumScreen(context) ? 25 : 28),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D79EC),
            ),
          ),
          SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getSubheaderFontSize(context),
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenuItem(
      IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6D79EC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6D79EC),
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
                  color: const Color(0xFF0F131A),
                ),
              ),
            ),
          ],
        ),
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
