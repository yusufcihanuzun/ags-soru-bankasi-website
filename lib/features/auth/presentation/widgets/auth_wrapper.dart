import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _userName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUserName();
  }

  Future<void> _checkUserName() async {
    try {
      print('🔍 Kullanıcı adı kontrol ediliyor...');
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');

      print('✅ Kullanıcı adı kontrolü tamamlandı: $userName');

      if (mounted) {
        setState(() {
          _userName = userName;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('❌ Kullanıcı adı kontrol hatası: $e');
      if (mounted) {
        setState(() {
          _userName = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF6D79EC),
              ),
              SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
              Text(
                'Yükleniyor...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: ResponsiveHelper.getContentPadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[400],
                ),
                SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
                Text(
                  'Bir Hata Oluştu',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getHeaderFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: ResponsiveHelper.isSmallScreen(context) ? 12 : 16),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getSubheaderFontSize(context),
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.getVerticalPadding(context)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _checkUserName();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _userName != null && _userName!.isNotEmpty
        ? HomePage(username: _userName!)
        : const OnboardingPage();
  }
}
