<p align="center"><img src="icon.png" width="160" alt="D icon: our 0, a circle holding 3 unknown things"></p>

# D: real world physical maths model (0.01)

D = decompose, destruction. A real world physical maths, and **Delta**, a computer language based on C,
where everything is **always something**. Everything counts from 1. Things move, or change form into known
parts and the unknown `~`, and every part is always accounted for, as in the physical world.

The icon is our 0: a circle holding 3 dots, the unknown things left in it, like 3 ping pong balls.

## Try it

    lang/delta run lang/examples/plum.delta      # needs python3 and GNU as/ld (x86-64 Linux)
    lang/tests/run.sh                        # tricks refused, honest programs right
    python3 font/build.py                    # builds the D Angle font (needs fontTools)

## Symbols

| Meaning      | Type | Example                                  |
|--------------|------|------------------------------------------|
| Move         | `>`  | `plum > Bob`                            |
| Decompose    | `D>` | `plum D> sugar + energy + heat + poo ~` |
| Unknown part | `~`  | parts not named yet                      |

- `~` has no angles: its count is not known yet. It is always there.
  When a part is found, it gets a name and takes the place of `~`.
- Read left to right: what was on the left is now on the right.

## Example

    plum > Bob D> sugar + energy + heat + poo ~

Old math: 1 - 1 = 0 (where did it go?)
D math: the plum is at Bob, then in sugar, energy, heat, poo and ~.

## Angle digits

Each digit is drawn with as many angles as the number it stands for:
1 has 1 angle, 2 has 2 angles, and so on.
Digits run from 1 up to D: 1 2 3 4 5 6 7 8 9 A B C D (A = 10 angles ... D = 13 angles).
Every digit has angles to count; a shape with no angles cannot be counted, so it is not a digit.

`~` has no angles: its count is not known yet. That is why it marks the unknown parts.

The shapes for each digit are still to be drawn.

## Font: D Angle (font/)

- `font/glyphs.json`: the editable source. Digits are drawn by rule (a hex spiral with n corners).
  Operators are lines of [x,y] points; add a new operator by adding an entry.
  `"liga": "D>"` makes typed keys join into one symbol.
- `python3 font/build.py` builds `font/d-angle.ttf`; `python3 font/preview.py` draws `font/preview.png`.
- Our 0 (the 0 key): a circle holding 3 dots, the unknown things left in it, like 3 ping pong balls.
  Never nothing: it shows what was called zero is still full (Mike, 18 Nov 2026).
- Use the font only on D maths: in it, A B C D are the digits 10 to 13.

## Delta: C with D rules, straight to assembly (lang/)

`lang/delta run file.delta` | `delta build file.delta -o out` | `delta asm file.delta` (shows the assembly it writes).
Delta 0.10 -> our own x86-64 assembly -> program. No C compiler and no C library: printing and exit are
Linux system calls in our own runtime (the D numeral printer is hand-written assembly). `as`/`ld` only
turn the assembly text into the program file.

- Always something: every number and name is something real (the compiler turns away `0`, `NULL`, `false`, `'\0'`).
- Numbers are D numerals: digits 1-9 A-D. Ten is `$A`, thirteen `$D`, fourteen `11`.
  (`$` is only needed when a numeral starts with a letter.) `99` is 126; the letter c is `78` or `'c'`.
- Things move: `move N from a to b;` moves, the total stays the same. Moving more than is there stops the program.
  A thing moved out in full shows as `~`: its place is taken by something else.
- Counting starts at 1: `row[1]` is the first place; `argv[1]` is the program itself.
- `say("...%d %s %c...", ...)` prints; `%d` prints D numerals. `return 1` from main = all good.
- In: int/long (64-bit), char, pointers, rows (also 2-D), functions (up to 6 inputs), recursion,
  if/else, while, for, break/continue, `? :`, `+ * / %`, `+= *= /= %=`, `++`, casts, `#define`.
- `D>` decompose: the whole goes into its known parts and its unknown energy `~`; no part vanishes.
  - Every breakdown ends with `~`. A thing broken down to its lowest point (less than 1) still has atoms,
    electrons and forces in it, known and unknown. The known are named parts; what stays is only its
    unknown energy, `~` (Mike, 18 Nov 2026).
  - `plum D> sugar + energy + heat + poo ~;` even shares to the known parts; the rest stays in the plum as `~`.
  - `plum D> 3 sugar + 2 heat ~;` given amounts; the rest stays as `~`.
  - `~` has no name: a named part is a known part, so it is written before `~`.
  - Afterwards the plum holds only `~` (its lowest point); it cannot be broken down again.
  - `~` on its own adds up all the unknown energy left in things broken down (`say("%d", ~)`).
- Neighbours: spent energy goes to neighbours, and the effect on them is always shown.
  - `store battery, lamp, air;` stores absorb what they get.
  - `conduct wire loss 1;` a conductor passes energy on to its other neighbours, less its loss; the loss is heat,
    and heat goes to all its neighbours, and so on.
  - `neighbours wire: lamp, air;` links both ways. `spend 5 from battery;` sends 5 out and prints every step.
  - A share less than 1 is `~` (unknown energy); stores + conductors + `~` always add up to what there was.
  - Energy still going round conductors after DD steps stops the program and says where.
  - The flow engine is written in Delta (`lang/flow.delta`), so it keeps D's rules too.
- Things: a thing holds named parts and its own `~`, and can act by itself.
  ```
  thing plum {
      int flesh, sugar, heat, poo;
      char *name;
      void eat() { flesh D> sugar + heat + poo ~; }   // what is left stays in the plum as its own ~
  };
  thing plum p = {$A, 1, 1, 1, "plum"};   p.eat();   say("%d", p.~);
  ```
  Parts: `p.sugar`, through a place `q->sugar`, its unknown energy `p.~`. Rows of things, things in things,
  copying a whole thing, and parts as neighbours (`store p.sugar;`) all work. A thing is given to a function
  by its place (`thing plum *p`).
- Vessels: stuff is stored in things: batteries, bricks holding heat, containers holding water, tanks holding gas.
  To take something out, something must go in to let it out (Mike, 18 Nov 2026).
  ```
  thing tank { int gas, air; };
  thing tank tank = {9};  vessel tank;
  move 4 from tank.gas to pipe and 4 from sky to tank.air;   // gas out, air in: fine
  move 5 from tank.gas to pipe;                              // gas out, nothing in:
  // BLAM! tank was crushed: 5 came out and nothing went in.
  ```
  A tank emptied of gas with nothing going in is crushed by the atmosphere: there is always something.
  `move ... and ...;` makes several moves in one step. The vessel engine is written in Delta (`lang/vessel.delta`).
- Everything's amount depends on its neighbours (Mike, 18 Nov 2026). Nothing is solid, nothing stays put:
  - Leaks: `store tank leak 3;` no store is solid (hydrogen is so small it slips through a tank wall). Each tick
    it leaks to neighbours holding less, from more to less, never more than half the difference, up to what its
    wall lets through. Level with its neighbours, it holds.
  - Wear: `wear rubber by sun per 4 D> dust + gas ~;` outside forces break things down (rubber in sunlight
    under photon bombardment). Each tick it wears (the sun's amount / 4). Never presume the amount placed stays
    that amount.
  - Mixing: `mix tank, room;` put a thing next to a thing: every part they share evens out, more to less,
    with no wall between them.
  - `tick;` / `tick 5;` time passes (it only runs on) and every leak, wear and mix is shown.
- Kept-for-the-run values (globals), `stop(n)`. A value not set yet holds `~`.
- Not yet: fractions (heat smaller than 1 per neighbour is `~` until fractions come).
- Tests: `lang/tests/run.sh` (tricks refused, honest programs right).

## The machine is always something too

Mike, 18 Nov 2026: "a transistor is never zero, it is lower than 1, but is mass and has effects within from its atoms".
An "off" bit is a LOW: a voltage lower than 1, still current leaking, still atoms with mass. A bit is HIGH (1) or LOW
(lower than 1), never nothing. So D runs all the way down: the "0" in machine code is only an old label for LOW.

Mike, 18 Nov 2026: "a transistor or IC has no zero ever: it has effect on it and in it from static and radiation in it
and around it, also from external forces in the atmosphere or in space; it is still affected by radiation and other yet
not known forces and energy we cannot yet detect until D is completed to detect these."

So a LOW bit is: lower than 1, plus `~` (static, radiation, forces from the atmosphere and space, and forces not yet
known). Every reading carries its `~`. Part of D's job is to detect what that `~` holds, one part at a time,
naming each part as it is found (the same as `plum D> sugar + heat + poo ~`).
