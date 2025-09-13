import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../quiz/presentation/pages/subject_topics_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/progress_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _scaleController.forward();
    _loadSubjects();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ResponsiveHelper kullanarak responsive değerleri al
    final isExtraSmallScreen = ResponsiveHelper.isExtraSmallScreen(context);
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isMediumScreen = ResponsiveHelper.isMediumScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header - Responsive Tasarım
                FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    padding: ResponsiveHelper.getHeaderPadding(context),
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
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                            ResponsiveHelper.getBorderRadius(context,
                                defaultRadius: 24)),
                        bottomRight: Radius.circular(
                            ResponsiveHelper.getBorderRadius(context,
                                defaultRadius: 24)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D79EC).withOpacity(0.08),
                          blurRadius:
                              ResponsiveHelper.isSmallScreen(context) ? 12 : 15,
                          offset: Offset(0,
                              ResponsiveHelper.isSmallScreen(context) ? 4 : 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sol taraf - Merhaba mesajı
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getHeaderFontSize(
                                            context),
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Merhaba, ',
                                      style: TextStyle(
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.username,
                                      style: TextStyle(
                                        color: const Color(0xFF6D79EC),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? 3
                                          : 4),
                              Text(
                                'Bugün ne öğrenmek istersin?',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getSubheaderFontSize(
                                          context),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sağ taraf - Modern bildirim ikonu
                        Container(
                          width: isExtraSmallScreen
                              ? 32
                              : (isSmallScreen ? 36 : 44),
                          height: isExtraSmallScreen
                              ? 32
                              : (isSmallScreen ? 36 : 44),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF6D79EC).withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF6D79EC).withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: const Color(0xFF6D79EC),
                                  size: isExtraSmallScreen
                                      ? 16
                                      : (isSmallScreen ? 18 : 22),
                                ),
                              ),
                              // Bildirim badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626)
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
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
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),

                // Search Bar - Çok daha modern
                FadeTransition(
                  opacity: _fadeController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getHorizontalPadding(context)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: isExtraSmallScreen
                              ? 'Ara...'
                              : 'Konular veya testler ara...',
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Container(
                            margin: EdgeInsets.all(isExtraSmallScreen
                                ? 6
                                : (isSmallScreen ? 8 : 12)),
                            padding: EdgeInsets.all(isExtraSmallScreen
                                ? 4
                                : (isSmallScreen ? 6 : 8)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6D79EC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF6D79EC),
                              size: isExtraSmallScreen
                                  ? 16
                                  : (isSmallScreen ? 18 : 20),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getHorizontalPadding(context),
                            vertical: isExtraSmallScreen
                                ? 10
                                : (isSmallScreen ? 12 : 16),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                ),

                // Arama Altı Banner Reklam
                Padding(
                  padding: ResponsiveHelper.getBannerPadding(context),
                  child: const Center(
                    child: BannerAdWidget(
                      adType: 'home_search',
                      // Responsive boyut otomatik olarak belirlenir
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getContentPadding(context),
                    child: Column(
                      children: [
                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 12),

                        // Konular Grid - Modern tasarım
                        FadeTransition(
                          opacity: _fadeController,
                          child: _isLoading
                              ? Container(
                                  height: 300,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6D79EC),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: isSmallScreen ? 8 : 12,
                                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                                    childAspectRatio: isSmallScreen
                                        ? 1.4
                                        : (isMediumScreen ? 1.5 : 1.6),
                                  ),
                                  itemCount: _subjects.length,
                                  itemBuilder: (context, index) {
                                    final subject = _subjects[index];
                                    return _buildSubjectCard(
                                      title: subject['name'],
                                      subtitle: subject['description'] ?? '',
                                      icon: _getIconData(
                                          subject['icon'] ?? 'school'),
                                      color: _parseColor(
                                          subject['color'] ?? '0xFF6D79EC'),
                                      gradient: [
                                        _parseColor(subject['gradient_start'] ??
                                            '0xFF6D79EC'),
                                        _parseColor(subject['gradient_end'] ??
                                            '0xFF8B5CF6'),
                                      ],
                                    );
                                  },
                                ),
                        ),

                        // Banner Reklam - Navigation bar'ın üzerinde
                        Padding(
                          padding: EdgeInsets.only(
                            top: ResponsiveHelper.getVerticalPadding(context),
                            bottom:
                                ResponsiveHelper.getVerticalPadding(context) *
                                    0.5,
                          ),
                          child: const Center(
                            child: BannerAdWidget(
                              adType: 'home',
                              // Responsive boyut otomatik olarak belirlenir
                            ),
                          ),
                        ),

                        // Alt boşluk nav bar için
                        SizedBox(
                            height: ResponsiveHelper.isSmallScreen(context)
                                ? 8
                                : 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Floating Nav Bar
          Positioned(
            bottom: isSmallScreen ? 12 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: ResponsiveHelper.getNavBarWidth(context),
                height: ResponsiveHelper.getNavBarHeight(context),
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
                        context: context,
                        icon: Icons.home_rounded,
                        isActive: _selectedIndex == 0,
                        isPrimary: _selectedIndex == 0,
                        onTap: () {
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                      // Profil
                      _buildFloatingNavItem(
                        context: context,
                        icon: Icons.person_rounded,
                        isActive: _selectedIndex == 1,
                        isPrimary: _selectedIndex == 1,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ProfilePage(username: widget.username),
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
                          ).then((_) {
                            setState(() => _selectedIndex = 0);
                          });
                        },
                      ),
                      // İlerleme (Progress)
                      _buildFloatingNavItem(
                        context: context,
                        icon: Icons.trending_up_rounded,
                        isActive: _selectedIndex == 2,
                        isPrimary: _selectedIndex == 2,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ProgressPage(),
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
                          ).then((_) {
                            setState(() => _selectedIndex = 0);
                          });
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

  Widget _buildFloatingNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width:
            isPrimary ? (isSmallScreen ? 40 : 48) : (isSmallScreen ? 32 : 40),
        height:
            isPrimary ? (isSmallScreen ? 40 : 48) : (isSmallScreen ? 32 : 40),
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
          size:
              isPrimary ? (isSmallScreen ? 20 : 24) : (isSmallScreen ? 16 : 20),
          color: isPrimary
              ? const Color(0xFF6D79EC)
              : isActive
                  ? const Color(0xFF6D79EC)
                  : const Color(0xFF6D79EC).withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    // Ders başına özel renkler ve ikonlar
    Color cardColor;
    IconData cardIcon;

    switch (title.toLowerCase()) {
      case 'tarih':
        cardColor = const Color(0xFF10B981); // Yeşil
        cardIcon = Icons.history_edu_rounded;
        break;
      case 'coğrafya':
        cardColor = const Color(0xFF3B82F6); // Mavi
        cardIcon = Icons.public_rounded;
        break;
      case 'eğitim':
        cardColor = const Color(0xFFF59E0B); // Turuncu
        cardIcon = Icons.school_rounded;
        break;
      case 'mevzuat':
        cardColor = const Color(0xFFEF4444); // Kırmızı
        cardIcon = Icons.gavel_rounded;
        break;
      default:
        cardColor = color; // Veritabanındaki renk
        cardIcon = icon; // Veritabanındaki ikon
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onSubjectSelected(title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cardIcon,
                    color: cardColor,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubjectSelected(String subjectName) {
    // Seçilen dersi bul
    final selectedSubject = _subjects.firstWhere(
      (subject) => subject['name'] == subjectName,
      orElse: () => {},
    );

    if (selectedSubject.isEmpty) return;

    final subjectId = selectedSubject['id'] as int;
    final description = selectedSubject['description'] as String? ??
        _getSubjectDescription(subjectName);

    // Tüm dersler için aynı konular sayfası
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SubjectTopicsPage(
          subjectName: subjectName,
          subjectDescription: description,
          subjectId: subjectId,
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

  Future<void> _loadSubjects() async {
    try {
      print('Loading subjects from database...');
      final databaseHelper = getIt<DatabaseHelper>();
      final subjects = await databaseHelper.getAllSubjects();
      print('Loaded ${subjects.length} subjects from database');
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading subjects: $e');
      // Fallback to static data
      setState(() {
        _subjects = [
          {
            'id': 1,
            'name': 'Tarih',
            'description':
                'Geçmişi keşfet ve tarihi olaylar, şahsiyetler ve medeniyetler hakkında bilgini test et.',
            'icon': 'history_edu_rounded',
            'color': '0xFF6D79EC',
            'gradient_start': '0xFF6D79EC',
            'gradient_end': '0xFF8B5CF6',
          },
          {
            'id': 2,
            'name': 'Matematik',
            'description':
                'Sayıların dünyasında yolculuk yap ve matematiksel becerilerini geliştir.',
            'icon': 'calculate_rounded',
            'color': '0xFFF59E0B',
            'gradient_start': '0xFFF59E0B',
            'gradient_end': '0xFFD97706',
          },
          {
            'id': 3,
            'name': 'Fizik',
            'description':
                'Evrenin temel kanunlarını öğren ve fiziksel dünyayı anla.',
            'icon': 'science_rounded',
            'color': '0xFF06B6D4',
            'gradient_start': '0xFF06B6D4',
            'gradient_end': '0xFF0891B2',
          },
        ];
        _isLoading = false;
      });
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'history_edu_rounded':
        return Icons.history_edu_rounded;
      case 'calculate_rounded':
        return Icons.calculate_rounded;
      case 'science_rounded':
        return Icons.science_rounded;
      case 'public_rounded':
        return Icons.public_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'music_note_rounded':
        return Icons.music_note_rounded;
      case 'palette_rounded':
        return Icons.palette_rounded;
      case 'sports_soccer_rounded':
        return Icons.sports_soccer_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return const Color(0xFF6D79EC);
    }
  }

  String _getSubjectDescription(String subjectName) {
    switch (subjectName) {
      case 'Tarih':
        return 'Geçmişi keşfet ve tarihi olaylar, şahsiyetler ve medeniyetler hakkında bilgini test et.';
      case 'Bilim':
        return 'Bilimsel keşiflerin dünyasını keşfet ve doğa kanunlarını öğren.';
      case 'Matematik':
        return 'Sayıların dünyasında yolculuk yap ve matematiksel becerilerini geliştir.';
      case 'Edebiyat':
        return 'Edebiyatın büyülü dünyasını keşfet ve klasik eserleri tanı.';
      case 'Coğrafya':
        return 'Dünyayı keşfet ve farklı kültürler, ülkeler ve coğrafi özellikler hakkında bilgi edin.';
      case 'Fizik':
        return 'Evrenin temel kanunlarını öğren ve fiziksel dünyayı anla.';
      case 'Kimya':
        return 'Maddenin yapısını keşfet ve kimyasal reaksiyonları öğren.';
      case 'Biyoloji':
        return 'Yaşamın sırlarını keşfet ve canlı organizmaları tanı.';
      case 'Felsefe':
        return 'Düşüncenin derinliklerine in ve filozofların görüşlerini keşfet.';
      case 'Müzik':
        return 'Müziğin büyülü dünyasını keşfet ve klasik bestecileri tanı.';
      case 'Sanat':
        return 'Sanatın evrimini keşfet ve büyük sanatçıları tanı.';
      case 'Spor':
        return 'Sporun tarihini keşfet ve büyük sporcuları tanı.';
      default:
        return 'Bu konu hakkında bilgini test et ve yeni şeyler öğren.';
    }
  }
}
