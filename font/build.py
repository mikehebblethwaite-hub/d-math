#!/usr/bin/env python3
"""D angle font: builds d-angle.ttf from glyphs.json (edit that, then run this)."""
import json, math, os, sys
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.feaLib.builder import addOpenTypeFeaturesFromString

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = json.load(open(os.path.join(HERE, "glyphs.json")))
W = SRC["stroke"]
TOP = 700

def hex_spiral(n):
    """n corners: n+1 lines, each turn 60 degrees (hex), lengths 1,1,2,2,3,3..."""
    lens = [1 + i // 2 for i in range(n + 1)]
    pts, x, y, a = [(0.0, 0.0)], 0.0, 0.0, 0.0
    for L in lens:
        x += L * math.cos(a); y += L * math.sin(a)
        pts.append((x, y)); a += math.pi / 3
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    span = max(max(xs) - min(xs), max(ys) - min(ys), 1e-9)
    s = min(TOP / span, 420)           # small numbers stay small, big ones fit
    return [((px - min(xs)) * s, (py - min(ys)) * s + (TOP - (max(ys) - min(ys)) * s) / 2)
            for px, py in pts]

def outline(pts, w):
    """Polyline -> one closed polygon with sharp (mitred) corners."""
    h = w / 2
    def norm(p, q):
        dx, dy = q[0] - p[0], q[1] - p[1]; L = math.hypot(dx, dy) or 1
        return (-dy / L, dx / L)
    left, right = [], []
    for i, p in enumerate(pts):
        if i == 0: nx, ny = norm(pts[0], pts[1]); m = 1
        elif i == len(pts) - 1: nx, ny = norm(pts[-2], pts[-1]); m = 1
        else:
            a, b = norm(pts[i-1], p), norm(p, pts[i+1])
            nx, ny = a[0] + b[0], a[1] + b[1]; L = math.hypot(nx, ny) or 1
            nx, ny = nx / L, ny / L; m = 1 / max(nx * a[0] + ny * a[1], 0.3)
        left.append((p[0] + nx * h * m, p[1] + ny * h * m))
        right.append((p[0] - nx * h * m, p[1] - ny * h * m))
    return left + right[::-1]

def wave(c):
    pts = []
    for i in range(41):
        t = i / 40
        pts.append((c["x0"] + t * (c["x1"] - c["x0"]),
                    c["y"] + c["amp"] * math.sin(t * c["waves"] * 2 * math.pi)))
    return pts

def draw(polys, adv, pad=60):
    pen = TTGlyphPen(None)
    for poly in polys:
        poly = [(round(x + pad), round(y)) for x, y in poly]
        # clockwise for TrueType
        area = sum(a[0]*b[1]-b[0]*a[1] for a, b in zip(poly, poly[1:] + poly[:1]))
        if area > 0: poly = poly[::-1]
        pen.moveTo(poly[0])
        for p in poly[1:]: pen.lineTo(p)
        pen.closePath()
    return pen.glyph()

order, glyphs, metrics, cmap, ligas = [".notdef"], {}, {}, {}, []
glyphs[".notdef"] = draw([], 500); metrics[".notdef"] = (500, 0)
for g in SRC["glyphs"]:
    name = g["name"]; order.append(name)
    if "angles" in g:
        line = hex_spiral(g["angles"])
        adv = round(max(p[0] for p in line) + W + 120)
        polys, pad = [outline(line, W)], 60
    elif "curve" in g:
        polys, adv, pad = [outline(wave(g["curve"]), W)], g["width"], 0
    else:
        polys = [outline(s, W) for s in g["strokes"] if len(s) > 1]
        adv, pad = g["width"], 0
    glyphs[name] = draw(polys, adv, pad); metrics[name] = (adv, 0)
    for ch in [g.get("char"), g.get("also")]:
        if ch: cmap[ord(ch)] = name
    if "liga" in g: ligas.append((g["liga"], name))

fb = FontBuilder(1000, isTTF=True)
fb.setupGlyphOrder(order)
fb.setupCharacterMap(cmap)
fb.setupGlyf(glyphs)
fb.setupHorizontalMetrics({n: (metrics[n][0], glyphs[n].xMin if hasattr(glyphs[n], "xMin") else 0) for n in order})
fb.setupHorizontalHeader(ascent=850, descent=-150)
fb.setupNameTable({"familyName": "D Angle", "styleName": "Regular"})
fb.setupOS2(sTypoAscender=850, sTypoDescender=-150, usWinAscent=850, usWinDescent=150)
fb.setupPost()
if ligas:
    rev = {v: k for k, v in cmap.items()}
    rules = "\n".join("  sub %s by %s;" % (" ".join(cmap[ord(c)] for c in seq), name)
                      for seq, name in ligas)
    addOpenTypeFeaturesFromString(fb.font, "feature liga {\n%s\n} liga;\nfeature calt {\n%s\n} calt;\n" % (rules, rules))
out = os.path.join(HERE, "d-angle.ttf")
fb.save(out)
print("built", out, len(order) - 1, "glyphs")
