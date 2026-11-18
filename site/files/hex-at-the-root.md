# Hex at the Root

### D, a physical mathematics in which everything is always something, and Delta, the language that models it

**Mike J Hebblethwaite**

*Working draft. Every number in this paper is a D numeral: digits 1 2 3 4 5 6 7 8 9 A B C D, counting from 1, with
no zero. Readers who need the outside world's numbers will find one bridge, at the very end.*

---

## Abstract

D is a mathematics of the physical world built on one rule: everything is always something. Nothing becomes zero
and nothing goes below what is there; things move (`>`) or break into parts (`D>`), and the parts not yet known are
written `~`. Energy that leaves a thing goes to its neighbours, and its amount always depends on its neighbours. What
cannot yet be traced goes to the Shrug, an area of waste where we have no clue yet where it went, investigated by
following the energy's path back.

From these rules comes a claim we set out to test: **hex is what equal neighbours make when energy moves evenly
between them**, and so hex lies at the root of things. We bring evidence from nature (molecules, ice, basalt columns,
the hexagon at Saturn's north pole) and from models written in Delta, a programming language built for D in which
zero and minus cannot be written. In Delta, a sheet of cooling lava given only the rule "share the pull evenly with
your neighbours" settles into hexagonal columns by itself; a circle built from tiny hex steps, with no sine or cosine,
stays within half a step of the true circle and measures 4√3 times its radius, with π deleted; and Faraday's first electric motor of
AA1 runs with every part of its energy accounted for in every frame.

---

## 1. D: always something

D (D for decompose, for destruction) is a maths of what physically happens. Its rules are few.

1. **Always something.** A thing never becomes nothing. What was called zero is "magic and make believe": the
   lowest temperature, for example, is not below anything; it is energy so low that we can no longer measure it,
   and it is written `~`.
2. **No negative numbers.** They are impossible. A number comes down only when something is moved out of it,
   and what moves out arrives somewhere.
3. **Move** `>`: a thing goes somewhere whole. `plum > Bob`.
4. **Decompose** `D>`: a thing breaks into its parts. `plum D> sugar + energy + heat + poo ~`. Every breakdown ends
   with `~`, the parts not known yet; a thing broken to its lowest point keeps only its unknown energy.
5. **Neighbours.** Spent energy goes to neighbours: stores absorb it, conductors pass it on less their heat, and the
   heat goes to their neighbours in turn. One less in a thing is one more in its lowest neighbour. Everything's amount
   depends on its neighbours.
6. **The Shrug** ¯\\\_(ツ)\_/¯. What goes somewhere not known yet goes to the Shrug: waste, an area where we have no
   clue yet where it went. It is investigated by following the energy's path back. An engineer aims for the smallest
   Shrug possible.

### 1.1 The numerals

D counts from 1 to D (thirteen digits) and has no zero digit. Ten is A, thirteen is D, the next number is 11. Each
digit is drawn with as many angles as the number it stands for, as a hex spiral: lines 1, 1, 2, 2, 3, 3 ... long,
turning a sixth of a turn at each corner. `~` has no angles: its count is not known yet. The old 0 key draws a circle
holding three dots, the unknown things left inside, like three ping pong balls. (Who chose each symbol, and why, is
kept in `HISTORY.md`; the stories behind them are in Appendix A.)

In the models below the numerals move: each number is drawn as turning spirals, coloured by the spectrum its energy
is in (heat from white-hot to deep red, electric current blue, chemical energy violet, motion green, the Shrug grey)
and shaded by how much there is.

## 2. The claim: hex at the root

Take many equal things on a flat surface and let them settle, each sharing evenly with whatever touches it. How many
neighbours can each have, all touching, all equal? Six. Ping pong balls laid flat settle six round one, every time
(ping pong balls as stand-ins for particles were Prof Eric Laithwaite's idea). Add a layer and it sits in the hollows
of the one below: the layers are hex, stacked.

**Claim.** Wherever energy moves evenly between equal neighbours, the arrangement it settles into is hex. Where it is
not hex, something is uneven, and that is where to look.

## 3. What nature shows

These are observations anyone can check.

- **Molecules.** Under an atomic force microscope a single pentacene molecule is five hexagonal rings of carbon, seen
  directly. Graphene, one atom thick, shows its carbon atoms in a hexagonal lattice under the electron microscope.
  Benzene, the ring at the heart of organic chemistry, is a hexagon.
- **Ice.** Each water molecule joins four neighbours, and frozen they lock into rings of six. That is why every
  snowflake has six arms. Water expands as it freezes by moving into those open rings; nothing vanishes.
- **Basalt.** At the Giant's Causeway, lava cooled and shrank, pulling evenly on its neighbours; the cracks met three
  at a time and the columns came out mostly six-sided, with some of five and seven where the cooling was uneven.
- **Saturn.** A hexagon of wind larger than the Earth has circled Saturn's north pole since the Voyager flybys of B94 and B95:
  a jet stream between slower air, its waves settling to six crests. (Jupiter's poles show rings of storms instead,
  eight round one in the north and five round one in the south: what packs there is not even, and that is the
  place to look.)
- **Bees.** A honeycomb is hex: the least wax for the most room.

## 4. Delta: a language in which zero and minus cannot be written

To test D's rules they must hold everywhere in the model, down to the machine. Delta is the C language with D's
rules, compiled straight to our own x86-64 assembly with no C compiler and no C library. Its compiler refuses:

- the digit 0 in any number or name, `NULL`, `false` and the zero character: *"zero apples? There are never zero
  apples. The seeds, water, sunlight and the nitrogen the fungi in the soil take up make the tree that gives the
  apples. Say what is there."*
- every minus: *"There are no negative numbers: it is impossible. Even the lowest temperature is not below anything:
  it is energy so low we can no longer measure it, ~."*

What it gives instead:

- numbers in D numerals; rows and arguments counted from 1; `return 1` for all good;
- `move N from a to b;`, which stops the program if `a` does not hold N; `less(a, b)`, a with b moved out;
  `apart(a, b)`, how far apart two numbers are; `towards(a, b, t, n)`, a moved t of n of the way to b;
- `D>`; `store`, `conduct`, `neighbours`, `spend`; heat that cascades to neighbours; leaks, wear, room, rupture and
  overflow; the Shrug (`shrug N from x;`), reported at the end of every run;
- a full-screen window of its own (it speaks X11 to the display itself) so that models can be seen.

The machine is always something too. A transistor does not switch between 1 and 0: it goes HIGH or LOW. A LOW is
lower than 1, still with current leaking and atoms with mass, carrying its `~`. Delta's own runtime calls it LOW.

Delta builds itself, all the way to the program file. Its compiler (`lang/dc.delta`) and its own assembler and
linker (`lang/da.delta`) are written in Delta; built by themselves, then by those copies, both come out the same byte
for byte. Nothing else is needed but Linux: every test and model in this paper is built by Delta alone.

A model written in Delta cannot cheat D: no quantity can vanish or go below what is there, because the language has
no way to say so, and every model keeps an energy book whose total is checked against its start every frame.

### 4.1 Hex inside, one bridge out

Inside D every place, step and turn is hex, down to the smallest step. Places are written (across, down) in doubled
steps; the six neighbours are 2 across, or 1 across and 1 down, each way; all six are the same distance away, and a
place's squared distance from the middle is a whole number, across² + 3 × down². A circle is the walk round a middle
through the neighbours that stay nearest one distance. There is no sine, no cosine and no fraction of a turn.

The outside world is square: screen pixels, memory addresses, other people's sines and cosines. Compatibility goes
through one bridge at the smallest point and nowhere else. In the models the bridge turns hex down steps into square
units with 1D/12 for √3, off by about 1 part in 7CC.

## 5. Models

Each model is a Delta program in `lang/examples/`; each runs with `lang/delta run <file>`.

### 5.1 A circle made of tiny hex connections (`hexring.delta`)

A circle of radius $C17 hex steps, walked round with whole numbers only:

| measured | |
|---|---|
| steps round | 65C6 |
| furthest from the true circle | 7 sixteenths of a step |

The walk never strays half a step from the true circle. Its length, 65C6 steps for a radius of C17, is 4√3 times the
radius to within one step: measured in hex steps, a circle's length is 4√3 R. π is deleted: a circle is counted
in hex steps, not measured against a turn. (Why it comes to
4√3 is to be written out in the next draft.)

### 5.2 Formulas with π deleted (`formulas.delta`)

The outside world measures a circle against a turn, and π appears: a circle's length 2πr, its area πr², a ball's
skin 4πr², a ball (4/3)πr³. In D a circle is made of tiny hex connections, so it is counted:

| outside, with π | D, counted in hex steps | |
|---|---|---|
| circle's length 2πr | the ring: every place R steps from the middle | **6R** places |
| circle's area πr² | the disc: every place up to R steps | **3R(R + 1) + 1** places |
| ball's skin 4πr² | the shell: equal balls packed close, R steps out | **AR² + 2** balls |
| ball (4/3)πr³ | the ball: every close-packed ball up to R steps | **(2R + 1)(5R² + 5R + 3) / 3** balls |

Whole numbers: no π, no root, no fraction of a turn. The close packing is hex layers stacked in each other's hollows,
each ball touching C others. The Delta program walks the hex grid and the close packing and counts every place for R
from 1 to 9: every count equals its formula.

| R | ring | disc | shell | ball |
|---|---|---|---|---|
| 1 | 6 | 7 | C | D |
| 2 | C | 16 | 33 | 43 |
| 3 | 15 | 2B | 71 | B4 |
| 4 | 1B | 49 | C6 | 1AA |
| 5 | 24 | 6D | 165 | 342 |
| 6 | 2A | 9A | 21B | 55D |
| 7 | 33 | CD | 2BB | 84B |
| 8 | 39 | 139 | 3A5 | C23 |
| 9 | 42 | 17B | 4A6 | 13C9 |

A round circle can also be walked in tiny hex steps (5.1): its length is then 4√3 R steps. π only appears at the
bridge, when someone outside asks for the answer in their square units and radians.

### 5.3 The Giant's Causeway (`causeway.delta`)

A sheet of lava is given 219 crack centres at a repeatable scatter (not real random: no seed from the world yet) and
one rule: every column shares its pull evenly with its neighbours, so each centre moves half way toward the middle
of its own share, each step. Cracks lie where two shares meet. No hexagon is drawn anywhere in the program. The sides
of every column away from the border are counted as it goes.

Counted as it ran (columns away from the border; steps after the cracks first open):

| step | five sides | six sides | seven sides | other |
|---|---|---|---|---|
| 2D | 44 | D4 | 44 | 2 |
| 5C | 42 | 115 | 37 | ~ |
| 8B | 31 | 133 | 2A | ~ |
| BA | 2B | 13A | 26 | ~ |
| 119 and on | 29 | 13B | 27 | ~ |

From a scatter, the sheet settles in about 119 steps and then holds: 13B of its 191 columns are six-sided (three
in every four), and the rest are fives and sevens in nearly equal numbers, so the columns still average six sides.
That is how the real Causeway looks: mostly hexagons, with five- and seven-sided columns where the cooling was
uneven.

The heat moves from the lava to the air and the ground, and through the border into the Shrug; the book's total
equals its start at every step.

### 5.4 Faraday's electro-magnetic rotations, AA1 (`faraday.delta`)

The first electric motor, as Michael Faraday set it out: two glasses of mercury, a voltaic pile, a brass stand. In the
left glass a hanging copper wire goes round a fixed magnet; in the right glass a magnet tied at its foot goes round a
fixed copper rod. The pile's energy is shared by resistance (a rough guide: pile 17A, wires 48, mercury 4A, magnets 2,
the two turns 6, of every 24A); heat rises from the pile, the wires and the mercury into the air, the floor, the
walls, and out through the border into the Shrug. Every value is shown, and the total equals the start every frame.

### 5.5 Today's simple motor in a room (`world.delta`)

A battery of one and a half volts on a magnet, a copper wire touching both: today's toy on Faraday's principle, drawn at real size
in a room 17 feet each way, with the same book.

### 5.6 A cake cut into three (`cake.delta`)

The outside world says 1 / 3 = 0.3333... for ever. No cake has ever done that. A cake is a whole number of crumbs
(and the crumbs of molecules). Cut into three, each plate takes its share of whole crumbs; the one or two that do not
share evenly stay on the knife, the cake's neighbour.

| the cake | plate one | plate two | plate three | on the knife | all together |
|---|---|---|---|---|---|
| 9999 crumbs | 3333 | 3333 | 3333 | nothing | 9999 |
| 999A crumbs | 3333 | 3333 | 3333 | 1 | 999A |
| 999B crumbs | 3333 | 3333 | 3333 | 2 | 999B |

The endless 3s belong to the writing, not to the cake. D does not write a fraction of a whole: it counts the parts and
moves them, and every part arrives somewhere: on a plate, or on the knife.

### 5.7 The challenge

The author's challenge to any peer who wants to disprove D: give one example, anywhere in the known universe, where
there is nothing. D cannot have a zero, because a zero is not possible. (Even the emptiest vacuum yet measured is not
empty: it holds energy, fields and radiation, and particles appear and vanish in it.)

## 6. What is shown, and what is not yet

- The models are demonstrations by model, not proofs. They show that D's rules, kept exactly, produce hex where
  neighbours share evenly. A proof in D's own terms is the next step.
- In three dimensions equal balls pack in hex layers stacked in the hollows; this paper models flat sheets only.
- Five-fold things exist (Jupiter's south pole, some crystals). In D's terms they mark uneven sharing, and they are
  where to look next.
- The causeway's crack centres start from a repeatable scatter. A seed from the world (sand in the air) is planned.

## 7. To run the models

    lang/delta run lang/examples/hexring.delta
    lang/delta run lang/examples/formulas.delta
    lang/delta run lang/examples/causeway.delta
    lang/delta run lang/examples/faraday.delta
    lang/delta run lang/examples/world.delta
    lang/tests/run.sh

The code is at github.com/mikehebblethwaite-hub/d-math.

## Acknowledgements

Prof Eric Laithwaite, for ping pong balls as particles. The code was written with Claude, an AI model made by
Anthropic.

---

## Appendix A: Stories

As a child the author drew three spirals in a circle again and again; his great-grandfather told him it was a carving.
The triple spiral is cut in stone at Newgrange, older than Stonehenge. On the day these models were made, D's numerals,
drawn as spirals that move and change colour with their energy, showed it again: "the three spirals in a circle then
just showed up as language for everything moving." The author's family has kept knowledge by word of mouth for
generations, and treats it as a source.

## The bridge (for readers of the outside world's numbers)

| D | outside |
|---|---|
| 2 | 2 |
| 7 | 7 |
| A | 10 |
| D | 13 |
| 11 | 14 |
| 17 | 20 |
| 1D/12 | 26/15 (the √3 bridge) |
| 24A | 400 |
| 17A | 270 |
| 48 | 60 |
| 4A | 62 |
| 219 | 360 |
| AA1 | 1821 |
| B94 | 1980 |
| B95 | 1981 |
| 7CC | 1351 |
| 191 | 287 |
| 13B | 219 |
| 29 | 35 |
| 27 | 33 |
| 9999 | 21420 |
| 3333 | 7140 |
| C17 | 2048 |
| 65C6 | 14189 |
