#!/usr/bin/env python3
"""Draws preview.png: every glyph with its key, plus a sample line."""
import json, os
from PIL import Image, ImageDraw, ImageFont, features
HERE = os.path.dirname(os.path.abspath(__file__))
src = json.load(open(os.path.join(HERE, "glyphs.json")))
f = ImageFont.truetype(os.path.join(HERE, "d-angle.ttf"), 90)
lab = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
items = [(g.get("char") or g.get("liga"), g["name"]) for g in src["glyphs"] if g["name"] != "space"]
cols, cw, ch = 6, 190, 170
rows = (len(items) + cols - 1) // cols
img = Image.new("RGB", (cols * cw, rows * ch + 160), "white"); d = ImageDraw.Draw(img)
raqm = features.check("raqm")
for i, (key, name) in enumerate(items):
    x, y = (i % cols) * cw + 20, (i // cols) * ch + 10
    d.text((x, y), key, font=f, fill="black",
           **({"features": ["liga"]} if raqm else {}))
    d.text((x, y + 125), "%s  %s" % (key, name), font=lab, fill="#666")
d.text((20, rows * ch + 30), "plum > Bob D> sugar + heat + poo ~", font=lab, fill="#666")
d.text((20, rows * ch + 60), "1 > D D> 3 + 4 + 6 ~", font=f, fill="black",
       **({"features": ["liga"]} if raqm else {}))
img.save(os.path.join(HERE, "preview.png")); print("raqm", raqm)
