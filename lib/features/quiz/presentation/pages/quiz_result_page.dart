import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/admob_service.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'quiz_review_page.dart';

class QuizResultPage extends StatefulWidget {
  final String subjectName;
  final String testName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int score;
  final List<Question> questions;
  final List<int> userAnswers;

  const QuizResultPage({
    super.key,
    required this.subjectName,
    required this.testName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animasyonları sırayla başlat
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    // Test tamamlandığında reklam göster
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        AdMobService.showInterstitialAd();
      }
    });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getContentPadding(context),
          child: Column(
            children: [
              // Header - Geri butonu
              FadeTransition(
                opacity: _fadeController,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF6D79EC),
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                        width:
                            ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                    Text(
                      'Quiz Tamamlandı!',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context) + 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                  height: ResponsiveHelper.isSmallScreen(context) ? 16 : 20),

              // Ana içerik
              Expanded(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Başarı ikonu
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.elasticOut,
                          )),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),

                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 12
                                : 16),

                        // Tebrik mesajı
                        Text(
                          'Tebrikler!',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getHeaderFontSize(context),
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),

                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 4
                                : 6),

                        Text(
                          '${widget.subjectName} quizini başarıyla tamamladın!',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getSubheaderFontSize(context),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 16
                                : 20),

                        // Doğru/Toplam kartı
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.isSmallScreen(context)
                                  ? 10
                                  : 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981).withOpacity(0.1),
                                const Color(0xFF059669).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.correctAnswers}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  Text(
                                    ' / ',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    '${widget.totalQuestions}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Doğru Cevap',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 12
                                : 16),

                        // Başarı yüzdesi
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isSmallScreen(context)
                                ? 10
                                : 14,
                            vertical:
                                ResponsiveHelper.isSmallScreen(context) ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Başarı Oranı: ${widget.totalQuestions > 0 ? ((widget.correctAnswers / widget.totalQuestions) * 100).round() : 0}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Butonlar
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    children: [
                      // Cevapları göster butonu
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      QuizReviewPage(
                                subjectName: widget.subjectName,
                                testName: widget.testName,
                                questions: widget.questions,
                                userAnswers: widget.userAnswers,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getHorizontalPadding(context) *
                                    1.2,
                            vertical: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Cevapları Göster',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(
                          height:
                              ResponsiveHelper.isSmallScreen(context) ? 8 : 10),

                      // Tekrar oyna butonu
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getHorizontalPadding(context) *
                                    1.2,
                            vertical: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6D79EC),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6D79EC).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Tekrar Oyna',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(
                          height:
                              ResponsiveHelper.isSmallScreen(context) ? 8 : 10),

                      // Ana sayfaya dön butonu
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getHorizontalPadding(context) *
                                    1.2,
                            vertical: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Ana Sayfaya Dön',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
