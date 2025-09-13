import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../utils/responsive_helper.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize; // Artık opsiyonel - responsive olarak belirlenir
  final String adType; // 'quiz' veya 'home'
  final bool useResponsiveSize; // Responsive boyut kullanılsın mı?

  const BannerAdWidget({
    super.key,
    this.adSize,
    required this.adType,
    this.useResponsiveSize = true, // Varsayılan olarak responsive kullan
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasLoadedAd = false;

  @override
  void initState() {
    super.initState();
    // initState'te sadece temel başlatma yap
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Context hazır olduğunda banner'ı yükle
    if (!_hasLoadedAd) {
      _loadBannerAd();
      _hasLoadedAd = true;
    }
  }

  void _loadBannerAd() {
    // Responsive boyut belirleme
    final adSize = widget.useResponsiveSize
        ? ResponsiveHelper.getBannerAdSize(context)
        : (widget.adSize ?? AdSize.banner);

    _bannerAd = AdMobService.createBannerAd(
      adType: widget.adType,
      adSize: adSize,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
        print(
            '✅ ${widget.adType} banner reklam yüklendi (${adSize.width}x${adSize.height})');
      },
      onAdFailedToLoad: (ad, error) {
        print('❌ ${widget.adType} banner reklam yüklenemedi: $error');
        ad.dispose();
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      },
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Responsive boyut belirleme - build metodunda güvenli
    final adSize = widget.useResponsiveSize
        ? ResponsiveHelper.getBannerAdSize(context)
        : (widget.adSize ?? AdSize.banner);

    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      margin: ResponsiveHelper.getBannerMargin(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context, defaultRadius: 8.0)),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context, defaultRadius: 8.0)),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
