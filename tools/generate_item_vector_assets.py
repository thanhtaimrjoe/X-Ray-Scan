from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from PIL import Image, ImageDraw, ImageFilter


OUT_DIR = Path("docs/assets/vector_items")
VIEWBOX = 256
CYAN = "#38F6FF"
CYAN_SOFT = "#8DFBFF"
BG = (5, 18, 26, 255)


@dataclass(frozen=True)
class SvgShape:
    tag: str
    attrs: dict[str, str]
    fill: bool = False
    stroke: bool = True
    soft: bool = False


@dataclass(frozen=True)
class ItemAsset:
    filename: str
    label: str
    shapes: list[SvgShape]
    preview: Callable[[ImageDraw.ImageDraw, tuple[int, int], float], None]


def attrs_to_text(attrs: dict[str, str]) -> str:
    return " ".join(f'{key}="{value}"' for key, value in attrs.items())


def svg_for(item: ItemAsset) -> str:
    body = []
    for shape in item.shapes:
        attrs = dict(shape.attrs)
        attrs["fill"] = "url(#xrayFill)" if shape.fill else "none"
        attrs["stroke"] = CYAN_SOFT if shape.soft else CYAN
        attrs["stroke-width"] = attrs.get("stroke-width", "8")
        attrs["stroke-linecap"] = attrs.get("stroke-linecap", "round")
        attrs["stroke-linejoin"] = attrs.get("stroke-linejoin", "round")
        attrs["filter"] = "url(#glow)" if shape.soft else "url(#fineGlow)"
        if not shape.stroke:
            attrs["stroke"] = "none"
        body.append(f"  <{shape.tag} {attrs_to_text(attrs)} />")

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <defs>
    <filter id="fineGlow" x="-25%" y="-25%" width="150%" height="150%">
      <feGaussianBlur stdDeviation="1.6" result="blur" />
      <feMerge>
        <feMergeNode in="blur" />
        <feMergeNode in="SourceGraphic" />
      </feMerge>
    </filter>
    <filter id="glow" x="-35%" y="-35%" width="170%" height="170%">
      <feGaussianBlur stdDeviation="3.2" result="blur" />
      <feMerge>
        <feMergeNode in="blur" />
        <feMergeNode in="SourceGraphic" />
      </feMerge>
    </filter>
    <linearGradient id="xrayFill" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8DFBFF" stop-opacity="0.38" />
      <stop offset="100%" stop-color="#38F6FF" stop-opacity="0.16" />
    </linearGradient>
  </defs>
{chr(10).join(body)}
</svg>
'''


def p(tag: str, attrs: dict[str, str], fill: bool = False, soft: bool = False) -> SvgShape:
    return SvgShape(tag=tag, attrs=attrs, fill=fill, soft=soft)


def preview_paint() -> tuple[tuple[int, int, int, int], tuple[int, int, int, int]]:
    return (56, 246, 255, 230), (141, 251, 255, 90)


def draw_line(draw: ImageDraw.ImageDraw, xy, width: int = 5) -> None:
    stroke, _ = preview_paint()
    draw.line(xy, fill=stroke, width=width, joint="curve")


def draw_polygon(draw: ImageDraw.ImageDraw, xy, width: int = 5) -> None:
    stroke, fill = preview_paint()
    draw.polygon(xy, fill=fill)
    draw.line([*xy, xy[0]], fill=stroke, width=width, joint="curve")


def draw_round_rect(draw: ImageDraw.ImageDraw, xy, radius: int = 12, width: int = 5) -> None:
    stroke, fill = preview_paint()
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=stroke, width=width)


def draw_ellipse(draw: ImageDraw.ImageDraw, xy, width: int = 5, fill_on: bool = False) -> None:
    stroke, fill = preview_paint()
    draw.ellipse(xy, fill=fill if fill_on else None, outline=stroke, width=width)


def pt(origin: tuple[int, int], scale: float, x: float, y: float) -> tuple[int, int]:
    return (round(origin[0] + x * scale), round(origin[1] + y * scale))


def preview_knife(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_polygon(draw, [pt(origin, scale, 26, 118), pt(origin, scale, 152, 54), pt(origin, scale, 116, 122), pt(origin, scale, 56, 150)])
    draw_round_rect(draw, (*pt(origin, scale, 46, 145), *pt(origin, scale, 124, 174)), radius=9, width=5)
    for x in (70, 96):
        draw_ellipse(draw, (*pt(origin, scale, x, 154), *pt(origin, scale, x + 8, 162)), width=3)


def preview_scissors(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_ellipse(draw, (*pt(origin, scale, 48, 152), *pt(origin, scale, 90, 194)), width=5)
    draw_ellipse(draw, (*pt(origin, scale, 122, 150), *pt(origin, scale, 164, 192)), width=5)
    draw_line(draw, [pt(origin, scale, 86, 142), pt(origin, scale, 170, 58)], 6)
    draw_line(draw, [pt(origin, scale, 120, 142), pt(origin, scale, 70, 48)], 6)
    draw_ellipse(draw, (*pt(origin, scale, 98, 130), *pt(origin, scale, 114, 146)), width=3, fill_on=True)


def preview_lighter(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 84, 96), *pt(origin, scale, 142, 188)), radius=10, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 112, 56), *pt(origin, scale, 158, 98)), radius=8, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 142, 92), *pt(origin, scale, 186, 118)), radius=5, width=4)
    draw_line(draw, [pt(origin, scale, 140, 72), pt(origin, scale, 174, 78)], 4)


def preview_razor(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 62, 48), *pt(origin, scale, 166, 82)), radius=9, width=5)
    draw_line(draw, [pt(origin, scale, 114, 84), pt(origin, scale, 84, 188)], 8)
    draw_line(draw, [pt(origin, scale, 114, 84), pt(origin, scale, 134, 188)], 5)
    for x in (76, 98, 120, 142):
        draw_line(draw, [pt(origin, scale, x, 55), pt(origin, scale, x + 10, 75)], 2)


def preview_battery(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 62, 74), *pt(origin, scale, 168, 182)), radius=12, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 94, 54), *pt(origin, scale, 136, 74)), radius=5, width=4)
    draw_round_rect(draw, (*pt(origin, scale, 78, 94), *pt(origin, scale, 152, 164)), radius=8, width=3)
    for x in (96, 116, 136):
        draw_line(draw, [pt(origin, scale, x, 104), pt(origin, scale, x, 154)], 3)


def preview_phone(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 76, 52), *pt(origin, scale, 154, 190)), radius=16, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 92, 76), *pt(origin, scale, 138, 154)), radius=5, width=4)
    draw_ellipse(draw, (*pt(origin, scale, 110, 166), *pt(origin, scale, 122, 178)), width=3)
    draw_line(draw, [pt(origin, scale, 106, 64), pt(origin, scale, 126, 64)], 3)


def preview_laptop(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 48, 66), *pt(origin, scale, 170, 146)), radius=6, width=5)
    draw_polygon(draw, [pt(origin, scale, 36, 154), pt(origin, scale, 182, 154), pt(origin, scale, 204, 184), pt(origin, scale, 58, 188)])
    for x in range(74, 150, 16):
        draw_line(draw, [pt(origin, scale, x, 164), pt(origin, scale, x + 40, 164)], 2)
    draw_round_rect(draw, (*pt(origin, scale, 92, 172), *pt(origin, scale, 136, 182)), radius=3, width=2)


def preview_bottle(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_round_rect(draw, (*pt(origin, scale, 88, 78), *pt(origin, scale, 142, 190)), radius=24, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 98, 48), *pt(origin, scale, 132, 78)), radius=6, width=5)
    for y in (104, 124, 144, 164):
        draw_line(draw, [pt(origin, scale, 92, y), pt(origin, scale, 138, y)], 3)


def preview_sandwich(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_polygon(draw, [pt(origin, scale, 38, 168), pt(origin, scale, 178, 168), pt(origin, scale, 74, 74)])
    draw_line(draw, [pt(origin, scale, 58, 146), pt(origin, scale, 158, 146)], 4)
    draw_line(draw, [pt(origin, scale, 70, 158), pt(origin, scale, 144, 124)], 3)
    for x, y in ((92, 132), (116, 138), (132, 120)):
        draw_ellipse(draw, (*pt(origin, scale, x, y), *pt(origin, scale, x + 6, y + 6)), width=2, fill_on=True)


def preview_keys(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw_ellipse(draw, (*pt(origin, scale, 82, 42), *pt(origin, scale, 144, 104)), width=6)
    draw_ellipse(draw, (*pt(origin, scale, 74, 96), *pt(origin, scale, 118, 140)), width=5)
    draw_ellipse(draw, (*pt(origin, scale, 124, 98), *pt(origin, scale, 168, 142)), width=5)
    draw_line(draw, [pt(origin, scale, 94, 132), pt(origin, scale, 62, 190)], 7)
    draw_line(draw, [pt(origin, scale, 146, 132), pt(origin, scale, 172, 190)], 7)
    draw_line(draw, [pt(origin, scale, 68, 174), pt(origin, scale, 88, 174)], 4)
    draw_line(draw, [pt(origin, scale, 154, 174), pt(origin, scale, 176, 174)], 4)


def preview_headphones(draw: ImageDraw.ImageDraw, origin: tuple[int, int], scale: float) -> None:
    draw.arc((*pt(origin, scale, 44, 48), *pt(origin, scale, 174, 178)), start=200, end=340, fill=preview_paint()[0], width=8)
    draw_round_rect(draw, (*pt(origin, scale, 40, 120), *pt(origin, scale, 78, 178)), radius=16, width=5)
    draw_round_rect(draw, (*pt(origin, scale, 142, 120), *pt(origin, scale, 180, 178)), radius=16, width=5)
    draw_ellipse(draw, (*pt(origin, scale, 50, 132), *pt(origin, scale, 70, 166)), width=3)
    draw_ellipse(draw, (*pt(origin, scale, 150, 132), *pt(origin, scale, 170, 166)), width=3)


ITEMS = [
    ItemAsset(
        "item_danger_knife.svg",
        "danger_knife",
        [
            p("path", {"d": "M32 124 C66 96 116 64 184 44 C170 84 132 122 84 148 Z"}, True, True),
            p("rect", {"x": "52", "y": "144", "width": "82", "height": "28", "rx": "9"}, True),
            p("circle", {"cx": "76", "cy": "158", "r": "4"}, True, False),
            p("circle", {"cx": "104", "cy": "158", "r": "4"}, True, False),
            p("path", {"d": "M74 142 L128 120"}, False),
        ],
        preview_knife,
    ),
    ItemAsset(
        "item_danger_scissors.svg",
        "danger_scissors",
        [
            p("circle", {"cx": "70", "cy": "172", "r": "22"}),
            p("circle", {"cx": "145", "cy": "170", "r": "22"}),
            p("path", {"d": "M98 148 L184 54"}),
            p("path", {"d": "M122 148 L74 48"}),
            p("circle", {"cx": "110", "cy": "139", "r": "7"}, True),
        ],
        preview_scissors,
    ),
    ItemAsset(
        "item_danger_lighter.svg",
        "danger_lighter",
        [
            p("rect", {"x": "86", "y": "98", "width": "64", "height": "96", "rx": "11"}, True, True),
            p("rect", {"x": "116", "y": "54", "width": "50", "height": "44", "rx": "9"}, True),
            p("rect", {"x": "148", "y": "92", "width": "44", "height": "28", "rx": "5"}),
            p("path", {"d": "M102 122 H134 M102 144 H134 M102 166 H134"}, False),
            p("circle", {"cx": "151", "cy": "76", "r": "7"}, False),
        ],
        preview_lighter,
    ),
    ItemAsset(
        "item_danger_razor.svg",
        "danger_razor",
        [
            p("rect", {"x": "60", "y": "46", "width": "112", "height": "38", "rx": "9"}, True, True),
            p("path", {"d": "M116 88 L84 194"}, False),
            p("path", {"d": "M116 88 L138 194"}, False),
            p("path", {"d": "M76 56 L88 76 M100 56 L112 76 M124 56 L136 76 M148 56 L160 76"}, False),
        ],
        preview_razor,
    ),
    ItemAsset(
        "item_danger_battery_pack.svg",
        "danger_battery_pack",
        [
            p("rect", {"x": "58", "y": "74", "width": "118", "height": "114", "rx": "14"}, True, True),
            p("rect", {"x": "94", "y": "52", "width": "44", "height": "22", "rx": "5"}),
            p("rect", {"x": "78", "y": "96", "width": "78", "height": "72", "rx": "8"}),
            p("path", {"d": "M98 108 V158 M118 108 V158 M138 108 V158"}, False),
        ],
        preview_battery,
    ),
    ItemAsset(
        "item_safe_phone.svg",
        "safe_phone",
        [
            p("rect", {"x": "78", "y": "48", "width": "84", "height": "148", "rx": "18"}, True, True),
            p("rect", {"x": "94", "y": "74", "width": "52", "height": "86", "rx": "5"}),
            p("circle", {"cx": "120", "cy": "176", "r": "7"}),
            p("path", {"d": "M108 62 H132 M102 88 H138 M102 112 H138 M102 136 H138"}, False),
        ],
        preview_phone,
    ),
    ItemAsset(
        "item_safe_laptop.svg",
        "safe_laptop",
        [
            p("rect", {"x": "46", "y": "66", "width": "128", "height": "82", "rx": "6"}, True, True),
            p("path", {"d": "M36 156 H184 L208 188 H58 Z"}, True),
            p("rect", {"x": "86", "y": "170", "width": "54", "height": "12", "rx": "3"}),
            p("path", {"d": "M66 166 H162 M78 176 H172 M76 86 H144 M76 106 H144 M76 126 H144"}, False),
        ],
        preview_laptop,
    ),
    ItemAsset(
        "item_safe_bottle.svg",
        "safe_bottle",
        [
            p("rect", {"x": "90", "y": "76", "width": "58", "height": "120", "rx": "27"}, True, True),
            p("rect", {"x": "100", "y": "46", "width": "38", "height": "32", "rx": "7"}),
            p("path", {"d": "M96 106 H142 M96 126 H142 M96 146 H142 M96 166 H142"}, False),
        ],
        preview_bottle,
    ),
    ItemAsset(
        "item_safe_sandwich.svg",
        "safe_sandwich",
        [
            p("path", {"d": "M36 174 H184 L76 72 Z"}, True, True),
            p("path", {"d": "M58 148 H166 M70 160 C96 144 122 136 148 124"}, False),
            p("circle", {"cx": "96", "cy": "132", "r": "4"}, True, False),
            p("circle", {"cx": "122", "cy": "138", "r": "4"}, True, False),
        ],
        preview_sandwich,
    ),
    ItemAsset(
        "item_safe_keys.svg",
        "safe_keys",
        [
            p("circle", {"cx": "114", "cy": "72", "r": "34"}),
            p("circle", {"cx": "96", "cy": "120", "r": "23"}),
            p("circle", {"cx": "150", "cy": "122", "r": "23"}),
            p("path", {"d": "M96 140 L62 198 M150 142 L178 198"}, False, True),
            p("path", {"d": "M68 182 H90 M160 182 H182 M72 166 H84 M164 166 H176"}, False),
        ],
        preview_keys,
    ),
    ItemAsset(
        "item_safe_headphones.svg",
        "safe_headphones",
        [
            p("path", {"d": "M46 136 C52 62 174 62 182 136"}, False, True),
            p("rect", {"x": "38", "y": "124", "width": "42", "height": "62", "rx": "18"}, True),
            p("rect", {"x": "148", "y": "124", "width": "42", "height": "62", "rx": "18"}, True),
            p("ellipse", {"cx": "60", "cy": "155", "rx": "12", "ry": "22"}),
            p("ellipse", {"cx": "169", "cy": "155", "rx": "12", "ry": "22"}),
        ],
        preview_headphones,
    ),
]


def write_preview_png() -> None:
    thumb = 190
    label_h = 30
    cols = 4
    rows = 3
    sheet = Image.new("RGBA", (cols * thumb, rows * (thumb + label_h)), BG)
    glow_layer = Image.new("RGBA", sheet.size, (0, 0, 0, 0))

    for idx, item in enumerate(ITEMS):
        col = idx % cols
        row = idx // cols
        x = col * thumb
        y = row * (thumb + label_h)
        cell = Image.new("RGBA", (thumb, thumb), (0, 0, 0, 0))
        cell_draw = ImageDraw.Draw(cell)
        item.preview(cell_draw, (14, 8), 0.82)

        alpha = cell.getchannel("A").filter(ImageFilter.GaussianBlur(5))
        glow = Image.new("RGBA", cell.size, (56, 246, 255, 70))
        glow.putalpha(alpha.point(lambda p: min(120, p)))
        glow_layer.alpha_composite(glow, (x, y))
        sheet.alpha_composite(cell, (x, y))

        draw = ImageDraw.Draw(sheet)
        draw.text((x + 10, y + thumb + 4), item.label, fill=(190, 250, 255, 255))

    sheet = Image.alpha_composite(glow_layer, sheet)
    sheet.save(OUT_DIR / "item_vector_preview_sheet.png")


def write_preview_svg() -> None:
    cols = 4
    cell = 256
    label_h = 34
    width = cols * cell
    height = 3 * (cell + label_h)
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="#05121A" />',
    ]
    for idx, item in enumerate(ITEMS):
        col = idx % cols
        row = idx // cols
        x = col * cell
        y = row * (cell + label_h)
        content = svg_for(item)
        inner = content.split("</defs>", 1)[1].replace("</svg>", "").strip()
        defs = content.split("<defs>", 1)[1].split("</defs>", 1)[0]
        if idx == 0:
            parts.insert(2, f"<defs>{defs}</defs>")
        parts.append(f'<g transform="translate({x},{y})">{inner}</g>')
        parts.append(f'<text x="{x + 12}" y="{y + cell + 23}" fill="#B7EFF4" font-size="16" font-family="Arial">{item.label}</text>')
    parts.append("</svg>")
    (OUT_DIR / "item_vector_preview_sheet.svg").write_text("\n".join(parts), encoding="utf-8")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for item in ITEMS:
        (OUT_DIR / item.filename).write_text(svg_for(item), encoding="utf-8")
    write_preview_svg()
    write_preview_png()
    print(f"Wrote {len(ITEMS)} SVG items to {OUT_DIR}")


if __name__ == "__main__":
    main()
