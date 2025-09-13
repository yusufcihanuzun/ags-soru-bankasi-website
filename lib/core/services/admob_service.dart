import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static const String _interstitialAdUnitId =
      'ca-app-pub-5868101723503625/4630477085';

  // Banner reklam birimleri
  static const String _quizBannerAdUnitId =
      'ca-app-pub-5868101723503625/6714892947'; // Soru altı reklam
  static const String _homeBannerAdUnitId =
      'ca-app-pub-5868101723503625/1326834890'; // Anasayfa reklam
  static const String _homeSearchBannerAdUnitId =
      'ca-app-pub-5868101723503625/2979662064'; // Anasayfa arama altı reklam

  // Test banner reklam birimleri (geliştirme için)
  static String get _testBannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Android test banner
      : 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner

  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Reklam kapandıktan sonra yeni reklam yükle
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null && _isAdLoaded) {
      await _interstitialAd!.show();
    } else {
      // Reklam yüklenmemişse yeni reklam yükle ve göster
      await loadInterstitialAd();
      // Kısa bir bekleme süresi
      await Future.delayed(const Duration(seconds: 1));
      if (_interstitialAd != null && _isAdLoaded) {
        await _interstitialAd!.show();
      }
    }
  }

  static bool get isAdLoaded => _isAdLoaded;

  // Banner reklam yönetimi
  static String getBannerAdUnitId(String adType) {
    switch (adType) {
      case 'quiz':
        return _quizBannerAdUnitId;
      case 'home':
        return _homeBannerAdUnitId;
      case 'home_search':
        return _homeSearchBannerAdUnitId;
      default:
        // Test modunda test ID'si kullan
        return _testBannerAdUnitId;
    }
  }

  /// Banner reklam oluştur
  static BannerAd createBannerAd({
    required String adType, // 'quiz' veya 'home'
    required AdSize adSize,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: getBannerAdUnitId(adType),
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('$adType banner reklam açıldı'),
        onAdClosed: (Ad ad) => print('$adType banner reklam kapandı'),
        onAdClicked: (Ad ad) => print('$adType banner reklam tıklandı'),
      ),
    );
  }
}
