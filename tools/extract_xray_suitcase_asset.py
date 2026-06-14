from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/assets/asset_candidates/ui_suitcase_xray_empty_scenario_candidate_01.png"
OUTPUT = ROOT / "app/assets/images/ui/ui_suitcase_xray_empty.png"

PADDING = 36
TARGET_HEIGHT = 896
ALPHA_BLACK = 7
ALPHA_FULL = 72


def alpha_for(value: int) -> int:
    if value <= ALPHA_BLACK:
        return 0
    if value >= ALPHA_FULL:
        return 255
    return round((value - ALPHA_BLACK) / (ALPHA_FULL - ALPHA_BLACK) * 255)


def make_cutout(source: Image.Image) -> Image.Image:
    rgba = source.convert("RGBA")
    pixels = rgba.load()
    min_x = rgba.width
    min_y = rgba.height
    max_x = 0
    max_y = 0

    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, _ = pixels[x, y]
            value = max(r, g, b)
            alpha = alpha_for(value)
            pixels[x, y] = (r, g, b, alpha)
            if alpha > 0:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)

    if min_x > max_x or min_y > max_y:
        raise RuntimeError("No suitcase pixels detected")

    left = max(0, min_x - PADDING)
    top = max(0, min_y - PADDING)
    right = min(rgba.width, max_x + PADDING + 1)
    bottom = min(rgba.height, max_y + PADDING + 1)
    cutout = rgba.crop((left, top, right, bottom))
    target_width = round(cutout.width * (TARGET_HEIGHT / cutout.height))
    return cutout.resize((target_width, TARGET_HEIGHT), Image.Resampling.LANCZOS)


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Missing source suitcase image: {SOURCE}")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    suitcase = make_cutout(Image.open(SOURCE))
    suitcase.save(OUTPUT)
    print(f"Wrote {OUTPUT.relative_to(ROOT)} {suitcase.width}x{suitcase.height}")


if __name__ == "__main__":
    main()
