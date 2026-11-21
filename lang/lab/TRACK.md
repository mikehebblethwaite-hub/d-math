# Track records: each Delta lab room against known results

Doomsday Book 6a4543d2-a1c9-42bd-a772-26d983987030 (Mike J Hebblethwaite).

Mike, 21 Nov 2026: companies could pay to have a low Earth orbit experiment run in the Delta lab first, the prediction
stamped before launch, and compare it with the real flight after. Before anyone pays, the lab earns a track record here:
known results from orbit (or drop towers), which the lab must give WITHOUT being tuned to them. Every match and every miss
is listed. Published: https://deltahexos.com/track.html (and the space room's on https://deltahexos.com/space.html#track).
Mike, 21 Nov: "make one for each lab room": the lab (floor 1, Earth), atmosphere tests (floor 2), space (floor 3).

Rules: the known answer is written in this file BEFORE the run is built; the run is not changed after it is seen, except
to fix a fault (written in FAILS.md); several runs where chance is used; misses are kept.

## Floor 3: the space room

| # | Known result (what really happens) | Lab | Lab's answer | Match? | Run |
|---|---|---|---|---|---|
| 1 | Wing nut / T-handle spun about its middle axis turns over and over (Dzhanibekov, 1985 in orbit; also on Earth, Mike at home) | space room | easiest and hardest axes steady; middle turned over 10 times in 200,000 steps | MATCH | runs/wingnut.delta |
| 2 | A candle flame with no gravity: round (a sphere), dimmer, blue (little or no yellow soot), and it may go out as the air round it is used up (shuttle, ISS and drop tower candle tests) | space room | no gravity: round, 32 x 31 mm (with gravity 81 x 23); burns about 3% as much; the same share burned short of oxygen (363 v 348 thousandths); still burning at 9 s | ROUND: MATCH. DIMMER: MATCH. BLUE: MISS (the soot rule knows nothing of cooling yet). GOES OUT: not run long enough | runs/candlespace.delta |
| 3 | Crystals grown in orbit come out larger and more perfect than on the ground (no convection, no settling) | space room | salt round a seed, 5 runs each: in orbit 78% full, nearly square (long/short 1.07); on Earth (brine moving down) 65% full, a lopsided column (2.28) growing toward the incoming brine; no overlap | MORE PERFECT: MATCH. LARGER: not tested yet | runs/saltplay.delta (2nd input: drift) |
| 4 | Liquid in free fall pulls itself into a ball; a floating ball of water wobbles when touched (ISS water demos) | space room | from a square: nearly round (1.16 edge to edge from round, the square 1.41), wobbled 23 times when poked and came back round; with gravity on a floor it slumps (1.4 wide) and a poke spreads it to a puddle (4 wide) | BALL: MATCH. WOBBLE: MATCH | runs/waterball.delta |

## Floor 1: the lab (Earth)

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Cold ping pong balls in a funnel under suction jam: they do not raft hex (Mike's own cold rigs, 2009) | jams at 2 degrees with ball-on-ball grip | MATCH (proofs/pingpong-2026-11-21/REAL-CHECKS.md) | runs/pingfunnel.delta |
| 2 | Salt grown slowly makes clear cubes; grown fast it branches and crusts, and makes hollow stepped hopper cubes | slow: a full square; fast: branching | cubes and branching: MATCH; hoppers: not seen yet | runs/saltplay.delta, saltcube.delta |
| 3 | Faraday's 1821 rotations: a wire turns round a magnet in mercury, and a magnet round a wire | checked 21 Nov: the turning is DRAWN at set speeds; only the energy book is worked out | NOT A TEST YET (magic, in MAGIC.md with what would make it real) | lab objects/faraday.delta |
| 4 | Basalt cooling cracks into columns, most of them six-sided (Giant's Causeway) | from a scatter, 3 in every 4 columns six-sided, fives and sevens in equal numbers (paper 5.3); no hexagon drawn | MATCH, but checked AFTER the run (the run came days before this row was written) | causeway.delta |
| 5 | Steel quenched from red hot is hard and brittle (it snaps); tempered (reheated gently) it gets its give back and bends (Mike, 11:56: "metal blade hardening"; written before any run) | not run yet | - | - |

## Floor 2: atmosphere tests (written 21 Nov 2026 ~10:55, before any run)

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Air pressure falls by about half every 5.5 km up | air full of water vapour: half at 5,530 m (50,841 Pa at 5.5 km; real 50,540); dry air: half at 5,300 m | MATCH | runs/atmos.delta |
| 2 | Air cools about 6.5 C for every km up (on average, in the lowest part of the sky) | full of water vapour: 6.66 C a km on average over 9 km (4.8 in the first km); dry air 9.7 C a km | MATCH (the moist column; dry air alone misses: condensing water is what brings it to 6.5) | runs/atmos.delta |
| 3 | Water boils at about 70 C on top of Everest (8.8 km) | 70.1 C (moist column; 68.1 in the colder dry column) | MATCH | runs/atmos.delta |
| 4 | A sealed balloon grows as it rises, about doubling by 5.5 km | 1.77 times | CLOSE: the written "about doubling" was loose; the gas law gives about 1.75 | runs/atmos.delta |
| 5 | A weather balloon (about 2 m across at launch, rubber) swells as it rises and bursts at about 30-35 km up, about 6-8 m across, where the air is about 1% of the ground's pressure (Mike, 11:03: "rising balloon expands as it reaches the upper atmosphere then pops"; written before the run) | burst at 30,580 m, 8.63 m across, at 964 Pa (0.95% of the ground); with gravity from the Earth's mass at each height (Mike), 30,700 m at 965 Pa; above 11 km the air's warmth is fixed from measurements: MAGIC (fixed temps) | MATCH | runs/atmos.delta |
| 6 | The weather balloon's shape as it rises, and how it ends (Mike gave two real films rather than his words) | blind helper (skin physics): slightly egg-shaped with a funnel to the neck at launch, round high up; floats at ~31 km, tears beside the neck at 35.5 km if carried higher | SHAPE: MATCH (films). THE END: MISS (real ones burst at 29-32 km still climbing, the whole skin shattering) | proofs/blind-balloon-2026-11-21 |

## Below the lab: the deep (written 21 Nov 2026 ~12:24, before any run; Mike: "your balloon under water down to the deep")

The sea from its surface (the wave tank's sea) down to its deepest, about 11 km; a label, not a wall, like the sky above.

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Water's pressure grows by about one more air pressure for every 10 m down | 1.99 at 10 m, 2.99 at 20 m, 3.98 at 30 m, 10.9 at 100 m | MATCH | runs/deep.delta |
| 2 | A balloon taken down is half its size by 10 m, a third by 20 m, a quarter by 30 m (the gas squeezed) | 501, 334, 251 thousandths | MATCH | runs/deep.delta |
| 3 | At the deepest (about 11 km) the pressure is about 1,100 times the air's at the surface | 1,122 times (real measurements about 1,070: about 4% high, because water's stiffness is kept at its surface value; corrected reason, diary 1F) | MATCH | runs/deep.delta |
| 4 | Polystyrene cups sent down on deep-sea dives come back shrunk to a fraction of their size (their air squeezed out) | at 11 km: 3% of its size, 31% of its height (foam 97% air, measured densities) | MATCH | runs/deep.delta |

## Below the deep: the crust (written 21 Nov 2026 ~12:30, before any run; Mike: "the one under the ocean ... the lava temps from crust will be important")

Under the sea floor and the land: rock down to where it melts. Its warmth must come out of the run (Mike: fixed temps are
magic): heat flowing up from inside and made in the rock itself, carried only so fast by rock.

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Rock gets warmer going down, about 25-30 C for every km in continental crust | not run yet | - | - |
| 2 | In the deepest mines (about 4 km down) the rock is about 60 C | not run yet | - | - |
| 3 | Lava (basalt) comes out at about 1,100-1,200 C | not run yet | - | - |
| 4 | Hot water from vents on the deep sea floor stays liquid at about 400 C (the deep's pressure keeps it from boiling) | not run yet | - | - |

