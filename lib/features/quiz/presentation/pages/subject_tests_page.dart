import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'quiz_page.dart';

class SubjectTestsPage extends StatefulWidget {
  final String subjectName;
  final String topicName;
  final int topicId;

  const SubjectTestsPage({
    super.key,
    required this.subjectName,
    required this.topicName,
    required this.topicId,
  });

  @override
  State<SubjectTestsPage> createState() => _SubjectTestsPageState();
}

class _SubjectTestsPageState extends State<SubjectTestsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  List<Map<String, dynamic>> _tests = [];
  Set<int> _completedTestIds = {};
  Map<int, int> _testCompletionCounts = {};
  bool _isLoading = true;

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
    _loadTests();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    try {
      final databaseHelper = getIt<DatabaseHelper>();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;

      final tests = await databaseHelper.getTestsByTopic(widget.topicId);
      final completedTests = await databaseHelper.getCompletedTestIds(userId);
      final completionCounts =
          await databaseHelper.getTestCompletionCounts(userId);

      setState(() {
        _tests = tests;
        _completedTestIds = completedTests;
        _testCompletionCounts = completionCounts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tests: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                      child: Column(
                        children: [
                          Text(
                            widget.topicName,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.getHeaderFontSize(context) *
                                      0.75,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.subjectName,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getSubheaderFontSize(
                                  context),
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A5568),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        width:
                            ResponsiveHelper.isSmallScreen(context) ? 30 : 40),
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
                          '${widget.topicName} konusuna ait testleri seçin',
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

                      // Tests List
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF7081EB),
                                ),
                              )
                            : SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _slideController,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: ListView.builder(
                                  itemCount: _tests.length,
                                  itemBuilder: (context, index) {
                                    final test = _tests[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildTestItem(
                                        title: test['name'],
                                        description: test['description'] ?? '',
                                        questionCount: test['question_count'],
                                        isCompleted: _completedTestIds
                                            .contains(test['id']),
                                        completionCount:
                                            _testCompletionCounts[test['id']] ??
                                                0,
                                        onTap: () => _onTestSelected(test),
                                      ),
                                    );
                                  },
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

  Widget _buildTestItem({
    required String title,
    required String description,
    required int questionCount,
    required bool isCompleted,
    required int completionCount,
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
          padding:
              EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Question Count Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.isSmallScreen(context) ? 6 : 8,
                      vertical: ResponsiveHelper.isSmallScreen(context) ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7081EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$questionCount Soru',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getSubheaderFontSize(context) *
                                0.8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Completion Count Badge (only if completed)
                  if (isCompleted && completionCount > 0) ...[
                    SizedBox(
                        width: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveHelper.isSmallScreen(context) ? 4 : 6,
                          vertical:
                              ResponsiveHelper.isSmallScreen(context) ? 1 : 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${completionCount}x',
                        style: TextStyle(
                          fontSize:
                              ResponsiveHelper.getSubheaderFontSize(context) *
                                  0.7,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Completion Status
                  if (isCompleted)
                    Container(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.isSmallScreen(context) ? 3 : 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFF7081EB),
                      size: 20,
                    ),
                ],
              ),
              SizedBox(
                  height: ResponsiveHelper.isSmallScreen(context) ? 8 : 12),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getHeaderFontSize(context) * 0.75,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 3 : 4),
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTestSelected(Map<String, dynamic> test) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizPage(
          subjectName: widget.subjectName,
          testId: test['id'],
          testName: test['name'],
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
