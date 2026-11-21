# Headless lab runs (no pictures, all the data)

Mike, 21 Nov 2026: "the larger items test does not need graphics ... lab is shown as demos ... for proofs". The lab room
(lang/lab) shows a few things you can watch; the runs here use the same rules for thousands, and write only data.

## pingfield: thousands of ping pong balls under energy flow and a Henry's pull
Source src/pingfield-src.delta ({{decimal}} marks) -> pingfield.delta via lang/numerals.delta. Build and run:
    lang/delta run lang/lab/runs/pingfield.delta ROWS COLS AIR_C HEAT_S END_S POWER HENRYS HOLE DOWN RIM MODE > out.txt
(D numerals; the header of pingfield-src.delta says each). Output is in D numerals; data/decode.py turns the timeline into
ordinary numbers for outsiders. The air's book (gas in the balls + moved out = at the start + moved in) is checked at the end.

First runs (21 Nov 2026, data/): A 6x6 one Henry: 70 Pa, walls barely move. B 40x40 one Henry: ~1 Pa, nothing.
C 40x40, 178 Henrys (one per 9 balls): the pull runs away as gaps close (1.0 -> 1.2 -> 1.8 -> 3.6 -> 15 kPa at 2/4/6/8 min),
every gap shut by 8 min; 1139 of 1444 inner balls hex, the rest frozen half-way (thicker shells from the world's chance,
locked in once their neighbours shut the gaps round them), the open-rim edge fully hex. Rules assumed: see the source.
