import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'subject_tests_page.dart';

class SubjectTopicsPage extends StatefulWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;

  const SubjectTopicsPage({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
    required this.subjectId,
  });

  @override
  State<SubjectTopicsPage> createState() => _SubjectTopicsPageState();
}

class _SubjectTopicsPageState extends State<SubjectTopicsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  List<Map<String, dynamic>> _topics = [];
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
    _loadTopics();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    try {
      print('Loading topics for subject ${widget.subjectId}...');
      final databaseHelper = getIt<DatabaseHelper>();
      final topics = await databaseHelper.getTopicsBySubject(widget.subjectId);
      print('Loaded ${topics.length} topics from database');
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading topics: $e');
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
                      child: Text(
                        widget.subjectName,
                        style: TextStyle(
                          fontSize:
                              ResponsiveHelper.getHeaderFontSize(context) *
                                  0.85,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
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
                          '${widget.subjectName} konularını seçin ve testlerinizi çözün',
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

                      // Topics List
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
                                  itemCount: _topics.length,
                                  itemBuilder: (context, index) {
                                    final topic = _topics[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildTopicItem(
                                        title: topic['name'],
                                        description: topic['description'] ?? '',
                                        icon: _getIconData(
                                            topic['icon'] ?? 'school'),
                                        color: _parseColor(
                                            topic['icon'] ?? 'school'),
                                        onTap: () => _onTopicSelected(topic),
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

  Widget _buildTopicItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
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
              // Icon
              Container(
                padding: EdgeInsets.all(
                    ResponsiveHelper.isSmallScreen(context) ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
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
                    Text(
                      description,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getSubheaderFontSize(context),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5568),
                      ),
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      // Tarih konuları için ikonlar
      case 'flag':
        return Icons.flag;
      case 'mosque':
        return Icons.mosque;
      case 'castle':
        return Icons.castle;
      case 'crown':
        return Icons.king_bed;
      case 'trending_up':
        return Icons.trending_up;
      case 'culture':
        return Icons.palette;
      case 'pause':
        return Icons.pause_circle;
      case 'world_war':
        return Icons.military_tech;
      case 'break':
        return Icons.broken_image;
      case 'modern_history':
        return Icons.public;
      case 'preparation':
        return Icons.gps_fixed;
      case 'struggle':
        return Icons.sports_martial_arts;
      case 'ataturk':
        return Icons.person;

      // Coğrafya konuları için ikonlar
      case 'factory':
        return Icons.factory;
      case 'people':
        return Icons.people;
      case 'terrain':
        return Icons.terrain;
      case 'location':
        return Icons.location_on;
      case 'weather':
        return Icons.wb_sunny;
      case 'mountain':
        return Icons.landscape;
      case 'agriculture':
        return Icons.agriculture;
      case 'project':
        return Icons.engineering;
      case 'tourism':
        return Icons.flight;
      case 'mining':
        return Icons.diamond;

      // Eğitim konuları için ikonlar
      case 'devices':
        return Icons.devices;
      case 'menu_book':
        return Icons.menu_book;
      case 'psychology':
        return Icons.psychology;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'account_tree':
        return Icons.account_tree;

      // Mevzuat konuları için ikonlar
      case 'article':
        return Icons.article;
      case 'balance':
        return Icons.balance;
      case 'school':
        return Icons.school;
      case 'badge':
        return Icons.badge;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'lock_open':
        return Icons.lock_open;
      case 'scale':
        return Icons.scale;
      case 'gavel':
        return Icons.gavel;
      case 'settings':
        return Icons.settings;

      // Eski ikonlar (geriye uyumluluk)
      case 'history_edu':
        return Icons.history_edu;
      case 'explore':
        return Icons.explore;
      case 'architecture':
        return Icons.architecture;
      case 'calculate':
        return Icons.calculate;
      case 'functions':
        return Icons.functions;
      case 'square':
        return Icons.square;
      case 'speed':
        return Icons.speed;
      case 'bolt':
        return Icons.bolt;
      case 'tech':
        return Icons.devices;
      case 'concepts':
        return Icons.menu_book;
      case 'theories':
        return Icons.psychology;
      case 'model':
        return Icons.lightbulb;
      case 'system':
        return Icons.account_tree;
      case 'law':
        return Icons.article;
      case 'constitution':
        return Icons.balance;
      case 'education_law':
        return Icons.school;
      case 'teacher_law':
        return Icons.badge;
      case 'administration':
        return Icons.admin_panel_settings;
      case 'rights':
        return Icons.lock_open;
      case 'judiciary':
        return Icons.scale;
      case 'legislation':
        return Icons.gavel;
      case 'executive':
        return Icons.settings;
      default:
        return Icons.school;
    }
  }

  Color _parseColor(String colorString) {
    // Tarih konuları için özel renkler
    switch (colorString) {
      case 'flag': // İslamiyet Öncesi Türk Tarihi
        return const Color(0xFF8B4513); // Kahverengi
      case 'mosque': // İlk Türk İslam Devletleri
        return const Color(0xFF228B22); // Yeşil
      case 'castle': // Anadolu Selçuklu
        return const Color(0xFF4169E1); // Mavi
      case 'crown': // Kuruluş Dönemi
        return const Color(0xFFDC143C); // Kırmızı
      case 'trending_up': // Osmanlı Yükselme
        return const Color(0xFFFF8C00); // Turuncu
      case 'culture': // Osmanlı Kültürü
        return const Color(0xFF9932CC); // Mor
      case 'pause': // Duraklama Dönemi
        return const Color(0xFF696969); // Gri
      case 'world_war': // Dağılma 1. Dünya Savaşı
        return const Color(0xFFB22222); // Koyu Kırmızı
      case 'break': // Dağılma Dönemi
        return const Color(0xFF2F4F4F); // Koyu Gri
      case 'modern_history': // Çağdaş Türk ve Dünya Tarihi
        return const Color(0xFF20B2AA); // Deniz Yeşili
      case 'preparation': // Milli Mücadele Hazırlık
        return const Color(0xFFCD853F); // Peru
      case 'struggle': // Milli Mücadele
        return const Color(0xFF32CD32); // Lime Yeşili
      case 'ataturk': // Atatürk Dönemi
        return const Color(0xFFDDA0DD); // Plum

      // Coğrafya konuları için özel renkler
      case 'factory': // Sanayi
        return const Color(0xFF1E3A8A); // Koyu Mavi
      case 'people': // Nüfus
        return const Color(0xFF059669); // Yeşil
      case 'terrain': // Yer Şekilleri
        return const Color(0xFF7C2D12); // Kahverengi
      case 'location': // Coğrafi Konum
        return const Color(0xFFDC2626); // Kırmızı
      case 'weather': // İklim
        return const Color(0xFF0EA5E9); // Mavi
      case 'mountain': // Dağlar
        return const Color(0xFF6B7280); // Gri
      case 'agriculture': // Tarım
        return const Color(0xFF16A34A); // Yeşil
      case 'project': // Projeler
        return const Color(0xFF7C3AED); // Mor
      case 'tourism': // Turizm-Ticaret-Ulaşım
        return const Color(0xFFF59E0B); // Turuncu
      case 'mining': // Madencilik
        return const Color(0xFF92400E); // Kahverengi

      // Eğitim konuları için özel renkler
      case 'devices': // Eğitim ve Öğretim Teknolojileri
        return const Color(0xFF3B82F6); // Mavi
      case 'menu_book': // Eğitimin Temel Kavramları
        return const Color(0xFF8B5CF6); // Mor
      case 'psychology': // Eğitimin Temelleri ve Kuramlar
        return const Color(0xFFEC4899); // Pembe
      case 'lightbulb': // Maarif Modeli
        return const Color(0xFFF59E0B); // Turuncu
      case 'account_tree': // Türk Milli Eğitim Sistemi
        return const Color(0xFF10B981); // Yeşil

      // Mevzuat konuları için özel renkler
      case 'article': // 1739 Sayılı Milli Eğitim Temel Kanunu
        return const Color(0xFF1F2937); // Koyu Gri
      case 'balance': // 1982 Anayasası
        return const Color(0xFFDC2626); // Kırmızı
      case 'school': // 222 Sayılı İlköğretim ve Eğitim Kanunu
        return const Color(0xFF059669); // Yeşil
      case 'badge': // 7528 Sayılı Öğretmenlik Meslek Kanunu
        return const Color(0xFF7C3AED); // Mor
      case 'admin_panel_settings': // İdare
        return const Color(0xFF1E40AF); // Koyu Mavi
      case 'lock_open': // Temel Hak ve Hürriyetler
        return const Color(0xFF16A34A); // Yeşil
      case 'scale': // Yargı
        return const Color(0xFF92400E); // Kahverengi
      case 'gavel': // Yasama
        return const Color(0xFFDC2626); // Kırmızı
      case 'settings': // Yürütme
        return const Color(0xFF6B7280); // Gri

      // Eski renkler (geriye uyumluluk)
      case 'tech':
        return const Color(0xFF3B82F6);
      case 'concepts':
        return const Color(0xFF8B5CF6);
      case 'theories':
        return const Color(0xFFEC4899);
      case 'model':
        return const Color(0xFFF59E0B);
      case 'system':
        return const Color(0xFF10B981);
      case 'law':
        return const Color(0xFF1F2937);
      case 'constitution':
        return const Color(0xFFDC2626);
      case 'education_law':
        return const Color(0xFF059669);
      case 'teacher_law':
        return const Color(0xFF7C3AED);
      case 'administration':
        return const Color(0xFF1E40AF);
      case 'rights':
        return const Color(0xFF16A34A);
      case 'judiciary':
        return const Color(0xFF92400E);
      case 'legislation':
        return const Color(0xFFDC2626);
      case 'executive':
        return const Color(0xFF6B7280);
      default:
        try {
          return Color(int.parse(colorString));
        } catch (e) {
          return const Color(0xFF7081EB); // Varsayılan mavi
        }
    }
  }

  void _onTopicSelected(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SubjectTestsPage(
          subjectName: widget.subjectName,
          topicName: topic['name'],
          topicId: topic['id'],
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
