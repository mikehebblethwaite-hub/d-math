# D: real world physical maths model (0.01)

D = decompose, destruction. A real world physical maths model: no zero, no minus,
because nothing in the physical world goes to zero or below it.
Nothing vanishes: everything is moved or broken into parts.

## Symbols

| Meaning      | Type | Example                                  |
|--------------|------|------------------------------------------|
| Move         | `>`  | `apple > Bob`                            |
| Decompose    | `D>` | `apple D> sugar + energy + heat + poo ~` |
| Unknown part | `~`  | parts not named yet                      |

- `~` has no angles: its count is not known yet. It is never empty.
  When a part is found, it gets a name and takes the place of `~`.
- Read left to right: what was on the left is now on the right.

## Example

    apple > Bob D> sugar + energy + heat + poo ~

Old math: 1 - 1 = 0 (where did it go?)
D math: the apple is at Bob, then in sugar, energy, heat, poo and ~.

## Angle digits

Each digit is drawn with as many angles as the number it stands for:
1 has 1 angle, 2 has 2 angles, and so on.
Digits run from 1 up to D: 1 2 3 4 5 6 7 8 9 A B C D (A = 10 angles ... D = 13 angles).
There is no zero digit, because a shape with no angles cannot be counted.

`~` has no angles: its count is not known yet. That is why it marks the unknown parts.

The shapes for each digit are still to be drawn.

## Font: D Angle (font/)

- `font/glyphs.json`: the editable source. Digits are drawn by rule (a hex spiral with n corners).
  Operators are lines of [x,y] points; add a new operator by adding an entry.
  `"liga": "D>"` makes typed keys join into one symbol.
- `python3 font/build.py` builds `font/d-angle.ttf`; `python3 font/preview.py` draws `font/preview.png`.
- Use the font only on D maths: in it, A B C D are the digits 10 to 13.
