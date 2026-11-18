# D: real world physical maths model (0.01)

D = decompose, destruction. A real world physical maths model: no zero, no minus,
because zero is make-believe: no thing in the physical world goes to zero or below it.
Nothing vanishes: everything is moved or broken into parts.

## Symbols

| Meaning      | Type | Example                                  |
|--------------|------|------------------------------------------|
| Move         | `>`  | `apple > Bob`                            |
| Decompose    | `D>` | `apple D> sugar + energy + heat + poo ~` |
| Unknown part | `~`  | parts not named yet                      |

- `~` has no angles: its count is not known yet. It is always there.
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
Dc 0.05 -> our own x86-64 assembly -> program. No C compiler and no C library: printing and exit are
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
- `D>` decompose: the whole goes into its known parts and its unknown energy `~`; no part vanishes.
  - Every breakdown ends with `~`. A thing broken down to its lowest point (less than 1) still has atoms,
    electrons and forces in it, known and unknown. The known are named parts; what stays is only its
    unknown energy, `~` (Mike, 18 Nov 2026).
  - `apple D> sugar + energy + heat + poo ~;` even shares to the known parts; the rest stays in the apple as `~`.
  - `apple D> 3 sugar + 2 heat ~;` given amounts; the rest stays as `~`.
  - `~` has no name: a named part is a known part, so it is written before `~`.
  - Afterwards the apple holds only `~` (its lowest point); it cannot be broken down again.
  - `~` on its own adds up all the unknown energy left in things broken down (`say("%d", ~)`).
- Neighbours: spent energy goes to neighbours, and the effect on them is always shown.
  - `store battery, lamp, air;` stores absorb what they get.
  - `conduct wire loss 1;` a conductor passes energy on to its other neighbours, less its loss; the loss is heat,
    and heat goes to all its neighbours, and so on.
  - `neighbours wire: lamp, air;` links both ways. `spend 5 from battery;` sends 5 out and prints every step.
  - A share less than 1 is `~` (unknown energy); stores + conductors + `~` always add up to what there was.
  - Energy still going round conductors after DD steps stops the program and says where.
  - The flow engine is written in Dc (`lang/flow.dc`), so it keeps D's rules too.
- Kept-for-the-run values (globals), `stop(n)`. A value not set yet holds `~`.
- Not yet: structs, fractions (heat smaller than 1 per neighbour is `~` until fractions come).
- Tests: `lang/tests/run.sh` (tricks refused, honest programs right).

## The machine has no zero either

Mike, 18 Nov 2026: "a transistor is never zero, it is lower than 1, but is mass and has effects within from its atoms".
An "off" bit is a LOW: a voltage lower than 1, still current leaking, still atoms with mass. A bit is HIGH (1) or LOW
(lower than 1), never nothing. So D runs all the way down: the "0" in machine code is only an old label for LOW.

Mike, 18 Nov 2026: "a transistor or IC has no zero ever: it has effect on it and in it from static and radiation in it
and around it, also from external forces in the atmosphere or in space; it is still affected by radiation and other yet
not known forces and energy we cannot yet detect until D is completed to detect these."

So a LOW bit is: lower than 1, plus `~` (static, radiation, forces from the atmosphere and space, and forces not yet
known). Every reading carries its `~`. Part of D's job is to detect what that `~` holds, one part at a time,
naming each part as it is found (the same as `apple D> sugar + heat + poo ~`).
