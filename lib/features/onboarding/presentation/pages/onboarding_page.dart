import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../home/presentation/pages/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _usernameController = TextEditingController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _onStartPressed() async {
    if (_usernameController.text.trim().isNotEmpty) {
      HapticFeedback.lightImpact();

      try {
        final databaseHelper = getIt<DatabaseHelper>();
        final userName = _usernameController.text.trim();

        // Kullanıcıyı veritabanına kaydet
        final userId = await databaseHelper.createUser(userName);

        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userName);
        await prefs.setInt('user_id', userId);

        if (mounted) {
          // Ana sayfaya geçiş
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(
                username: _usernameController.text.trim(),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error saving user name: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kullanıcı adı kaydedilemedi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen bir kullanıcı adı girin'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  _OnboardingMainPage(
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    scaleAnimation: _scaleAnimation,
                  ),
                  _OnboardingInfoPage(
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    scaleAnimation: _scaleAnimation,
                  ),
                  _OnboardingSignUpPage(
                    usernameController: _usernameController,
                    onStart: _onStartPressed,
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    scaleAnimation: _scaleAnimation,
                  ),
                ],
              ),
            ),
            // Dots
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getVerticalPadding(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3, (index) => _buildDot(index == _currentPage)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isSmallScreen(context) ? 3 : 4),
      width: isActive ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6D79EC) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF6D79EC).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

// 1. Sayfa: Ana tanıtım - Çok daha kaliteli
class _OnboardingMainPage extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;

  const _OnboardingMainPage({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ana illüstrasyon - Orijinal görsel
          FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D79EC).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size(300, 250),
                  painter: const OnboardingIllustrationPainter(),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getVerticalPadding(context) * 2),
          // Başlık - Çok daha güzel tipografi
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getHorizontalPadding(context)),
                child: Text(
                  'Öğrenmek Hiç Bu Kadar\nEğlenceli Olmadı',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isSmallScreen(context)
                        ? 24
                        : (ResponsiveHelper.isMediumScreen(context) ? 28 : 32),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
          // Açıklama - Daha güzel spacing
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveHelper.getHorizontalPadding(context) * 1.2),
                child: Text(
                  'Favori konularında kendini test et, puanları topla ve liderlik tablosunda yüksel. Her gün yeni bir macera seni bekliyor!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937).withOpacity(0.8),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Sayfa: Bilgi sayfası - Çok daha renkli ve çekici
class _OnboardingInfoPage extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;

  const _OnboardingInfoPage({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ana icon container - Çok daha renkli
          FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF059669),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 32 : 40),
          // Başlık
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Text(
                'Her Gün Yeni Bir Şey Öğren!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getHeaderFontSize(context) * 1.2,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
          // Özellikler listesi - Çok daha detaylı
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                padding: ResponsiveHelper.getContentPadding(context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.quiz_rounded,
                      title: 'Günlük Mini Quizler',
                      description: 'Her gün yeni sorularla kendini test et',
                      color: const Color(0xFF6D79EC),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Puanlar ve Ödüller',
                      description: 'Başarılarını ödüllerle kutla',
                      color: const Color(0xFFF59E0B),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.leaderboard_rounded,
                      title: 'Liderlik Tablosu',
                      description: 'Arkadaşlarınla yarış ve yüksel',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
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
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 1 : 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1F2937).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 3. Sayfa: Kayıt formu - Çok daha şık
class _OnboardingSignUpPage extends StatelessWidget {
  final TextEditingController usernameController;
  final VoidCallback onStart;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;

  const _OnboardingSignUpPage({
    required this.usernameController,
    required this.onStart,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başlık
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Text(
                'Topluluğumuza Katıl!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isSmallScreen(context)
                      ? 26
                      : (ResponsiveHelper.isMediumScreen(context) ? 29 : 32),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                  letterSpacing: -0.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
          // Alt başlık
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Text(
                'Kullanıcı adını gir ve öğrenme yolculuğuna başla!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937).withOpacity(0.8),
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getVerticalPadding(context) * 2),
          // Kullanıcı adı input'u - Çok daha şık
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D79EC).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Kullanıcı Adı',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF6D79EC),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getHorizontalPadding(context) * 1.2,
                      vertical:
                          ResponsiveHelper.isSmallScreen(context) ? 14 : 18,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF6D79EC),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onStart(),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getVerticalPadding(context) * 1.3),
          // Hemen Başla butonu - Çok daha modern
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6D79EC),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D79EC).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hemen Başla',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          width:
                              ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: Colors.white,
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
}

// Mevcut illustration painter
class OnboardingIllustrationPainter extends CustomPainter {
  const OnboardingIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = const Color(0xFFE5E7EB);
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );
    canvas.drawRRect(backgroundRect, paint);
    paint.color = const Color(0xFF6D79EC);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );
    paint.color = const Color(0xFF1F2937);
    final trianglePath = Path()
      ..moveTo(120, 185)
      ..lineTo(180, 185)
      ..lineTo(170, 165)
      ..lineTo(130, 165)
      ..close();
    canvas.drawPath(trianglePath, paint);
    paint.color = const Color(0xFF10B981);
    canvas.drawCircle(
      const Offset(130, 100),
      10,
      paint,
    );
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    paint.style = PaintingStyle.stroke;
    final arrowPath = Path()
      ..moveTo(170, 95)
      ..lineTo(175, 100)
      ..lineTo(170, 105);
    canvas.drawPath(arrowPath, paint);
    paint.color = const Color(0xFF6D79EC);
    paint.style = PaintingStyle.fill;
    final blueRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(180, 80, 40, 15),
      const Radius.circular(7.5),
    );
    canvas.drawRRect(blueRect, paint);
    paint.color = const Color(0xFF10B981);
    final greenRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(80, 130, 40, 15),
      const Radius.circular(7.5),
    );
    canvas.drawRRect(greenRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
