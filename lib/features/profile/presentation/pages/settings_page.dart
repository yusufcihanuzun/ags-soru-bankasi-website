import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  bool notificationsEnabled = true;
  String selectedLanguage = 'Türkçe';
  String selectedTheme = 'Açık';
  String username = 'Kullanıcı';

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
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? 'Kullanıcı';
      if (mounted) {
        setState(() {
          username = userName;
        });
      }
    } catch (e) {
      // Hata durumunda varsayılan değer kullan
    }
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
      backgroundColor: const Color(0xFFF8FAFC),
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
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveHelper.getHorizontalPadding(context) * 1.2,
                      ResponsiveHelper.getVerticalPadding(context),
                      ResponsiveHelper.getHorizontalPadding(context) * 1.2,
                      ResponsiveHelper.getVerticalPadding(context) * 0.8,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
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
                              Icons.arrow_back_ios_rounded,
                              color: Color(0xFF7081EB),
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Ayarlar',
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
                                ? 32
                                : 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      FadeTransition(
                        opacity: _fadeController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('HESAP'),
                            _buildSettingsItem(
                              icon: Icons.person_rounded,
                              title: 'Profil Bilgileri',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Profile info action
                              },
                              showArrow: true,
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Icons.lock_rounded,
                              title: 'Şifre Değiştir',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Change password action
                              },
                              showArrow: true,
                            ),
                          ],
                        ),
                      ),

                      // Preferences Section
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
                            _buildSectionHeader('TERCİHLER'),
                            _buildSettingsItem(
                              icon: Icons.notifications_rounded,
                              title: 'Bildirimler',
                              trailing: Switch(
                                value: notificationsEnabled,
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  if (mounted) {
                                    setState(() {
                                      notificationsEnabled = value;
                                    });
                                  }
                                },
                                activeColor: const Color(0xFF4285F4),
                              ),
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Icons.language_rounded,
                              title: 'Dil',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedLanguage,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.getBodyFontSize(
                                              context),
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 6
                                          : 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF9CA3AF),
                                    size: 16,
                                  ),
                                ],
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showLanguageDialog();
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Icons.brightness_6_rounded,
                              title: 'Tema',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedTheme,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.getBodyFontSize(
                                              context),
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveHelper.isSmallScreen(
                                              context)
                                          ? 6
                                          : 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF9CA3AF),
                                    size: 16,
                                  ),
                                ],
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showThemeDialog();
                              },
                            ),
                          ],
                        ),
                      ),

                      // Support Section
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
                            _buildSectionHeader('DESTEK'),
                            _buildSettingsItem(
                              icon: Icons.email_rounded,
                              title: 'Bize Ulaşın',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Contact us action
                              },
                              showArrow: true,
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Icons.help_rounded,
                              title: 'Sıkça Sorulan Sorular',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // FAQ action
                              },
                              showArrow: true,
                            ),
                          ],
                        ),
                      ),

                      // About Section
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
                            _buildSectionHeader('HAKKINDA'),
                            _buildSettingsItem(
                              icon: Icons.info_rounded,
                              title: 'Uygulama Sürümü',
                              trailing: Text(
                                '1.0.0',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getBodyFontSize(context),
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Icons.description_rounded,
                              title: 'Yasal Bilgiler',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Legal info action
                              },
                              showArrow: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.isSmallScreen(context)
                              ? 16
                              : 20), // Alt boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getHorizontalPadding(context),
        ResponsiveHelper.getVerticalPadding(context),
        ResponsiveHelper.getHorizontalPadding(context),
        ResponsiveHelper.isSmallScreen(context) ? 6 : 8,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getSubheaderFontSize(context) * 0.85,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6B7280),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getHorizontalPadding(context),
          vertical: ResponsiveHelper.getVerticalPadding(context),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4B5563),
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
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow && trailing == null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFE5E7EB),
      height: 1,
      indent: 72,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dil Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Türkçe'),
                leading: Radio<String>(
                  value: 'Türkçe',
                  groupValue: selectedLanguage,
                  onChanged: (String? value) {
                    if (mounted) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('English'),
                leading: Radio<String>(
                  value: 'English',
                  groupValue: selectedLanguage,
                  onChanged: (String? value) {
                    if (mounted) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tema Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Açık'),
                leading: Radio<String>(
                  value: 'Açık',
                  groupValue: selectedTheme,
                  onChanged: (String? value) {
                    if (mounted) {
                      setState(() {
                        selectedTheme = value!;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Koyu'),
                leading: Radio<String>(
                  value: 'Koyu',
                  groupValue: selectedTheme,
                  onChanged: (String? value) {
                    if (mounted) {
                      setState(() {
                        selectedTheme = value!;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
