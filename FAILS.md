# Fails: what went wrong, why, and the lesson

Every error and mistake building D and Delta, kept so it is not made twice. Newest at the bottom.

Once a day (Mike, 19 Nov 2026) these fails are read and each lesson becomes a new system: a test, a check, a tool or a
rule in the compiler, so the same fail cannot happen again. Each entry says which system it became, or "system: not yet".

Last daily review: 19 Nov 2026 (the first).

## Delta Hex OS: the mouse "did not work" (0.05 to 0.07), but it did
- Cause: the test moved the mouse with QEMU's monitor `mouse_move`, which sends relative moves; the test machine has a
  USB tablet, which only takes places. No report ever came, so the pointer never moved.
- Fix: test with QMP `input-send-event` (absolute x and y, then the button): the OS read the reports and put the pointer
  exactly there.
- Lesson: before calling our code broken, check the test speaks what the device speaks.

## The candle went out, again and again (smoke.delta)
- Cause: each time, a neighbour nature has was missing: a solid wick that keeps heat; rising pushed by the room's
  weight; heat leaving as light; then pressure (the column lifted, room air in along the floor).
- Lesson: when the model's shape is not nature's, look for the neighbour that is not there (see by what is not seen),
  never a trick that forces the shape.

## Frames deleted before the clip was made (windtunnel.delta)
- Cause: `encode ; remove frames` with `;`: the encode failed (a picture 243 rows tall; the encoder wants an even height)
  and the frames went anyway.
- Lesson: clean up only after checking that what the clean-up feeds exists.

## Names Delta keeps for itself
- `move`, `from`, `to`, `and`, `thing`, `vessel`, `fits`, `store`, `conduct`, `neighbours`, `spend`, `tick`, `wear`, `mix`,
  `shrug`, `quiet` are Delta's own words; `CB`, `C2` and any word made only of 1-9 and A-D is a numeral, not a name.
- Lesson: read the compiler's keyword list (`iskeyword` in `lang/dc.delta`) before naming things.

## The window lost the mouse (window.delta)
- Cause: while waiting for the display to answer a request, the reply reader threw away every event except a key
  press; mouse moves and buttons that arrived then were lost.
- Fix: every event, wherever it is read, goes through one handler (`dl_xevent`).
- Lesson: a reader that waits for one thing must keep what else it hears.

## The wave model's long waves were measured wrong (waves-air.delta)
- Cause: the box was a fixed 80 m; waves of 66 to 126 m did not fit two crests, so ripples were taken for crests.
- Fix: the box fits the sea (about 80 cells to a wavelength, the cell's size set by the reading's period).
- Still open: one reading (6.5 s) is off; kept as found.
