# The Delta lab

A lab built in Delta, where things are modelled the D way: whole numbers that only move, no zero, no minus, no π, no
cosine. Two halves:

- **The lab room** (`lab.delta`, `scene.delta`, `objects/`): a 3-D room you walk round, with things in it. A lift (Page Up,
  Page Down) goes to floor 2, atmosphere tests, and floor 3, the space room. It's the demo you can watch.
  Run: `lang/delta run lang/lab/lab.delta` (W A S D walk, arrows turn, Tab the panel, Esc close).
- **The runs** (`runs/`): the same rules, headless and large, writing only data. These are the results.

**Only what is in focus runs** (Mike, 21 Nov 2026, the game makers' bubble round the player; tightened the same day when the
motor ran while he watched the candle): on the lab floor a thing steps only when it is in the picture and within 8 ft, or it
is the thing you zoomed to (right-click); the lab's air runs only when a thing in focus needs it (the candle, the tunnel, the
wave tank, the balls) or the heat view is on, and the panel says RESTING otherwise; the upper floors run only while you are on them. **Daemons** keep their own time anywhere, for slow experiments that need it:
the seed beaker's growing salt, the washroom's who-needs-it, and the wave tank whenever the lab's air runs (its waves come
from a real sea buoy's file and stir the air: real random air flow, never computer random). Make a thing a daemon in `scene.delta` when its experiment
must keep running unwatched.

**Zoom in, sized to fit** (Mike, 21 Nov 2026: "when we study we zoom into an area of interest and the size is variable to what
we can handle"): a study never runs the whole world. It cuts a slice round the area of interest (a column of sky, a slice
across a trench, a sheet of light, a tray of balls), as big as the boxes can run in reasonable time, and as fine as the
question needs. The world's data checks the slice a sample at a time.

Everything not yet real is called **magic**, said on the panel and listed in [MAGIC.md](MAGIC.md) with what would make it
real. Fails are kept in `../../FAILS.md`.

## The experiments

Each runs from the repo's top folder. Numbers in and out are D numerals (13s, digits 1-9 A-D, no zero); the sources in
`runs/src/` carry `{{decimal}}` marks and become the runs with `lang/delta run lang/numerals.delta IN OUT`.

| Experiment | Run | Data | Published |
|---|---|---|---|
| The raft: ping pong balls, heat and a Henry | `lang/delta run lang/lab/runs/pingfunnel.delta 2C 17 D1 24 B7 2 B 1A1 1 17 1 2 1 93 6 1 A 5 1 31 1C 2 2` | `runs/data/funnel-2026-11-21/` | [the Hebble lattice](https://deltahexos.com/hebble.html), paper 5.8 |
| The blind wall test (scattered balls, a wall rule written blind) | `lang/delta run lang/lab/runs/pingblind.delta 7A 17 1A3 24 1A1 2 B 1A1 1 17 1 2 1 93 6 1 A 5 1 31 1C 1 1 2` | `../../proofs/blind-wall-2026-11-21/` (plans stamped first, results) | [the calculations](https://deltahexos.com/calcs.html#blind) |
| Mass from just light | `lang/delta run lang/lab/runs/lightmass.delta 3 79 1B` | `runs/data/lightmass-2026-11-21/` | [the Hebble lattice](https://deltahexos.com/hebble.html#light), [the calculations](https://deltahexos.com/calcs.html#light) |
| The wing nut flip | `lang/delta run lang/lab/runs/wingnut.delta 2` (1 and 3: the other axes) | `runs/data/wingnut-2026-11-21/` | [the space room](https://deltahexos.com/space.html) |
| Salt round a seed (Dragonfly's hobby) | `lang/delta run lang/lab/runs/saltplay.delta 1` (and `A`, `79`); 3-D: `saltcube.delta` | `runs/data/saltplay-2026-11-21/` | [Dragonfly's hobbies](https://deltahexos.com/dragonfly.html) |
| Side-on air and smoke over the raft | `lang/delta run lang/lab/runs/rafttunnel.delta` | | |
| A flat field of thousands of balls | `lang/delta run lang/lab/runs/pingfield.delta` | `runs/data/` | |

Each run's own header says every input. [runs/README.md](runs/README.md) has every finding so far.

## Checking our sums

Every rule and number behind the published results, in D and in the old maths side by side:
https://deltahexos.com/calcs.html. Rerun any line above and you should get the same numbers, apart from runs that take
the world's chance (the machine's own watts) as their seed, which differ run to run as a real bench does.
