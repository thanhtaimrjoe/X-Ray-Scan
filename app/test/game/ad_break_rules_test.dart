import 'package:flutter_test/flutter_test.dart';
import 'package:xray_scan/game/systems/ad_break_rules.dart';

void main() {
  group('AdBreakRules', () {
    test('does not show interstitial on first launch or first game over', () {
      const rules = AdBreakRules();

      expect(
        rules.shouldShowInterstitial(
          completedRounds: 0,
          roundsSinceInterstitial: 0,
        ),
        isFalse,
      );
      expect(
        rules.shouldShowInterstitial(
          completedRounds: 1,
          roundsSinceInterstitial: 1,
        ),
        isFalse,
      );
    });

    test('does not show interstitial after every round', () {
      const rules = AdBreakRules(interstitialFrequency: 4);

      for (var rounds = 1; rounds < 4; rounds++) {
        expect(
          rules.shouldShowInterstitial(
            completedRounds: rounds,
            roundsSinceInterstitial: rounds,
          ),
          isFalse,
        );
      }
    });

    test(
      'shows interstitial only after configured completed round frequency',
      () {
        const rules = AdBreakRules(interstitialFrequency: 4);

        expect(
          rules.shouldShowInterstitial(
            completedRounds: 4,
            roundsSinceInterstitial: 4,
          ),
          isTrue,
        );
      },
    );

    test('resets interstitial counter after showing an interstitial', () {
      const rules = AdBreakRules(interstitialFrequency: 4);
      const state = AdBreakState(
        completedRounds: 4,
        roundsSinceInterstitial: 4,
      );

      final updated = rules.onInterstitialShown(state);

      expect(updated.completedRounds, 4);
      expect(updated.roundsSinceInterstitial, 0);
    });

    test('rewarded continue is offered only when loaded and unused', () {
      const rules = AdBreakRules();

      expect(
        rules.canOfferRewardedContinue(
          rewardedAdAvailable: false,
          rewardedContinueUsed: false,
        ),
        isFalse,
      );
      expect(
        rules.canOfferRewardedContinue(
          rewardedAdAvailable: true,
          rewardedContinueUsed: false,
        ),
        isTrue,
      );
      expect(
        rules.canOfferRewardedContinue(
          rewardedAdAvailable: true,
          rewardedContinueUsed: true,
        ),
        isFalse,
      );
    });

    test('rewarded continue cannot be chained in the same round', () {
      const rules = AdBreakRules();
      const state = AdBreakState();

      final updated = rules.onRewardedContinueGranted(state);

      expect(updated.rewardedContinueUsed, isTrue);
      expect(
        rules.canOfferRewardedContinue(
          rewardedAdAvailable: true,
          rewardedContinueUsed: updated.rewardedContinueUsed,
        ),
        isFalse,
      );
    });

    test(
      'completed round keeps rewarded continue locked until a new attempt starts',
      () {
        const rules = AdBreakRules();
        const state = AdBreakState(rewardedContinueUsed: true);

        final updated = rules.onRoundCompleted(state);

        expect(updated.completedRounds, 1);
        expect(updated.roundsSinceInterstitial, 1);
        expect(updated.rewardedContinueUsed, isTrue);
      },
    );

    test('new level attempt resets rewarded continue eligibility', () {
      const rules = AdBreakRules();
      const state = AdBreakState(
        completedRounds: 2,
        roundsSinceInterstitial: 2,
        rewardedContinueUsed: true,
      );

      final updated = rules.onLevelAttemptStarted(state);

      expect(updated.completedRounds, 2);
      expect(updated.roundsSinceInterstitial, 2);
      expect(updated.rewardedContinueUsed, isFalse);
    });
  });
}
