"""Outline Arabic copy in Thmanyah Sans as SVG (HarfBuzz shaping, right-aligned)."""
import json
import sys

import uharfbuzz as hb
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

FONTS = "C:/Windows/Fonts/thmanyahsans-{}.otf"
WIDTH = 888


def ntos(v):
    s = f"{v:.1f}"
    return s[:-2] if s.endswith(".0") else s


class Face:
    def __init__(self, weight):
        path = FONTS.format(weight)
        self.hb_font = hb.Font(hb.Face(hb.Blob.from_file_path(path)))
        self.tt = TTFont(path)
        self.gs = self.tt.getGlyphSet()
        self.order = self.tt.getGlyphOrder()
        self.upem = self.tt["head"].unitsPerEm
        self.asc = self.tt["hhea"].ascent
        self.desc = self.tt["hhea"].descent

    def shape(self, text):
        buf = hb.Buffer()
        buf.add_str(text)
        buf.guess_segment_properties()
        hb.shape(self.hb_font, buf, {})
        return buf.glyph_infos, buf.glyph_positions

    def width(self, text, size):
        _, pos = self.shape(text)
        return sum(p.x_advance for p in pos) * size / self.upem


def wrap(face, text, size):
    lines = []
    for para in text.split("\n"):
        cur = ""
        for word in para.split(" "):
            cand = (cur + " " + word).strip()
            if cur and face.width(cand, size) > WIDTH:
                lines.append(cur)
                cur = word
            else:
                cur = cand
        lines.append(cur)
    return lines


def render(text, weight, size, lh, color):
    face = Face(weight)
    scale = size / face.upem
    lines = wrap(face, text, size)
    cmds = []
    for i, line in enumerate(lines):
        infos, pos = face.shape(line)
        total = sum(p.x_advance for p in pos) * scale
        x = WIDTH - total
        content = (face.asc - face.desc) * scale
        baseline = i * lh + (lh - content) / 2 + face.asc * scale
        for info, p in zip(infos, pos):
            pen = SVGPathPen(face.gs, ntos=ntos)
            t = TransformPen(pen, (scale, 0, 0, -scale, x + p.x_offset * scale, baseline - p.y_offset * scale))
            face.gs[face.order[info.codepoint]].draw(t)
            cmds.append(pen.getCommands())
            x += p.x_advance * scale
    h = round(len(lines) * lh)
    d = "".join(cmds)
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{h}" '
           f'viewBox="0 0 {WIDTH} {h}"><path d="{d}" fill="{color}"/></svg>')
    return svg, len(lines)


if __name__ == "__main__":
    spec = json.load(open(sys.argv[1], encoding="utf-8"))
    out = {}
    for key, s in spec.items():
        svg, n = render(s["text"], s["weight"], s["size"], s["lh"], s["color"])
        out[key] = svg
        print(key, n, "lines", len(svg), "chars", file=sys.stderr)
    json.dump(out, open(sys.argv[2], "w", encoding="utf-8"), ensure_ascii=False)
