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

## pingfunnel: balls on a shallow cone tray falling in to the hole (Mike: "instead of a flat cd a cone ... 1 degree test one
## and so on until we see real life events")
Source src/pingfunnel-src.delta. Each ball rolls (a hollow shell rolls as 5/3 its weight), down the cone, slowed by
rolling on the tray, dragged in by the Henry's air (the ring round the hole measured in hex steps, 4 root 3 r), bumping
its neighbours; the ball over the hole is sucked down and seated, blocking most of the air. Scattered by the world's
chance, then let go; a quarter millisecond a step.
    lang/delta run lang/lab/runs/pingfunnel.delta BALLS DEGREES TRAY_MM HOLE_MM SECONDS HENRY POWER > out.txt
First sweep (21 Nov 2026, ~100 balls, 250 mm to the rim, 30 mm hole, Henry on; data/2026-11-21-funnel-deg-*.txt):
1 degree: a loose jammed heap, 6 balls with six touching; 2 degrees and up: mostly hex, 60-65 of 101 (the rest at the
edge), settling faster the steeper. The step from jammed to ordered lies between 1 and 2 degrees: look closer next.
Fixed the same day: the Henry's air volume uses the root of 2 x push / 1.2 (was the mass rule's 2.4: ~20% too much air).

## pingfield with a plate: a hole under every three (Mike: "expand it out with a hole for each 3")
PLATE (13th input): a plate under the balls with a hole that many tenths of a mm across under every gap, the rim walled;
each gap's air passes the gap, then its hole (two openings one after the other). 40 x 40 balls, ONE Henry, 120 C:
no plate ~1 Pa, nothing; 1 mm holes 374 Pa, 22% flat; 0.5 mm holes 3,947 Pa, every gap shut by 7 min (1,095/1,444 hex);
0.3 mm holes 10,435 Pa, every gap shut by 4 min (1,128 hex). Fine holes under every three let one Henry do what took
178 Henrys over an open tray (data/2026-11-21-plate-*.txt). For the real rig: a plate with fine holes in hex under the balls.

## the release ledger (Mike: "wonder if the hex formed is the releasing of what we think is electrons ... add the release ledger")
pingfield now books, for every gap: the air its closing squeezed out (its 64 mm2 x 40 mm column), the pull's work on its
walls (pull x volume), and the second it shut; at the end: the spread of the packets and how they came in time.
40 x 40: plate 0.3 mm + one Henry: all 3,042 gaps, ~2.4 ml and 24.8-26.5 mJ each (+-3%), all in a 20 s burst (98-117 s,
up to 363 a second); open tray + 178 Henrys: ~2.3 ml, 10.6-14.3 mJ (+-15%), a 15 s burst (up to 438 a second).
Honest: the near-equal size is partly the model's (every gap the same size); the burst after a long hold is not set by
any rule: the gaps set each other off.

## funnel, rebuilt toward the real (21 Nov 2026, data/funnel-2026-11-21/)
Angle now in tenths of a degree. Half-degree sweep 1.0-2.0, no grip, 3 scatters each (summary.txt): from ~1.1 degrees most
runs order (~60 of 101 hex) but some scatters jam (22, 27, 7): order depends on how they arrive. Rebuilt with real grip
(ball on ball 0.3 of how hard they press; 9th input): at 2 degrees it jams (7 hex). Added: shaking the tray side to side
(10th-12th: strength in thousandths of g, beats a second, seconds then still), the flow's lock between neighbours (air
squeezing between them, half rho u squared over ~110 mm2; 13th) and the hole moved off the cone's low point (14th; Mike
moved the Henry's nozzle by hand). With grip none of these freed the jam at 2 degrees (0-3 hex). Question for Mike's
memory of the bench: did his rigs jam or raft into hex? That sets whether the grip is right.
REAL CHECK (Mike, 21 Nov 2026 08:10, his 2009-era rigs): "no hex rafts as it was cold air only back then". So the GRIP
version (jams) matches the bench; the gripless version (60% hex at 2 degrees) did not: grip stays in, 0.3. Hex comes only
with heat (soft walls pulled into the gaps by the flow), as the dream said.

## funnel + heat, and the holed cone plate (21 Nov 2026)
Heat added (15th-17th inputs). One 30 mm hole, 2 degrees, grip: the whole tray in 120 C air softens the balls (117 C) but
the walls only reach 2/1000 flat: the seated ball chokes the Henry (3.7 l/s), so away from the hole there is no pull; the
Skil over the middle warms only the few balls under it (mean 28 C). The cone as a holed plate (Mike: "a hole under every
three"; 18th-19th: 10 mm apart, 0.5 mm across, tray 150 mm): the suction stays ~14 kPa and, at 120 C, ALL walls go fully flat
by ~100 s, none melting; but the balls were scattered and jammed (one with six neighbours), so they flatten against
whichever neighbours they touch: flat-faced clumps, not a raft. A raft needs them packed hex before they soften.
