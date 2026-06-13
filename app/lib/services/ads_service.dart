import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  const AdsService._();

  static const androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // Widget tests and unsupported platforms do not register the native ads plugin.
    }
  }

  static BannerAd createTestBannerAd({required BannerAdListener listener}) {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: androidTestBannerAdUnitId,
      listener: listener,
      request: const AdRequest(),
    );
  }

  static void loadInterstitial({
    required ValueChanged<InterstitialAd> onAdLoaded,
    required ValueChanged<LoadAdError> onAdFailedToLoad,
  }) {
    InterstitialAd.load(
      adUnitId: androidTestInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  static void loadRewarded({
    required ValueChanged<RewardedAd> onAdLoaded,
    required ValueChanged<LoadAdError> onAdFailedToLoad,
  }) {
    RewardedAd.load(
      adUnitId: androidTestRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}

class XrayBannerAd extends StatefulWidget {
  const XrayBannerAd({super.key});

  @override
  State<XrayBannerAd> createState() => _XrayBannerAdState();
}

class _XrayBannerAdState extends State<XrayBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBanner() {
    final banner = AdsService.createTestBannerAd(
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    banner.load().catchError((Object _) {
      banner.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (_isLoaded && banner != null) {
      return SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      );
    }

    return const _AdFallback();
  }
}

class _AdFallback extends StatelessWidget {
  const _AdFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Ad banner area',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}
