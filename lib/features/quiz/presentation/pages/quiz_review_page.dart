import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/question.dart';
import '../../../../core/utils/responsive_helper.dart';

class QuizReviewPage extends StatefulWidget {
  final String subjectName;
  final String testName;
  final List<Question> questions;
  final List<int> userAnswers;

  const QuizReviewPage({
    super.key,
    required this.subjectName,
    required this.testName,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    // Debug bilgisi
    print('📊 QuizReviewPage - Sorular sayısı: ${widget.questions.length}');
    print(
        '📊 QuizReviewPage - UserAnswers sayısı: ${widget.userAnswers.length}');
    print(
        '📊 QuizReviewPage - İlk soru: ${widget.questions.isNotEmpty ? widget.questions.first.questionText : "Soru yok"}');

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
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC).withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: ResponsiveHelper.getContentPadding(context),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                color: Color(0xFF6D79EC),
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Cevapları İncele',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getHeaderFontSize(
                                        context) *
                                    0.75,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                              width: ResponsiveHelper.isSmallScreen(context)
                                  ? 30
                                  : 40), // Balance için
                        ],
                      ),
                    ),
                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.questions.isNotEmpty
                            ? 0.4
                            : 0.0, // Güvenli progress
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
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
                  child: widget.questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 64,
                                color: const Color(0xFF6D79EC).withOpacity(0.5),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 12
                                          : 16),
                              Text(
                                'Soru bulunamadı',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getHeaderFontSize(
                                          context) *
                                      0.75,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 6
                                          : 8),
                              Text(
                                'Sorular yüklenirken bir hata oluştu',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getSubheaderFontSize(
                                          context),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: ResponsiveHelper.getContentPadding(context),
                          itemCount: widget.questions.length,
                          itemBuilder: (context, index) {
                            return _buildQuestionCard(index);
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = widget.questions[index];
    final userAnswer = widget.userAnswers[index];

    // Doğru cevabı veritabanı formatından al
    final correctAnswerStr = question.correctAnswer;
    int correctAnswerIndex;
    switch (correctAnswerStr.toLowerCase()) {
      case 'a':
        correctAnswerIndex = 0;
        break;
      case 'b':
        correctAnswerIndex = 1;
        break;
      case 'c':
        correctAnswerIndex = 2;
        break;
      default:
        correctAnswerIndex = 0;
    }

    final isCorrect = userAnswer == correctAnswerIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soru numarası ve soru
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D79EC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6D79EC),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),

            // Kullanıcının cevabı
            Text(
              userAnswer >= 0 ? 'Senin cevabın:' : 'Cevap verilmedi:',
              style: TextStyle(
                fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),

            SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallScreen(context) ? 8 : 12),
              decoration: BoxDecoration(
                color: userAnswer < 0
                    ? const Color(0xFF6B7280).withOpacity(0.1)
                    : isCorrect
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: userAnswer < 0
                      ? const Color(0xFF6B7280).withOpacity(0.3)
                      : isCorrect
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getOptionText(question, userAnswer),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        fontWeight: FontWeight.w600,
                        color: userAnswer < 0
                            ? const Color(0xFF6B7280)
                            : isCorrect
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  Icon(
                    userAnswer < 0
                        ? Icons.help_outline
                        : isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                    color: userAnswer < 0
                        ? const Color(0xFF6B7280)
                        : isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                    size: 20,
                  ),
                ],
              ),
            ),

            // Yanlış cevap verildiyse doğru cevabı göster
            if (!isCorrect) ...[
              SizedBox(
                  height: ResponsiveHelper.isSmallScreen(context) ? 8 : 12),
              Text(
                'Doğru cevap:',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                    ResponsiveHelper.isSmallScreen(context) ? 8 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getOptionText(question, correctAnswerIndex),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getOptionText(Question question, int optionIndex) {
    // Eğer optionIndex geçersizse veya -1 ise (cevapsız)
    if (optionIndex < 0 || optionIndex > 2) {
      return 'Cevap verilmedi';
    }

    switch (optionIndex) {
      case 0:
        return question.optionA;
      case 1:
        return question.optionB;
      case 2:
        return question.optionC;
      default:
        return 'Cevap verilmedi';
    }
  }
}
