from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/assets/asset_candidates/item_sheet_gemini31_black_bg_approved.png"
OUT_DANGER = ROOT / "app/assets/images/items/danger"
OUT_SAFE = ROOT / "app/assets/images/items/safe"
PREVIEW = ROOT / "docs/assets/asset_candidates/item_sheet_gemini31_black_bg_cut_preview.png"

CANVAS_SIZE = 384
PADDING = 24
DETECT_THRESHOLD = 28
ALPHA_BLACK = 7
ALPHA_FULL = 70


@dataclass(frozen=True)
class ItemSpec:
    name: str
    output: Path


ITEMS_BY_READING_ORDER = [
    ItemSpec("knife", OUT_DANGER / "item_danger_knife.png"),
    ItemSpec("scissors", OUT_DANGER / "item_danger_scissors.png"),
    ItemSpec("lighter", OUT_DANGER / "item_danger_lighter.png"),
    ItemSpec("razor", OUT_DANGER / "item_danger_razor.png"),
    ItemSpec("battery_pack", OUT_DANGER / "item_danger_battery_pack.png"),
    ItemSpec("phone", OUT_SAFE / "item_safe_phone.png"),
    ItemSpec("laptop", OUT_SAFE / "item_safe_laptop.png"),
    ItemSpec("bottle", OUT_SAFE / "item_safe_bottle.png"),
    ItemSpec("sandwich", OUT_SAFE / "item_safe_sandwich.png"),
    ItemSpec("keys", OUT_SAFE / "item_safe_keys.png"),
    ItemSpec("headphones", OUT_SAFE / "item_safe_headphones.png"),
]


def brightness(pixel: tuple[int, int, int, int]) -> int:
    return max(pixel[0], pixel[1], pixel[2])


def connected_boxes(image: Image.Image) -> list[tuple[int, int, int, int]]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
    visited = bytearray(width * height)
    boxes: list[tuple[int, int, int, int]] = []

    def index(x: int, y: int) -> int:
        return y * width + x

    for y in range(height):
        for x in range(width):
            idx = index(x, y)
            if visited[idx] or brightness(pixels[x, y]) < DETECT_THRESHOLD:
                visited[idx] = 1
                continue

            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[idx] = 1
            min_x = max_x = x
            min_y = max_y = y
            count = 0

            while queue:
                cx, cy = queue.popleft()
                count += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)

                for nx, ny in (
                    (cx - 1, cy),
                    (cx + 1, cy),
                    (cx, cy - 1),
                    (cx, cy + 1),
                ):
                    if nx < 0 or nx >= width or ny < 0 or ny >= height:
                        continue
                    nidx = index(nx, ny)
                    if visited[nidx]:
                        continue
                    visited[nidx] = 1
                    if brightness(pixels[nx, ny]) >= DETECT_THRESHOLD:
                        queue.append((nx, ny))

            if count > 550:
                boxes.append((min_x, min_y, max_x + 1, max_y + 1))

    return boxes


def sort_reading_order(boxes: list[tuple[int, int, int, int]]) -> list[tuple[int, int, int, int]]:
    rows: list[list[tuple[int, int, int, int]]] = []
    for box in sorted(boxes, key=lambda b: (b[1] + b[3]) / 2):
        center_y = (box[1] + box[3]) / 2
        for row in rows:
            row_center_y = sum((b[1] + b[3]) / 2 for b in row) / len(row)
            if abs(center_y - row_center_y) < 90:
                row.append(box)
                break
        else:
            rows.append([box])

    ordered: list[tuple[int, int, int, int]] = []
    for row in rows:
        ordered.extend(sorted(row, key=lambda b: b[0]))
    return ordered


def alpha_cutout(crop: Image.Image) -> Image.Image:
    rgba = crop.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, _ = pixels[x, y]
            value = max(r, g, b)
            if value <= ALPHA_BLACK:
                alpha = 0
            elif value >= ALPHA_FULL:
                alpha = 255
            else:
                alpha = round((value - ALPHA_BLACK) / (ALPHA_FULL - ALPHA_BLACK) * 255)
            pixels[x, y] = (r, g, b, alpha)
    return rgba


def square_sprite(source: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    left, top, right, bottom = box
    left = max(0, left - PADDING)
    top = max(0, top - PADDING)
    right = min(source.width, right + PADDING)
    bottom = min(source.height, bottom + PADDING)

    cutout = alpha_cutout(source.crop((left, top, right, bottom)))
    scale = min((CANVAS_SIZE - PADDING * 2) / cutout.width, (CANVAS_SIZE - PADDING * 2) / cutout.height)
    resized = cutout.resize(
        (round(cutout.width * scale), round(cutout.height * scale)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
    canvas.alpha_composite(
        resized,
        ((CANVAS_SIZE - resized.width) // 2, (CANVAS_SIZE - resized.height) // 2),
    )
    return canvas


def write_preview(sprites: list[tuple[str, Image.Image]]) -> None:
    cols = 4
    cell = 180
    rows = (len(sprites) + cols - 1) // cols
    preview = Image.new("RGBA", (cols * cell, rows * cell), (3, 9, 13, 255))
    for index, (_, sprite) in enumerate(sprites):
        thumb = sprite.resize((150, 150), Image.Resampling.LANCZOS)
        x = (index % cols) * cell + 15
        y = (index // cols) * cell + 15
        preview.alpha_composite(thumb, (x, y))
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    preview.save(PREVIEW)


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Missing source sheet: {SOURCE}")

    source = Image.open(SOURCE).convert("RGBA")
    boxes = sort_reading_order(connected_boxes(source))
    if len(boxes) != len(ITEMS_BY_READING_ORDER):
        raise RuntimeError(f"Expected 11 detected items, found {len(boxes)}: {boxes}")

    OUT_DANGER.mkdir(parents=True, exist_ok=True)
    OUT_SAFE.mkdir(parents=True, exist_ok=True)

    sprites: list[tuple[str, Image.Image]] = []
    for spec, box in zip(ITEMS_BY_READING_ORDER, boxes):
        sprite = square_sprite(source, box)
        sprite.save(spec.output)
        sprites.append((spec.name, sprite))

    write_preview(sprites)
    print(f"Extracted {len(sprites)} item sprites")
    print(f"Wrote preview: {PREVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
