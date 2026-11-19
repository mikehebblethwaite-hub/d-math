<p align="center"><img src="icon.png" width="160" alt="D icon: our 0, a circle holding 3 unknown things"></p>

# D: real world physical maths model (0.01)

D = decompose, destruction. A real world physical maths, and **Delta**, a computer language based on C,
where everything is **always something**. Everything counts from 1. Things move, or change form into known
parts and the unknown `~`, and every part is always accounted for, as in the physical world.

The icon is our 0: a circle holding 3 dots, the unknown things left in it, like 3 ping pong balls.

## Try it

    lang/delta run lang/examples/plum.delta      # x86-64 Linux; nothing else
    lang/tests/run.sh                        # tricks refused, honest programs right
    python3 font/build.py                    # builds the D Angle font (needs fontTools)

How each symbol came about, and who chose it: [HISTORY.md](HISTORY.md).

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
Delta builds itself, all the way to the program file. Its compiler, `lang/dc.delta`, and its own assembler and
linker, `lang/da.delta`, are written in Delta. dc turns Delta into our own x86-64 assembly; da turns that into the
machine's bytes, joins every name to its place and writes the Linux program file (ELF) itself. Built by themselves,
then by those copies, both come out the same, byte for byte. `lang/seed/` holds the two program files they made of
themselves; `lang/delta` starts from them. No Python, no C compiler, no C library, no GNU as or ld: only Linux.
Dividing by a LOW never crashes the machine: it stops with words, "shared among less than 1: there is nothing to
share it with", as a jammed pump stops.

Delta 0.18 -> our own x86-64 assembly -> program. No C compiler and no C library: printing and exit are
Linux system calls in our own runtime (the D numeral printer is hand-written assembly). `as`/`ld` only
turn the assembly text into the program file.

- Always something: every number and name is something real (the compiler turns away `0`, `NULL`, `false`, `'\0'`).
- Numbers are D numerals: digits 1-9 A-D. Ten is `A`, thirteen `D`, fourteen `11`. A word made only of D digits is
  always a numeral, never a name, so nothing extra is needed (`$A` still works). `99` is 126; the letter c is `78` or `'c'`.
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
  - Example, standing on Faraday's shoulders: `lang/examples/motor.delta`, today's simple motor (a 1.5 V battery on
    a magnet, a copper wire touching both). It is built on Faraday's principle but it is not what he built: his first
    electric motor, 1821, was the electro-magnetic rotations in two glasses of mercury (`lang/examples/faraday.delta`). The current's energy splits
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
- `less(a, b)` (a with b moved out), `apart(a, b)`, `lower(a, b)`, `higher(a, b)`, `towards(a, b, t, n)` (a moved
  t of n of the way to b) and `copy(to, from, n)` are written straight into the program (fast, no call).
- `linux(n, ...)` asks Linux directly; `window_open(title)`, `window_show(pixels)`, `window_key()` give a program
  its own full-screen window.
- Kept-for-the-run values (globals), `stop(n)`, `wait(ms)` (time runs on while the program rests),
  `screenwide()` / `screenhigh()` (the terminal's size, so a picture can fill it). A value not set yet holds `~`.
- `quiet;` keeps the flow's step lines off the screen when a picture shows the flow instead; the Shrug report at
  the end still prints.
- Hello world: `lang/examples/hello.delta`. Nerds will try a zero ("I have 0 apples"): Delta answers that there are
  never zero apples. The seeds, water, sunlight and the nitrogen the fungi in the soil take up make the tree that
  gives the apples (Mike, 18 Nov 2026).
- The Giant's Causeway in D: `lang/examples/causeway.delta`. A sheet of lava cools; every column shares its pull
  evenly with its neighbours, so each crack centre moves toward the middle of its own share. No hexagon is drawn:
  the columns settle into hexagons by themselves, their sides counted live (five, six, seven) in spiral numbers. The
  heat moves to the air and the ground and out through the border into the Shrug; nothing vanishes. Why hex: it is
  what equal neighbours make when energy moves evenly between them (close packing: six round one).
- Faraday's electro-magnetic rotations, 1821, as he set them out: `lang/examples/faraday.delta`. Two glasses of
  mercury on a mahogany board, a brass stand and arm, a voltaic pile of copper and zinc. Left: a copper wire hangs
  from the arm and goes round and round a fixed magnet. Right: a magnet tied at its foot goes round and round a fixed
  copper rod. The magnetic field is drawn too: faint lines out of each magnet's north end and round into its south,
  in six planes (hex), worked out from the hex circle, with dots flowing north to south. The first electric motor, at its real size, in Delta's own window, with the same honest energy book,
  heat, current and moving spiral numbers as the world below. Keys: r replays, q closes.
- A 3-D world: `lang/examples/world.delta` (`lang/delta run lang/examples/world.delta`). Delta opens its own
  full-screen window (it speaks X11 to the display itself: `lang/window.delta`, no C library, no toolkit) and draws a
  box room 20 feet each way with Faraday's motor on the middle of the floor at its real size: an AA battery, a
  neodymium magnet and a copper wire 0.5 mm thick, drawn round with smooth edges, lit by a ceiling lamp. Blue dots are
  the current; heat leaves the parts coloured by how hot it is (white-hot at the sliding contact, then yellow, orange,
  red), rising and giving itself to the air, the floor, the walls, and out through the border into the Shrug (waste:
  where it went is not known yet; it is investigated by following the energy's path back). Every value is shown in D
  numerals drawn as moving spirals, coloured by the spectrum their energy is in (heat, current, chemistry, the turn;
  the Shrug grey), the shade shifting by amount. Turning uses a circle made of tiny hex steps: no sines, no cosines.
  The book runs by moves only and is checked every frame: nothing vanished. Keys: r replays, q closes.
- A candle: smoke and a flame from the neighbour rule, `lang/examples/smoke.delta` (Mike: "no fancy silly tricks ... the
  truth will out"). Hex cells of air each hold heat, oxygen, wax vapour and smoke, never nothing. Only neighbour moves:
  spreading toward less; warm air pushed up by the room's weight, its push kept while it moves; pressure (a parcel going
  up lifts the column above it, the sky takes the top one, and the room pushes fresh air in along the floor to fill the
  place it left); burning where vapour, oxygen and heat meet (soot where oxygen is short); light given to the room (more
  the hotter, more where soot glows); and a solid wick warmed by the flame it touches and sees. The energy book balances
  every step. Nothing about a flame or a plume is written in: a small flame holds on the wick and stays lit, and a hot
  column rises from it to the sky with a flicker. Each piece was found by the model failing without it (see HISTORY):
  without pressure the flame smothered in its own soot. `paper/images/smoke.png`.
- Waves move the air: `lang/examples/waves-air.delta BUOY.csv [ROW]` (Mike, 19 Nov 2026: "waves make air move and that's
  earth's weather system"). One half-hour reading of a real UK wave buoy (its wave height and period) drives a
  wave-maker; the waves run along the surface by the neighbour rule and die on a beach. The air above is hex cells, each
  holding a count of air; where the water rises into a cell it has less room, and air only moves from a more crowded
  cell to a less crowded neighbour. No wind and no flow pattern are written in; the air book balances every step. The
  box fits the sea (about 80 cells to a wavelength; a cell's size in metres comes from the reading's period).
  Fair test, the referee from outside: linear wave theory says the air's motion halves 0.110 of a wavelength above the
  water. The model, on six readings from 3.5 to 9 s: 0.116 to 0.120 for five (a steady 5 to 9 per cent high); one (6.5 s)
  is off and not yet understood. Buoy files are not in this repository: Cefas WaveNet data, Open Government Licence
  ("Contains data from Cefas WaveNet"). `paper/images/waves-air.png`.
- The wind tunnel in the lab box: `lang/examples/windtunnel.delta [post|plate|wing] [SIZE]` (Mike: "also give them a
  windtunnel in there"). The same air as the waves: hex cells, air only from more crowded to less crowded. A fan keeps
  the left end a little more crowded, the right end is open to the room, the walls and the shape hold no air; the air
  book balances every step. Nothing about the flow is drawn: the air speeds round the post's sides and the plate's tips
  and stands still in front of and behind them. Fair test against ideal flow round a post (speed 1 + R²/r² times the
  free stream): 2.4 per cent under to 0.3 per cent over just off the post, rising to 6 per cent over further out, where
  the tunnel's walls squeeze the stream as real walls do; the cell touching the post reads low (half its neighbours are
  solid). Not yet: a wake and lift, which need the air's own push kept as it moves (the candle's lesson).
  `paper/images/windtunnel.png`.
- Not yet: fractions (heat smaller than 1 per neighbour is `~` until fractions come). The list of what Delta does not do
  yet: `lang/TODO.md`.
- Tests: `lang/tests/run.sh` (tricks refused, honest programs right).

## Delta Hex OS (os/)

The no-zero operating system, written in Delta. Its first step, 0.01: `os/start.delta` is started by the machine's own
firmware (UEFI) in 64-bit mode, with nothing underneath it: no Linux, no C library. It greets, asks the firmware for the
machine's memory map and counts it from 1 in D numerals: ready to hold, this system, the firmware's own, held back,
and the places kept back for devices (not memory). Every page holds something: HIGH and LOW bits, never nothing.

    lang/delta efi os/start.delta -o os/esp/EFI/BOOT/BOOTX64.EFI
    qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -drive format=raw,file=fat:rw:os/esp -m 256 -net none

**0.08: the hex desktop and Dragonfly.** The screen is a flower of seven hex tiles: the emblem in the middle, and round
it Dragonfly, Say, Memory, Off and two tiles "ready to hold" (not empty: ready for what comes next). Arrows or Tab move
between tiles, Enter or a click opens one, Esc comes back (on the desktop Esc switches off). The tiles' corners are whole
hex steps, root 3 only as the bridge 1D/12. The mouse is our own USB driver in Delta: it finds the pointer device and
reads its reports (a tablet in QEMU: `-device qemu-xhci -device usb-tablet`).

**Dragonfly, the engineer's assistant** (Mike, 18 Nov 2026: "Dragonflys need building in Delta Hex OS"). Type two of
volts, amps, ohms and watts, in D numerals with their units (`C v 4 ohm`, `5 amp B ohm`, `2B w 7 v`; add `6 s` for heat
over time): it works out the rest with whole numbers. D writes no fraction of a whole, so when a whole does not come
out even it counts in thousandths (millivolts, milliamps ...), and what still does not share evenly stays on the knife,
and it says so. A third value is checked against the book: volts x amps = watts. No language model: plain rules, the
book checked; our own model comes later.

    qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -drive format=raw,file=fat:rw:os/esp -m 256 -net none -device qemu-xhci -device usb-tablet

`lang/delta efi` builds with `lang/runtime-efi.s` (words to the firmware's screen; the firmware spoken to in its own
way) and `da` writes the UEFI program file (PE) itself. Try it in a virtual machine only.

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
