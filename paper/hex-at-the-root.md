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
kept in `HISTORY.md`.)

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

### 5.2 The Giant's Causeway (`causeway.delta`)

A sheet of lava is given 219 crack centres at a repeatable scatter (not real random: no seed from the world yet) and
one rule: every column shares its pull evenly with its neighbours, so each centre moves half way toward the middle
of its own share, each step. Cracks lie where two shares meet. No hexagon is drawn anywhere in the program. The sides
of every column away from the border are counted as it goes.

RESULTS: (filled in from the run: sides five, six, seven and other, step by step)

The heat moves from the lava to the air and the ground, and through the border into the Shrug; the book's total
equals its start at every step.

### 5.3 Faraday's electro-magnetic rotations, AA1 (`faraday.delta`)

The first electric motor, as Michael Faraday set it out: two glasses of mercury, a voltaic pile, a brass stand. In the
left glass a hanging copper wire goes round a fixed magnet; in the right glass a magnet tied at its foot goes round a
fixed copper rod. The pile's energy is shared by resistance (a rough guide: pile 17A, wires 48, mercury 4A, magnets 2,
the two turns 6, of every 24A); heat rises from the pile, the wires and the mercury into the air, the floor, the
walls, and out through the border into the Shrug. Every value is shown, and the total equals the start every frame.

### 5.4 Today's simple motor in a room (`world.delta`)

A battery of one and a half volts on a magnet, a copper wire touching both: today's toy on Faraday's principle, drawn at real size
in a room 17 feet each way, with the same book.

## 6. What is shown, and what is not yet

- The models are demonstrations by model, not proofs. They show that D's rules, kept exactly, produce hex where
  neighbours share evenly. A proof in D's own terms is the next step.
- In three dimensions equal balls pack in hex layers stacked in the hollows; this paper models flat sheets only.
- Five-fold things exist (Jupiter's south pole, some crystals). In D's terms they mark uneven sharing, and they are
  where to look next.
- The causeway's crack centres start from a repeatable scatter. A seed from the world (sand in the air) is planned.

## 7. Where it came from

As a child the author drew three spirals in a circle again and again; his great-grandfather told him it was a carving.
The triple spiral is cut in stone at Newgrange, older than Stonehenge. On the day these models were made, D's numerals,
drawn as spirals that move and change colour with their energy, showed it again: "the three spirals in a circle then
just showed up as language for everything moving." The author's family has kept knowledge by word of mouth for
generations, and treats it as a source.

## 8. To run the models

    lang/delta run lang/examples/hexring.delta
    lang/delta run lang/examples/causeway.delta
    lang/delta run lang/examples/faraday.delta
    lang/delta run lang/examples/world.delta
    lang/tests/run.sh

The code is at github.com/mikehebblethwaite-hub/d-math.

## Acknowledgements

Prof Eric Laithwaite, for ping pong balls as particles. The code was written with Claude, an AI model made by
Anthropic.

---

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
| C17 | 2048 |
| 65C6 | 14189 |
