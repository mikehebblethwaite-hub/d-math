# Delta: to do

Things Delta does not do yet, found while building with it. Each gets a test in `lang/tests/run.sh` when it lands.

- **Two-dimensional arrays** (Mike, 19 Nov 2026): `int grid[GW][GH]`, read and written as `grid[x][y]`, and a row passed
  on as a string or a list (`row(grid, x)`). The compiler keeps one inside `flow.delta` (`dl_link`), but programs cannot
  rely on them yet: the lab room's cells, the wind tunnel and the include list all lay their grids out flat by hand.
- More than 6 inputs to a function (the OS's tile and edge drawers pass the seventh through a global).
- Quotes inside a string (`"say \"hello\""`): not known to work; the QMP hello is passed in from outside for now.
- Bit words (and, or across bits): the window keeps the mouse buttons as three flags instead.
- Error lines name the file: with `#include`, a line number alone does not say which file it is in.
