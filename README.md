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

## Dc: C with D rules, straight to assembly (lang/)

`lang/dcc run file.dc` | `dcc build file.dc -o out` | `dcc asm file.dc` (shows the assembly it writes).
Dc 0.02 -> our own x86-64 assembly -> program. No C compiler and no C library: printing and exit are
Linux system calls in our own runtime (the D numeral printer is hand-written assembly). `as`/`ld` only
turn the assembly text into the program file.

- No zero anywhere in code: no `0` digit, `NULL`, `false`, `'\0'`, no 0 in names.
- Numbers are D numerals: digits 1-9 A-D, no zero digit. Ten is `$A`, thirteen `$D`, fourteen `11`.
  (`$` is only needed when a numeral starts with a letter.) `99` is 126; the letter c is `78` or `'c'`.
- No minus: `move N from a to b;` moves, the total stays the same. Moving more than is there stops the program.
  A thing moved out in full shows as `~`: its place is taken by something else.
- Counting starts at 1: `row[1]` is the first place; `argv[1]` is the program itself.
- `say("...%d %s %c...", ...)` prints; `%d` prints D numerals. `return 1` from main = all good.
- In: int/long (64-bit), char, pointers, rows (also 2-D), functions (up to 6 inputs), recursion,
  if/else, while, for, break/continue, `? :`, `+ * / %`, `+= *= /= %=`, `++`, casts, `#define`.
- Not yet: structs, fractions, `D>` (decompose: needs Mike's rule for how a thing splits).
- Tests: `lang/tests/run.sh` (tricks refused, honest programs right).

## The machine has no zero either

Mike, 18 Nov 2026: "a transistor is never zero, it is lower than 1, but is mass and has effects within from its atoms".
An "off" bit is a LOW: a voltage lower than 1, still current leaking, still atoms with mass. A bit is HIGH (1) or LOW
(lower than 1), never nothing. So D runs all the way down: the "0" in machine code is only an old label for LOW.
