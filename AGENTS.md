# AGENTS.md - AI Development Guidelines

## Project

Tap Sort Rush is an Android-first casual mini game intended for Google Play release and AdMob monetization.

## Required Reading

Before implementing code, read:

- `docs/01_game_concept.md`
- `docs/02_user_stories.md`
- `docs/03_game_design.md`
- `docs/04_monetization_ads.md`
- `docs/05_technical_spec.md`
- `docs/06_release_checklist.md`

## Mandatory Changelog

Any code, spec, asset, configuration, or release-process change must be recorded in:

`docs/changelog/CHANGELOG.md`

Use this format:

```markdown
## [YYYY-MM-DD HH:MM] - Change title

**Owner**: AI Assistant
**Type**: Feature/Bugfix/Refactor/Test/Docs/Chore
**Scope**: Gameplay/Ads/Android/Docs/Release

### Changes
- Change 1
- Change 2

### Details
- File: `path/to/file`
- Reason: ...
- Decision: ...

### Verification
- [ ] Unit tests
- [ ] Manual playtest
- [ ] Policy check

---
```

## Engineering Rules

- Keep gameplay simple and shippable.
- Do not target children or position the app as child-directed.
- Use test ad unit IDs during development.
- Never click live ads during testing.
- Keep secrets, keystores, and production ad unit IDs out of Git.
- Use English for code comments.
- Prefer small, focused commits.

