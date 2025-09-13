import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/question_service.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final String subjectName;
  final int testId;
  final String testName;

  const QuizPage({
    super.key,
    required this.subjectName,
    required this.testId,
    required this.testName,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  bool isAnswered = false;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  List<int> userAnswers = [];
  List<Question> questions = [];
  bool isLoading = true;
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
    _loadQuestions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        isLoading = true;
      });

      print('📚 Sorular yükleniyor... Test ID: ${widget.testId}');

      // JSON'dan yüklenen soruları al (hızlı SQLite sorgusu)
      final questionsData =
          await QuestionService.getQuestionsByTestId(widget.testId);

      print('📊 Yüklenen soru sayısı: ${questionsData.length}');

      if (mounted) {
        setState(() {
          questions = questionsData;
          // UserAnswers listini sorular boyutunda başlat (-1 = cevapsız)
          userAnswers = List.filled(questions.length, -1);
          isLoading = false;
        });

        print('✅ Sorular başarıyla yüklendi! Toplam: ${questions.length} soru');
      }
    } catch (e) {
      print('❌ Sorular yüklenirken hata: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Kullanıcıya hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorular yüklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6D79EC),
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: ResponsiveHelper.getIconSize(context, defaultSize: 64),
                  color: const Color(0xFF6D79EC),
                ),
                SizedBox(
                    height: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                Text(
                  'Bu test için henüz soru bulunmuyor',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getHeaderFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                Text(
                  'Lütfen daha sonra tekrar deneyin',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getContentPadding(context),
          child: Column(
            children: [
              // Progress Bar
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (currentQuestionIndex + 1) / questions.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D79EC),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                    Text(
                      'Soru ${currentQuestionIndex + 1} / ${questions.length}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getSubheaderFontSize(context),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                  height: ResponsiveHelper.getVerticalPadding(context) * 1.3),

              // Question and Answers with Scroll
              Expanded(
                child: SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Soru metni ve bildirim butonu
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  questions[currentQuestionIndex].questionText,
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.isSmallScreen(context)
                                            ? 20
                                            : (ResponsiveHelper.isMediumScreen(
                                                    context)
                                                ? 24
                                                : 28),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              // Bildirim butonu
                              GestureDetector(
                                onTap: () => _showReportDialog(context),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    ResponsiveHelper.isSmallScreen(context)
                                        ? 8
                                        : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.report_problem_outlined,
                                    size: ResponsiveHelper.getIconSize(context,
                                        defaultSize: 20),
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  ResponsiveHelper.getVerticalPadding(context) *
                                      1.3),
                          // Answer Options
                          _buildAnswerOption(
                              0, questions[currentQuestionIndex].optionA),
                          SizedBox(
                              height: ResponsiveHelper.isSmallScreen(context)
                                  ? 8
                                  : 12),
                          _buildAnswerOption(
                              1, questions[currentQuestionIndex].optionB),
                          SizedBox(
                              height: ResponsiveHelper.isSmallScreen(context)
                                  ? 8
                                  : 12),
                          _buildAnswerOption(
                              2, questions[currentQuestionIndex].optionC),

                          // Banner Reklam - şıkların altında, scroll içinde
                          SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context),
                          ),
                          Padding(
                            padding: ResponsiveHelper.getBannerPadding(context),
                            child: const Center(
                              child: BannerAdWidget(
                                adType: 'quiz',
                                // Responsive boyut otomatik olarak belirlenir
                              ),
                            ),
                          ),
                          // Banner altı boşluk
                          SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context),
                          ),

                          // Next Button - scroll içinde
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _onNextPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveHelper
                                                .getHorizontalPadding(context) *
                                            1.6,
                                        vertical:
                                            ResponsiveHelper.isSmallScreen(
                                                    context)
                                                ? 8
                                                : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6D79EC),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6D79EC)
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        currentQuestionIndex ==
                                                questions.length - 1
                                            ? 'Bitir'
                                            : 'Sonraki',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getBodyFontSize(
                                                  context),
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Alt boşluk - güvenli alan için
                          SizedBox(
                            height:
                                ResponsiveHelper.getVerticalPadding(context) *
                                    2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(int index, String optionText) {
    final isSelected = selectedAnswerIndex == index;
    final correctAnswer = questions[currentQuestionIndex].correctAnswer;
    final isCorrect = (correctAnswer == 'a' && index == 0) ||
        (correctAnswer == 'b' && index == 1) ||
        (correctAnswer == 'c' && index == 2);
    final isWrong = isSelected && !isCorrect;

    Color borderColor = const Color(0xFFE5E7EB);
    Color backgroundColor = Colors.white;
    Color textColor = const Color(0xFF1F2937);

    if (isAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF10B981);
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF10B981);
      } else if (isWrong) {
        borderColor = const Color(0xFFFCA5A5);
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF6D79EC);
      backgroundColor = const Color(0xFFF3F4F6);
    }

    return GestureDetector(
      onTap: () {
        if (!isAnswered) {
          HapticFeedback.lightImpact();
          setState(() {
            selectedAnswerIndex = index;
            isAnswered = true;

            // Kullanıcı cevabını kaydet
            userAnswers[currentQuestionIndex] = index;

            // Doğru/yanlış sayısını güncelle
            final correctAnswer = questions[currentQuestionIndex].correctAnswer;
            final isCorrect = (correctAnswer == 'a' && index == 0) ||
                (correctAnswer == 'b' && index == 1) ||
                (correctAnswer == 'c' && index == 2);
            if (isCorrect) {
              correctAnswers++;
            } else {
              wrongAnswers++;
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding:
            EdgeInsets.all(ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, defaultRadius: 16)),
          border: Border.all(
            color: borderColor,
            width: isAnswered && (isCorrect || isWrong) ? 2 : 1,
          ),
        ),
        child: Text(
          optionText,
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            fontWeight: isAnswered && (isCorrect || isWrong)
                ? FontWeight.w600
                : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (selectedAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen bir cevap seçin'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = -1;
        isAnswered = false;
      });

      // Animasyonları yeniden başlat
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    } else {
      // Quiz bitti - Sonuçları veritabanına kaydet
      _saveQuizResult();
    }
  }

  Future<void> _saveQuizResult() async {
    try {
      final databaseHelper = getIt<DatabaseHelper>();
      int score = correctAnswers * 20; // Her doğru cevap 20 puan

      // Kullanıcı ID'sini SharedPreferences'dan al
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;

      // Test sonucunu veritabanına kaydet
      await databaseHelper.saveTestResult(
        testId: widget.testId,
        userId: userId,
        score: score,
        totalQuestions: questions.length,
        correctAnswers: correctAnswers,
        wrongAnswers: questions.length - correctAnswers, // Yanlış cevap sayısı
        timeTaken: null, // Şimdilik null
      );

      // Sonuç sayfasına git
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuizResultPage(
            subjectName: widget.subjectName,
            testName: widget.testName,
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            score: score,
            questions: questions,
            userAnswers: userAnswers,
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
    } catch (e) {
      print('Error saving quiz result: $e');
      // Hata durumunda da sonuç sayfasına git
      int score = correctAnswers * 20;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuizResultPage(
            subjectName: widget.subjectName,
            testName: widget.testName,
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            score: score,
            questions: questions,
            userAnswers: userAnswers,
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

  // Soru bildirimi dialog'u
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: const Color(0xFFF59E0B),
                size: ResponsiveHelper.getIconSize(context, defaultSize: 24),
              ),
              SizedBox(
                  width: ResponsiveHelper.getHorizontalPadding(context) * 0.5),
              Expanded(
                child: Text(
                  'Soruyu Bildir',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getHeaderFontSize(context),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu soruda bir hata mı var? Lütfen sorunun ne olduğunu belirtin:',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
              _buildReportOption(
                context,
                'Yanlış cevap',
                'Doğru cevap yanlış işaretlenmiş',
                Icons.check_circle_outline,
              ),
              SizedBox(height: 8),
              _buildReportOption(
                context,
                'Belirsiz soru',
                'Soru net değil veya belirsiz',
                Icons.help_outline,
              ),
              SizedBox(height: 8),
              _buildReportOption(
                context,
                'Yazım hatası',
                'Soru veya seçeneklerde yazım hatası var',
                Icons.edit_outlined,
              ),
              SizedBox(height: 8),
              _buildReportOption(
                context,
                'Diğer',
                'Başka bir sorun var',
                Icons.more_horiz,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showReportSuccess(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Bildir',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        // Seçilen seçeneği işle
        Navigator.of(context).pop();
        _showReportSuccess(context);
      },
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.getIconSize(context, defaultSize: 20),
              color: const Color(0xFF6B7280),
            ),
            SizedBox(
                width: ResponsiveHelper.getHorizontalPadding(context) * 0.5),
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
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, defaultSize: 20),
            ),
            SizedBox(
                width: ResponsiveHelper.getHorizontalPadding(context) * 0.5),
            Expanded(
              child: Text(
                'Soru bildirimi alındı. Teşekkürler!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
