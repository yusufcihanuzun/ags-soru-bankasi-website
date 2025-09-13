import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'quiz_page.dart';

class QuizSelectionPage extends StatefulWidget {
  final String subjectName;
  final String subjectDescription;

  const QuizSelectionPage({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
  });

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

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
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                padding: ResponsiveHelper.getContentPadding(context),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB).withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
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
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF7081EB),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.subjectName,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getHeaderFontSize(context),
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.isSmallScreen(context)
                            ? 32
                            : 40), // Balance için
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: ResponsiveHelper.getContentPadding(context),
                  child: Column(
                    children: [
                      // Description
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Text(
                          widget.subjectDescription,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getVerticalPadding(context)),

                      // Quiz List
                      Expanded(
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: ListView(
                            children: [
                              _buildQuizItem(
                                title: 'Kolay Seviye',
                                duration: '5 min',
                                difficulty: 'Easy',
                                difficultyColor: const Color(0xFF48BB78),
                                onTap: () => _onQuizSelected('Kolay'),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              _buildQuizItem(
                                title: 'Orta Seviye',
                                duration: '10 min',
                                difficulty: 'Medium',
                                difficultyColor: const Color(0xFFF6E05E),
                                textColor: const Color(0xFF4A5568),
                                onTap: () => _onQuizSelected('Orta'),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 8
                                          : 12),
                              _buildQuizItem(
                                title: 'Zor Seviye',
                                duration: '15 min',
                                difficulty: 'Hard',
                                difficultyColor: const Color(0xFFF56565),
                                onTap: () => _onQuizSelected('Zor'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizItem({
    required String title,
    required String duration,
    required String difficulty,
    required Color difficultyColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Difficulty Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isSmallScreen(context) ? 6 : 8,
                  vertical: ResponsiveHelper.isSmallScreen(context) ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getSubheaderFontSize(context) * 0.8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.isSmallScreen(context) ? 3 : 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: const Color(0xFF4A5568),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.isSmallScreen(context)
                                ? 3
                                : 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getSubheaderFontSize(context),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF7081EB),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQuizSelected(String difficulty) {
    // Bu sayfa artık kullanılmıyor, veritabanı tabanlı sisteme geçildi
    // Bu metodu güncelleyerek testId ve testName parametrelerini kullanacak şekilde değiştiriyoruz
    // Şimdilik basit bir test ID'si kullanıyoruz
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizPage(
          subjectName: widget.subjectName,
          testId: 1, // Geçici test ID
          testName: difficulty, // difficulty'yi testName olarak kullanıyoruz
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
