class AdBreakRules {
  const AdBreakRules({
    this.interstitialFrequency = 4,
    this.minimumCompletedRoundsBeforeInterstitial = 3,
  }) : assert(interstitialFrequency > 0),
       assert(minimumCompletedRoundsBeforeInterstitial > 0);

  final int interstitialFrequency;
  final int minimumCompletedRoundsBeforeInterstitial;

  bool shouldShowInterstitial({
    required int completedRounds,
    required int roundsSinceInterstitial,
  }) {
    if (completedRounds < minimumCompletedRoundsBeforeInterstitial) {
      return false;
    }
    return roundsSinceInterstitial >= interstitialFrequency;
  }

  AdBreakState onRoundCompleted(AdBreakState state) {
    return state.copyWith(
      completedRounds: state.completedRounds + 1,
      roundsSinceInterstitial: state.roundsSinceInterstitial + 1,
      rewardedContinueUsed: false,
    );
  }

  AdBreakState onInterstitialShown(AdBreakState state) {
    return state.copyWith(roundsSinceInterstitial: 0);
  }

  bool canOfferRewardedContinue({
    required bool rewardedAdAvailable,
    required bool rewardedContinueUsed,
  }) {
    return rewardedAdAvailable && !rewardedContinueUsed;
  }

  AdBreakState onRewardedContinueGranted(AdBreakState state) {
    return state.copyWith(rewardedContinueUsed: true);
  }
}

class AdBreakState {
  const AdBreakState({
    this.completedRounds = 0,
    this.roundsSinceInterstitial = 0,
    this.rewardedContinueUsed = false,
  });

  final int completedRounds;
  final int roundsSinceInterstitial;
  final bool rewardedContinueUsed;

  AdBreakState copyWith({
    int? completedRounds,
    int? roundsSinceInterstitial,
    bool? rewardedContinueUsed,
  }) {
    return AdBreakState(
      completedRounds: completedRounds ?? this.completedRounds,
      roundsSinceInterstitial:
          roundsSinceInterstitial ?? this.roundsSinceInterstitial,
      rewardedContinueUsed: rewardedContinueUsed ?? this.rewardedContinueUsed,
    );
  }
}
