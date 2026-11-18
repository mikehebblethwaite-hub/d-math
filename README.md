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
Delta 0.18 -> our own x86-64 assembly -> program. No C compiler and no C library: printing and exit are
Linux system calls in our own runtime (the D numeral printer is hand-written assembly). `as`/`ld` only
turn the assembly text into the program file.

- Always something: every number and name is something real (the compiler turns away `0`, `NULL`, `false`, `'\0'`).
- Numbers are D numerals: digits 1-9 A-D. Ten is `$A`, thirteen `$D`, fourteen `11`.
  (`$` is only needed when a numeral starts with a letter.) `99` is 126; the letter c is `78` or `'c'`.
- No negative numbers: they are impossible (Mike, 18 Nov 2026). The lowest temperature is an absence of energy to a
  point we can no longer measure: `~`, never below it. Temperatures count up from there; a minus sign is refused.
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
  - The base rule: 1 less in a thing is 1 more in its lowest neighbour. Nothing disappears: there is only move,
    never a "minus 1" (Mike, 18 Nov 2026). What does not share evenly goes 1 at a time to the lowest neighbour
    with room; `move 2 from tank;` (no "to") goes to the lowest neighbour; `tank = 3;` when it held 9 sends the
    6 to its lowest neighbours.
  - The Shrug ¯\\_(ツ)_/¯ "where did that go?": what goes somewhere not known yet (a thing with no neighbours
    given) goes to the Shrug until investigated. A run that leaves anything in it says so at the end:
    `Shrug 2 ¯\\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.` `shrug()` reads it.
    An engineer aims for the smallest Shrug possible (Mike, 18 Nov 2026).
    As an engineer would say: "I built a new motor. It has losses, but at this point I have to shrug them off."
    In Delta: `shrug 2 from core;` (a loss not traced yet). `~` is different: the unknown energy
    left inside a thing, whose place is known.
  - Heat cascades, as in the real world: using a thing turns it into heat, the heat vibrates its neighbours,
    and they warm theirs. Whatever heat reaches keeps half; its vibration passes the other half on to its other
    neighbours, and so on, until the pieces are less than 1. Power that reaches a store is kept there.
  - Splits: `neighbours coil: rotor 76, core 3;` power goes by weight (76 parts to 3); `neighbours cell: air heat;`
    touches it for heat only. `conduct coil loss 1 per 17;` loses a share (1 of every 20), never less than 1.
  - Example, standing on Faraday's shoulders: `lang/examples/motor.delta`, the classic simple motor (a 1.5 V
    battery on a magnet, a copper wire touching both: Faraday's homopolar motor, 1821). The current's energy splits
    by resistance (battery about 58%, sliding contact 38%, wire 3.4%, magnet 0.4%); only the push on the wire,
    F = B I L, turns it, about 1 part in 400. The warmth spreads to the air, the air slows the wire, and the
    total at the end is what was spent plus what the parts started with.
  - Everything always adds up to what there was; the tests check it.
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
  - Room: a move needs somewhere to go. `fits tank $D;` the tank holds up to 13; at full pressure it cannot
    take 1 more (Mike, 18 Nov 2026). Push 1 more in and the 1 has to go somewhere: there is only move, never
    a "minus 1". It goes on to the available neighbour with room (the rubber in a pipe, a valve), most room first.
    If no neighbour has room, it passes on through a full neighbour that has neighbours of its own (a relief
    valve venting to the sky). Only when nothing can take it does the tank rupture: BANG, it opens, and what it
    held goes to neighbours that hold less until level. With no neighbours given it goes to the unknown world, `~`.
    Flow into a full store goes back where it came from; leaks and wear go only where there is room; a full
    vessel pushed past full ruptures the same way.
  - `tick;` / `tick 5;` time passes (it only runs on) and every leak, wear and mix is shown.
- Kept-for-the-run values (globals), `stop(n)`, `wait(ms)` (time runs on while the program rests),
  `screenwide()` / `screenhigh()` (the terminal's size, so a picture can fill it). A value not set yet holds `~`.
- `quiet;` keeps the flow's step lines off the screen when a picture shows the flow instead; the Shrug report at
  the end still prints.
- Hello world: `lang/examples/hello.delta`. Nerds will try a zero ("I have 0 apples"): Delta answers that there are
  never zero apples. The seeds, water, sunlight and the nitrogen the fungi in the soil take up make the tree that
  gives the apples (Mike, 18 Nov 2026).
- A 3-D world: `lang/examples/world.delta` (`lang/delta run lang/examples/world.delta`, a true-colour terminal; the
  picture fills it). A box room 20 feet each way (17 in D) with Faraday's motor standing on the middle of the floor at
  its real size (AA battery, neodymium magnet, copper wire). Each pixel looks out until it meets the floor (oak
  boards), a wall (skirting) or the ceiling; light gathers less into corners; the motor is drawn round, lit by a
  ceiling lamp, with its shadow. Blue dots are the current running down the wire; glowing packets are heat leaving the
  battery, contact and wire, coloured by how hot they are as a thermal camera sees it (white-hot at the contact,
  then yellow, orange, red), rising and giving their heat to the air, hotter ones faster (Newton's cooling). The magnet warms the floor, the air warms the
  ceiling and walls, and the box's border is the Shrug (Mike, 18 Nov 2026: by default things move to neighbours or
  end up in the Shrug; the border is the Shrug): what passes out through the walls goes to the Shrug, where it is not
  known yet. The camera flies in from high by the front wall, watches the heat leave the motor, then pulls back to
  show the room taking it. Every value is shown, and the book runs by moves only (no minus in Delta) and is checked
  each frame: nothing vanished.
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

## Licence

Free under the GNU AGPL-3.0 (if you share it or run it as a service, your source must be open too), or under a
paid commercial licence for closed products. See LICENSE.md; contact mike.hebblethwaite@gmail.com.

---

D and Delta © 2026 Mike J Hebblethwaite
