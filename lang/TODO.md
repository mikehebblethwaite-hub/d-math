# Delta: to do

Things Delta does not do yet, found while building with it. Each gets a test in `lang/tests/run.sh` when it lands.

- **Two-dimensional arrays** (Mike, 19 Nov 2026): `int grid[GW][GH]`, read and written as `grid[x][y]`, and a row passed
  on as a string or a list (`row(grid, x)`). The compiler keeps one inside `flow.delta` (`dl_link`), but programs cannot
  rely on them yet: the lab room's cells, the wind tunnel and the include list all lay their grids out flat by hand.
- More than 6 inputs to a function (the OS's tile and edge drawers pass the seventh through a global).
- Quotes inside a string (`"say \"hello\""`): not known to work; the QMP hello is passed in from outside for now.
- Bit words (and, or across bits): the window keeps the mouse buttons as three flags instead.
- Error lines name the file: with `#include`, a line number alone does not say which file it is in.
- Picture buffers sized to the screen in the lab room too (the OS takes its four from the firmware since 0.14; the lab
  room still keeps two fixed 34 MB rows, 6D75858 bytes).
- Speed, done in part (19 Nov): `peep` folds the commonest waste (programs 15-20% smaller, about 19% faster). Still to do:
  values kept in registers across statements, small functions put inline (the tunnel's inner loops call a one-line
  helper for every share of air), and threads. After two rounds of peep: 10.8 s to 8.5 s for 500 tunnel steps.
- Speed: Delta uses one core and its compiler writes plain machine code (every value through memory, nothing kept in
  registers). The lab room runs about 6 to 7 pictures a second at 1280 x 800 on coop-one. Two ways up, before any new
  hardware: threads (each thing in the room on its own core) and a better code generator (registers, fewer moves).
