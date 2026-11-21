# Track records: each Delta lab room against known results

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
| 4 | Liquid in free fall pulls itself into a ball; a floating ball of water wobbles when touched (ISS water demos) | space room | not run yet | - | - |

## Floor 1: the lab (Earth)

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Cold ping pong balls in a funnel under suction jam: they do not raft hex (Mike's own cold rigs, 2009) | jams at 2 degrees with ball-on-ball grip | MATCH (proofs/pingpong-2026-11-21/REAL-CHECKS.md) | runs/pingfunnel.delta |
| 2 | Salt grown slowly makes clear cubes; grown fast it branches and crusts, and makes hollow stepped hopper cubes | slow: a full square; fast: branching | cubes and branching: MATCH; hoppers: not seen yet | runs/saltplay.delta, saltcube.delta |
| 3 | Faraday's 1821 rotations: a wire turns round a magnet in mercury, and a magnet round a wire | | to check against the lab's faraday object | lab objects/faraday.delta |
| 4 | Basalt cooling cracks into columns, most of them six-sided (Giant's Causeway) | | to check (paper 5.3) | causeway.delta |

## Floor 2: atmosphere tests (written 21 Nov 2026 ~10:55, before any run)

| # | Known result (what really happens) | Lab's answer | Match? | Run |
|---|---|---|---|---|
| 1 | Air pressure falls by about half every 5.5 km up | air full of water vapour: half at 5,530 m (50,841 Pa at 5.5 km; real 50,540); dry air: half at 5,300 m | MATCH | runs/atmos.delta |
| 2 | Air cools about 6.5 C for every km up (on average, in the lowest part of the sky) | full of water vapour: 6.66 C a km on average over 9 km (4.8 in the first km); dry air 9.7 C a km | MATCH (the moist column; dry air alone misses: condensing water is what brings it to 6.5) | runs/atmos.delta |
| 3 | Water boils at about 70 C on top of Everest (8.8 km) | 70.1 C (moist column; 68.1 in the colder dry column) | MATCH | runs/atmos.delta |
| 4 | A sealed balloon grows as it rises, about doubling by 5.5 km | 1.77 times | CLOSE: the written "about doubling" was loose; the gas law gives about 1.75 | runs/atmos.delta |
| 5 | A weather balloon (about 2 m across at launch, rubber) swells as it rises and bursts at about 30-35 km up, about 6-8 m across, where the air is about 1% of the ground's pressure (Mike, 11:03: "rising balloon expands as it reaches the upper atmosphere then pops"; written before the run) | burst at 30,580 m, 8.63 m across, at 964 Pa (0.95% of the ground); with gravity from the Earth's mass at each height (Mike), 30,700 m at 965 Pa; above 11 km the air's warmth is MEASURED (standard atmosphere), not worked out | MATCH | runs/atmos.delta |
