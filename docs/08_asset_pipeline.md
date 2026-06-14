# Asset Pipeline

## Purpose

This document defines how X-Ray Scan should create, review, name, store, and integrate visual assets. The current Flutter build can use mock Canvas art, but production polish should move toward consistent anime airport backgrounds and clean, handover-friendly cyan x-ray item assets.

## Art Direction

Primary style:

- Polished anime mobile game UI.
- International airport/customs inspection setting.
- Warm airport environment outside the scanner.
- Cyan/teal translucent x-ray treatment inside the scanner.
- Clean silhouettes and high readability on Android phones.
- No child-directed framing, mascot-first tone, or toy-store visuals.

Reference files:

- `docs/assets/gameplay_visual_reference_approved.jpg`
- `docs/assets/main_menu_visual_reference_approved.jpg`
- `docs/assets/level_map_visual_reference_approved.jpg`
- `docs/assets/item_database_visual_reference_approved.jpg`
- `docs/assets/level_clear_visual_reference_approved.jpg`
- `docs/assets/level_failed_visual_reference_approved.jpg`
- `docs/assets/xray_asset_sheet_approved.png`
- `app/assets/images/xray_asset_sheet_approved.png`

## Source Strategy

- Use Gemini or other image generators for large illustrated backgrounds and screen mood references.
- Gemini 3.1 is acceptable for gameplay item sheets when the source uses a pure solid black background, no checkerboard pattern, no grid lines, and enough item spacing for deterministic extraction.
- Keep the approved source sheet under `docs/assets/asset_candidates/`, then generate one transparent PNG per item with `tools/extract_xray_item_sprites.py`.
- Prefer PNG masters for item sprites. Runtime WebP can be generated later from approved PNGs if APK size requires it.
- Avoid manual color repair, aggressive blur, or glow reconstruction. If extraction damages the source art, regenerate the sheet instead of repairing heavily.

## MVP Asset Inventory

### Backgrounds

| Asset | Target use | Notes |
| --- | --- | --- |
| `bg_main_menu_terminal.png` | Main menu | Airport x-ray checkpoint with scanner and luggage belt. Leave center-bottom space for buttons and bottom ad. |
| `bg_gameplay_scanner.png` | Gameplay | Portrait airport scanner bay. Must leave central suitcase/scanner area clean and not too visually noisy. |
| `bg_level_map_terminal.png` | Level map | International terminal concourse/customs hall with room for 10 glowing route nodes. |
| `bg_result_checkpoint.png` | Level clear/fail | Softly blurred scanner/checkpoint background behind result cards. |
| `bg_database_grid.png` | Item database | Subtle x-ray grid or scanner glass texture. Low contrast. |

### Gameplay Objects

Danger items:

- `item_danger_knife.png`
- `item_danger_scissors.png`
- `item_danger_lighter.png`
- `item_danger_razor.png`
- `item_danger_battery_pack.png`

Safe items:

- `item_safe_phone.png`
- `item_safe_laptop.png`
- `item_safe_bottle.png`
- `item_safe_sandwich.png`
- `item_safe_keys.png`
- `item_safe_headphones.png`

Object requirements:

- Source should be editable vector/Canvas code, SVG, a true transparent PNG, or an approved pure-black AI sheet that can be deterministically extracted.
- Square export canvas preferred when rasterizing for app use.
- One object per file.
- Cyan x-ray visual treatment by default.
- Shape must be readable at small phone sizes.
- No red/green danger hints baked into the base item art.
- Avoid heavy shadows, oversized glow, or halo outside the object bounds.

### UI and Map Accents

| Asset | Target use | Notes |
| --- | --- | --- |
| `ui_scanner_frame.png` | Gameplay | Optional overlay for premium scanner frame if Canvas frame is not enough. |
| `ui_suitcase_xray_empty.png` | Gameplay | Empty translucent suitcase shell. Can replace Canvas suitcase later. |
| `ui_map_node_completed.png` | Level map | Optional. Code can still draw nodes. |
| `ui_map_node_current.png` | Level map | Optional. |
| `ui_map_node_locked.png` | Level map | Optional. |
| `ui_star_filled.png` | Result/map | Optional if Material stars feel too plain. |
| `ui_star_empty.png` | Result/map | Optional. |

## Folder Structure

Store production-ready app assets under:

```text
app/assets/images/
  backgrounds/
  items/danger/
  items/safe/
  ui/
```

Keep design references and source-review images under:

```text
docs/assets/
```

Do not place temporary generator outputs directly in `app/assets/images/`. First save candidates in `docs/assets/asset_candidates/`, review them, then promote approved files into the app asset folders.

For item assets specifically, the preferred runtime source is code/vector art. Exported PNGs are acceptable only after the vector/source shape is approved.

## Naming Rules

- Use lowercase snake_case.
- Use semantic names, not generator names.
- Add a version suffix only for candidates, such as `item_danger_knife_candidate_01.png`.
- Production app filenames should not include `candidate`, `final`, `new`, or dates.
- Prefer PNG for transparent gameplay objects.
- Prefer PNG or WebP for backgrounds after size testing.

## Background Generation Workflow

1. Generate candidate background image sets from prompts.
2. Save candidates to `docs/assets/asset_candidates/`.
3. Review for style consistency, UI-safe empty space, mobile crop safety, and absence of watermarks/text.
4. Promote approved assets into `app/assets/images/...`.
5. Add the asset path to `app/pubspec.yaml`.
6. Wire the asset into Flutter/Flame.
7. Run:
   - `flutter test`
   - `flutter analyze`
   - `flutter build apk --debug`
8. Test on Galaxy S24-class device and capture evidence.
9. Record the change in `docs/changelog/CHANGELOG.md`.

## Item Asset Workflow

1. Generate an item sheet using the approved item list on a pure solid black background.
2. Save the approved sheet to `docs/assets/asset_candidates/item_sheet_gemini31_black_bg_approved.png`.
3. Run `python tools/extract_xray_item_sprites.py` to export transparent PNG sprites and a cut preview sheet.
4. Review the cut preview for crop safety, alpha edges, and item readability.
5. Integrate the generated PNGs into Flame rendering under `app/assets/images/items/...`.
6. Keep mock Canvas fallback until every item image loads reliably.
7. Run:
   - `flutter test`
   - `flutter analyze`
   - `flutter build apk --debug`
8. Test on a Galaxy S24-class device and capture evidence.
9. Record the change in `docs/changelog/CHANGELOG.md`.

Current vector item source:

- Generator: `tools/generate_item_vector_assets.py`
- Review folder: `docs/assets/vector_items/`
- Preview sheet: `docs/assets/vector_items/item_vector_preview_sheet.png`

Current raster item source:

- Source sheet: `docs/assets/asset_candidates/item_sheet_gemini31_black_bg_approved.png`
- Extraction script: `tools/extract_xray_item_sprites.py`
- Cut preview: `docs/assets/asset_candidates/item_sheet_gemini31_black_bg_cut_preview.png`
- Runtime folders: `app/assets/images/items/danger/` and `app/assets/images/items/safe/`

Current gameplay background:

- Source candidate: `docs/assets/asset_candidates/bg_gameplay_scanner_scenario_candidate_01.png`
- Runtime asset: `app/assets/images/backgrounds/bg_gameplay_scanner.png`
- Generator workflow: Scenario AI using Gemini 3.1 with the approved gameplay reference image.

Current suitcase asset:

- Source candidate: `docs/assets/asset_candidates/ui_suitcase_xray_empty_scenario_candidate_01.png`
- Extraction script: `tools/extract_xray_suitcase_asset.py`
- Runtime asset: `app/assets/images/ui/ui_suitcase_xray_empty.png`
- Generator workflow: Scenario AI using Gemini 3.1, pure black background, empty x-ray suitcase only.

## Prompt Style Guide

Use the same style clause across all generation prompts:

```text
Polished anime mobile game art for an Android casual game called X-Ray Scan, international airport customs inspection theme, warm airport lighting outside the scanner, cyan teal x-ray glow inside scanner elements, crisp readable silhouettes, premium casual game UI quality, clean composition, portrait mobile aspect ratio, no childish toy-like style, no text unless explicitly requested.
```

Negative prompt:

```text
No horror, no gore, no realistic weapons in a threatening scene, no children, no mascot characters, no blurry objects, no unreadable clutter, no random text, no watermark, no logo, no stock photo look, no inconsistent art style.
```

## Background Prompt Templates

### Main Menu

```text
Create a portrait mobile game main menu background for X-Ray Scan.
Scene: international airport customs x-ray checkpoint with a luggage scanner and conveyor belt in the foreground, warm terminal lighting, subtle passengers and signs blurred in the distance.
Composition: leave clear space in the lower third for large Play, Level Map, Item Database buttons and a banner ad at the bottom; leave top space for title and sound/settings icons.
Style: [STYLE CLAUSE]
Do not include readable UI text, buttons, logos, or ad banners in the image.
```

### Gameplay

```text
Create a portrait mobile gameplay background for X-Ray Scan.
Scene: airport x-ray scanner bay viewed straight on, central scanner tunnel and suitcase inspection area, cyan scanner glow, subtle conveyor belt, warm airport terminal visible softly behind.
Composition: keep the center clean for a translucent x-ray suitcase and tappable item silhouettes; keep top HUD and bottom Clear button areas visually calm.
Style: [STYLE CLAUSE]
Do not include readable UI text, score, buttons, logos, or item labels.
```

### Level Map

```text
Create a portrait mobile level map background for X-Ray Scan World 1: International Terminal.
Scene: stylized airport terminal/customs hall with baggage belts, passport stamps, gate signs, glass walls, and soft runway lights.
Composition: leave room for a glowing winding route with 10 level nodes from upper left to lower right; keep top status bar and bottom selected-level panel readable.
Style: [STYLE CLAUSE]
Do not include final route nodes, readable UI text, buttons, logos, or currency icons.
```

### Result Screens

```text
Create a portrait mobile result screen background for X-Ray Scan.
Scene: airport luggage scanner/checkpoint with a suitcase exiting the scanner, softly blurred depth of field, cyan scanner glow, warm terminal lights.
Composition: leave a central vertical area for a large result card and bottom space for an ad banner.
Style: [STYLE CLAUSE]
Do not include readable UI text, buttons, stars, score, logos, or ad banners.
```

## Historical Item Prompt Template

Item prompts are kept for reference/ideation only. The preferred production path is now Codex-authored vector/Canvas/SVG-style item assets.

The first prompt batch is stored at `docs/assets/item_asset_prompt_batch_01.md`, but it should not be treated as the primary production item workflow.

```text
Create a transparent PNG game asset of [OBJECT NAME] as seen through an airport x-ray scanner.
Visual: cyan/teal translucent x-ray silhouette, crisp outline, subtle internal details, readable at small mobile size, centered on transparent background.
Style: polished anime mobile game asset, consistent with X-Ray Scan airport customs game, clean cyan scanner glow.
Constraints: one object only, no label, no text, no red/green status color, no background, no shadow outside object bounds, no watermark.
```

Recommended object notes:

- Knife: clear handle and blade, side view, not posed aggressively.
- Scissors: open blades, circular handles, readable crossed shape.
- Lighter: flip-top lighter silhouette, visible lid and body.
- Razor: disposable razor or razor blade profile, avoid gore context.
- Battery pack: rectangular power bank/battery pack, internal cell detail.
- Phone: smartphone with internal board hints.
- Laptop: open laptop, visible keyboard/screen outline.
- Bottle: plastic water bottle, cap and ribbed body.
- Sandwich: triangular sandwich, layered filling shapes.
- Keys: keyring with 2-3 keys.
- Headphones: over-ear headphones, clear band and cups.

## Acceptance Checklist

Before promoting an asset into `app/assets/images/`:

- [ ] Matches the approved anime airport/x-ray direction.
- [ ] Reads clearly on a Galaxy S24-class phone.
- [ ] Does not include baked UI text unless intentionally part of a background sign and unreadable/ambient.
- [ ] Does not reveal danger/safe state through red/green color.
- [ ] Has consistent cyan x-ray treatment for scanner/items.
- [ ] Has transparent background for item/object assets.
- [ ] Item assets are code/vector-authored, true transparent PNGs, or extracted from an approved pure-black source sheet without checkerboard/grid artifacts.
- [ ] File size is reasonable for Android APK.
- [ ] Naming follows lowercase snake_case.
- [ ] Changelog entry is added when integrated into app code.

## Integration Notes

- Keep mock Canvas rendering available until every required production item asset exists.
- Replace gameplay objects in one small batch first, then background screens in later batches.
- Prefer loading item images once and reusing them during Flame render.
- Avoid live network image loading in the game.
- Keep active gameplay free of banner ads.
