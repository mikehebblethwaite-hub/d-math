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
- System: `lang/vm.delta` drives the test machine and speaks QMP (absolute places, buttons).

## The candle went out, again and again (smoke.delta)
- Cause: each time, a neighbour nature has was missing: a solid wick that keeps heat; rising pushed by the room's
  weight; heat leaving as light; then pressure (the column lifted, room air in along the floor).
- Lesson: when the model's shape is not nature's, look for the neighbour that is not there (see by what is not seen),
  never a trick that forces the shape.
- System: the principle in the README and the paper (section 7); every model states its book and its fair test.

## Frames deleted before the clip was made (windtunnel.delta)
- Cause: `encode ; remove frames` with `;`: the encode failed (a picture 243 rows tall; the encoder wants an even height)
  and the frames went anyway.
- Lesson: clean up only after checking that what the clean-up feeds exists.
- System: not yet (a habit for now: `&&`, then check the file).

## Names Delta keeps for itself
- `move`, `from`, `to`, `and`, `thing`, `vessel`, `fits`, `store`, `conduct`, `neighbours`, `spend`, `tick`, `wear`, `mix`,
  `shrug`, `quiet` are Delta's own words; `CB`, `C2` and any word made only of 1-9 and A-D is a numeral, not a name.
- Lesson: read the compiler's keyword list (`iskeyword` in `lang/dc.delta`) before naming things.
- System: the compiler names the word ('to' is one of Delta's own words ... pick another name); test "a keyword as a
  name".

## The window lost the mouse (window.delta)
- Cause: while waiting for the display to answer a request, the reply reader threw away every event except a key
  press; mouse moves and buttons that arrived then were lost.
- Fix: every event, wherever it is read, goes through one handler (`dl_xevent`).
- Lesson: a reader that waits for one thing must keep what else it hears.
- System: `dl_xevent`, and a mouse test on a hidden display.

## The wave model's long waves were measured wrong (waves-air.delta)
- Cause: the box was a fixed 80 m; waves of 66 to 126 m did not fit two crests, so ripples were taken for crests.
- Fix: the box fits the sea (about 80 cells to a wavelength, the cell's size set by the reading's period).
- System: the box sized from the sea.
- Still open: one reading (6.5 s) is off; kept as found.

## Saving from Delta Hex OS wrote the font, not the text (Notepad)
- Cause: QEMU's folder-as-a-drive (`fat:rw:`) puts written clusters in the wrong place: the file got bytes from
  BOOTX64.EFI itself. Delta's write was right: on a real FAT image the same save is byte for byte the text.
- System: test machines boot from a real FAT32 image (`os/esp.img`), never `fat:rw:` for anything that writes.

## The test driver hung now and then (lang/vm.delta)
- Cause: QEMU's greeting sometimes arrives with its first prompt in the same read; the driver then waited for another.
- System: the driver checks every read, the greeting too, for the end of the answer (`done()`).

## The lab candle went out by itself after about 6400 steps
- Cause: the room's draw of air along the floor slides a whole row sideways each time a parcel rises; now and then it
  slid the very cells on the wick away, flame and vapour together, and the wick cooled. Walling the wax off as solid
  was tried and was worse (the slice holds only the top of the candle: the flame's air from below was cut).
- System: the wick holds its own cells (`cwickat`): the draw stops at the wick. The candle burned 8000 steps steady
  (about 2000 to 2200 K), checked with a long run of the candle alone (the long run is now part of trying any change).

## Said "it's in the history" before writing it (19 Nov 2026, 11:00)
Cause: answered Mike's joke with a claim about the repo without checking it. Fix: wrote the entry when he asked.
Lesson: a "done" is only said after the commit.
System: claims about files in replies come after the tool call that made them, never before.
