# AGENTS.md - AI Development Guidelines

**Project**: Tap Sort Rush
**Created**: 2026-06-12
**Purpose**: Development rules for AI assistants and future contributors

---

## Project Overview

Tap Sort Rush is an Android-first casual mini game for Google Play. The product goal is to build a simple, replayable 2D reflex game that can be monetized with Google AdMob without positioning the app as child-directed.

### Project Roles

- **PM**: Codex / AI Assistant
- **Product Owner**: Tai
- **Developer**: AI Assistants and future human contributors

### Critical Rule

When you write code, fix bugs, add features, change specs, adjust release configuration, add assets, or modify monetization behavior, you must record the change in:

`docs/changelog/CHANGELOG.md`

No changelog entry means reviewers cannot reliably understand what changed, why it changed, and how it was verified.

---

## Required Reading

Before implementation, read the relevant documents below. For gameplay, ads, release, or policy work, read all of them.

| Document | Path | Purpose |
| --- | --- | --- |
| Game Concept | `docs/01_game_concept.md` | Product goal, target audience, MVP scope |
| User Stories | `docs/02_user_stories.md` | Functional requirements and acceptance criteria |
| Game Design | `docs/03_game_design.md` | Gameplay loop, scoring, screens, difficulty |
| Monetization and Ads | `docs/04_monetization_ads.md` | AdMob strategy, ad placement rules, policy notes |
| Technical Spec | `docs/05_technical_spec.md` | Flutter architecture, package name, services, testing |
| Release Checklist | `docs/06_release_checklist.md` | Google Play, AdMob, Android release checklist |
| Decision Log | `docs/07_tracking/decisions.md` | Product and technical decisions |
| Progress | `docs/07_tracking/progress.md` | Current project status and next steps |
| Changelog | `docs/changelog/CHANGELOG.md` | Historical record of changes |

---

## Development Workflow

### 1. Understand the Task

- Identify the related user story or create/update one if the work changes product behavior.
- Check acceptance criteria before editing code.
- Confirm whether the task touches gameplay, ads, Android release, policy, or docs.

### 2. Check Design and Policy

- Gameplay changes: read `docs/03_game_design.md`.
- Ad changes: read `docs/04_monetization_ads.md`.
- Android/release changes: read `docs/05_technical_spec.md` and `docs/06_release_checklist.md`.
- Any policy-sensitive monetization change must avoid accidental clicks, child-directed positioning, and live-ad misuse.

### 3. Implement

- Tech stack:
  - **App**: Flutter stable
  - **Game Engine**: Flame
  - **Ads**: Google Mobile Ads SDK via `google_mobile_ads`
  - **Local Storage**: `shared_preferences`
- Code comments must be in English.
- Keep gameplay code small, testable, and shippable.
- Do not commit secrets, keystores, production ad unit IDs, or local signing config.

### 4. Test

- Add or update tests when game rules, scoring, ads frequency, persistence, or release behavior changes.
- Run the narrowest useful verification first, then broader checks when needed.
- Preferred checks:
  - `flutter test`
  - `flutter analyze`
  - `flutter build apk --debug`
  - `flutter build appbundle --release` when release config changes

### 5. Record Changelog

- Add a new entry at the top of `docs/changelog/CHANGELOG.md`.
- Include what changed, why, files touched, technical decisions, tests, and remaining notes.
- Use checked boxes only for verification that actually happened.

### 6. Update Tracking Docs When Needed

- Update `docs/07_tracking/decisions.md` when a product, monetization, package-name, architecture, release, or policy decision changes.
- Update `docs/07_tracking/progress.md` when a milestone is completed or the next-step plan changes.

---

## Mandatory Changelog Format

### File Path

`docs/changelog/CHANGELOG.md`

### Format

```markdown
## [YYYY-MM-DD HH:MM] - Change title

**Owner**: AI Assistant
**Type**: Feature/Bugfix/Refactor/Test/Docs/Chore/Release
**Related US**: US-001, US-002, or N/A
**Impact Scope**: Gameplay/Ads/Android/Docs/Release/Policy

### Changes
- Change 1
- Change 2
- Change 3

### Implementation Details
- File: `path/to/file`
- Reason: ...
- Technical decision: ...

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [ ] Error handling checked
- [ ] Policy/ad placement checked

### Notes
- Risks, follow-ups, or pending work.

---
```

### Example

```markdown
## [2026-06-12 14:30] - Basic scoring system

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-002, US-003
**Impact Scope**: Gameplay, Test

### Changes
- Added score calculation for correct lane taps.
- Added combo multiplier thresholds.
- Added tests for score and combo reset behavior.

### Implementation Details
- File: `app/lib/game/systems/scoring_system.dart`
- File: `app/test/game/scoring_system_test.dart`
- Reason: Satisfy sorting and combo acceptance criteria for MVP gameplay.
- Technical decision: Keep score calculation independent from Flame components so it can be unit tested.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [ ] Policy/ad placement checked

### Notes
- Manual tuning can happen after the first playable loop exists.

---
```

---

## Important Rules

### 1. Changelog Is Mandatory

- Code change: changelog required.
- Bugfix: changelog required.
- Refactor: changelog required.
- Test change: changelog required.
- Spec or policy change: changelog required.
- Release/signing/AdMob configuration change: changelog required.

### 2. Follow the Specs

- Do not silently change product behavior.
- If the spec is wrong or incomplete, update the spec and changelog.
- If a decision affects future review, record it in Decision Log.

### 3. Monetization Safety

- Use test ad unit IDs during development.
- Never click live ads during QA.
- Do not ask or incentivize users to click ads.
- Do not place ads near primary gameplay taps.
- Do not show interstitials on first launch, immediately after Play, or after every round.
- Do not position the app as child-directed unless the whole ads and policy setup is reviewed again.

### 4. Security and Release Safety

- Do not commit Android keystores.
- Do not commit `key.properties`.
- Do not commit production AdMob IDs if they are stored in local config.
- Treat package name changes as release-critical. After first Play Console upload, package name is effectively permanent.

### 5. Code Style

- Dart classes: PascalCase.
- Dart files: snake_case.
- Dart variables/functions: lowerCamelCase.
- Comments: English, only when they explain non-obvious behavior.
- Git commit messages: `type: description`.
- Commit types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `release`.

---

## Do Not

1. Do not skip the changelog.
2. Do not implement without reading the relevant spec.
3. Do not silently change monetization rules.
4. Do not use live ads for development testing.
5. Do not target children without a dedicated policy review.
6. Do not commit secrets, signing keys, or local credentials.
7. Do not make package-name changes casually.

---

## Project Structure

```text
Tap-Sort-Rush/
â”œâ”€â”€ README.md
â”œâ”€â”€ AGENTS.md
â”œâ”€â”€ app/
â”‚   â”œâ”€â”€ android/
â”‚   â”œâ”€â”€ lib/
â”‚   â”œâ”€â”€ test/
â”‚   â””â”€â”€ pubspec.yaml
â””â”€â”€ docs/
    â”œâ”€â”€ 01_game_concept.md
    â”œâ”€â”€ 02_user_stories.md
    â”œâ”€â”€ 03_game_design.md
    â”œâ”€â”€ 04_monetization_ads.md
    â”œâ”€â”€ 05_technical_spec.md
    â”œâ”€â”€ 06_release_checklist.md
    â”œâ”€â”€ 07_tracking/
    â”‚   â”œâ”€â”€ decisions.md
    â”‚   â””â”€â”€ progress.md
    â””â”€â”€ changelog/
        â””â”€â”€ CHANGELOG.md
```

---

## Completion Checklist

- [ ] Acceptance criteria checked.
- [ ] Relevant specs followed or updated.
- [ ] Unit tests added/updated when behavior changed.
- [ ] `flutter test` run when code changed.
- [ ] `flutter analyze` run for meaningful Dart changes.
- [ ] Android build checked when Android config changed.
- [ ] Ad policy checked when ads/monetization changed.
- [ ] Decision Log updated when a durable decision changed.
- [ ] Progress updated when milestone status changed.
- [ ] Changelog entry added.

