import 'package:flutter/material.dart';
import 'package:agsapp/core/di/injection.dart';
import 'package:agsapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:agsapp/features/home/presentation/pages/home_page.dart';
import 'package:agsapp/core/services/admob_service.dart';
import 'package:agsapp/core/services/question_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Error handling ekle
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('❌ Flutter Error: ${details.exception}');
      print('❌ Stack trace: ${details.stack}');
    }
  };

  try {
    print('🚀 Uygulama başlatılıyor...');

    // Dependency injection'ı başlat
    await initDependencies();
    print('✅ Dependency injection tamamlandı');

    // Soruları yükle (Debug için force reload)
    if (kDebugMode) {
      await QuestionService.forceReload();
      print('🔄 Sorular yeniden yüklendi (debug mode)');
    } else {
      await QuestionService.initializeQuestions();
      print('✅ Sorular yüklendi');
    }

    // AdMob'u başlat
    await AdMobService.initialize();
    await AdMobService.loadInterstitialAd();
    print('✅ AdMob başlatıldı');

    print('✅ Uygulama başlatma tamamlandı');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('❌ Uygulama başlatma hatası: $e');
    print('❌ Stack trace: $stackTrace');

    // Hata durumunda basit bir error screen göster
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGS App - Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Uygulama Başlatılamadı',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lütfen uygulamayı yeniden başlatın veya cihazınızı yeniden başlatın.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D79EC)),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme,
      ),
      home: const UserCheckPage(), // Kullanıcı kontrolü yapan sayfa
      builder: (context, child) {
        // Global error handling ve responsive text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2)),
          ),
          child: child!,
        );
      },
    );
  }
}

// Kullanıcı kontrolü yapan basit sayfa
class UserCheckPage extends StatefulWidget {
  const UserCheckPage({super.key});

  @override
  State<UserCheckPage> createState() => _UserCheckPageState();
}

class _UserCheckPageState extends State<UserCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final userId = prefs.getInt('user_id');

      if (mounted) {
        if (userName != null && userName.isNotEmpty && userId != null) {
          // Kullanıcı daha önce giriş yapmış, HomePage'e git
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(username: userName),
            ),
          );
        } else {
          // İlk kez giriş yapıyor, OnboardingPage'e git
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OnboardingPage(),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Kullanıcı kontrolü hatası: $e');
      if (mounted) {
        // Hata durumunda onboarding'e git
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6D79EC),
        ),
      ),
    );
  }
}
