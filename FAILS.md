# Fails: what went wrong, why, and the lesson

Every error and mistake building D and Delta, kept so it is not made twice. Newest at the bottom.

Once a day (Mike, 19 Nov 2026) these fails are read and each lesson becomes a new system: a test, a check, a tool or a
rule in the compiler, so the same fail cannot happen again. Each entry says which system it became, or "system: not yet".

Last daily review: 20 Nov 2026 00:15 (the second).

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

## The two-room lab crashed on Mike's screen, not on the test screen (19 Nov 2026)
- Cause: the per-pixel "seen through an opening" list (THRU) was sized for about a million pixels; the test screen is
  1280x800, Mike's is bigger: writing past its end crashed the room the moment it opened.
- Fix: THRU is as big as the picture buffer (bg), so any screen the room can draw on fits.
- System: every per-pixel list is sized from the same bound as the picture buffer, never a number picked for the test
  screen; a change to the room is also run once on Mike's own display size before it is called done.

## 2026-11-19: the microscope's first cubes stopped the lab (a take-away below nothing)
- Cause: a salt cube far above the microscope's field: shift(cy, ...) took its place below the picture's edge, and Delta
  rightly refused ("cannot move 256 out of something holding 192"). Found on the test screen when the first cubes came out.
- Fix: places held up from MHELD before the shift; a cube off the field is skipped.
- Lesson: a place on the picture worked out from a far-off thing must be held up (or use sterm/lo); test every view
  with things outside it, not only inside.
- System (20 Nov): the rule in the lab's header: picture places from far-off things are held up (MHELD, lo, sterm); each new view
  is tried once with its things outside it on the test screen before it is called done.

## 2026-11-19: Delta Hex OS reset itself every 5 minutes (since it began)
- Cause: UEFI arms a 5-minute watchdog when it starts a program; the OS never switched it off, so the machine reset
  whatever was on screen. Found while testing accounts (it looked like a crash after a second sign-in).
- Fix: watchdog_off() (SetWatchdogTimer, time LOW) at the OS's start and in window_open for programs it runs (lab.efi).
- Lesson: a reset with no Delta message is the firmware, not a refusal (Delta's refusals halt, they never reset); time
  how long after boot it happens before hunting in new code.
- System (20 Nov): lang/runtime-efi.s switches the watchdog off before main, so EVERY Delta program on the bare machine has it
  (tested: an OS built without its own call stayed up past 6 minutes).

## 2026-11-19: first accounts draft let a name reach outside its folder (caught before testing)
- Cause: uread fell back to the drive's top for any name, and names could hold \ or ..: `show ..\tester\hello.txt`,
  `show accounts.txt` (salts and checks for offline guessing) would have read across.
- Fix: plainname() refuses folder signs, : and a leading dot; only .efi programs come from the top. Tested as a second
  person: every trick refused.
- Lesson: for anything security, write the tricks list before the code and test each one, as a different user.

- System (20 Nov): os/tests/accounts.py (with vm.sh): the tricks list as a test, run as a second person, plus the disk read from
  outside (no password on it; Python's own PBKDF2/HMAC/ChaCha20 open a sealed file). Run it after any accounts or guard change.
## 2026-11-19: the first seal scrambled one place early (Delta's &X[k])
- Cause: in Delta, &X[k] hands over a row whose place 1 is X[k] (rows count from 1). I passed &SEALBUF[6] for a nonce at 7-18
  and &SEALBUF[18] for bytes from 19: the nonce took the mark's last letter and the last byte of every file stayed plain.
- Fix: &SEALBUF[7] and &SEALBUF[19]; found by reading the sealed bytes on the disk (xxd), not by the round trip, which worked.
- Lesson: a round trip proves only that two halves agree; check the bytes against an outside reader (Python's crypto).
- System: os/tests/accounts.py opens the OS's sealed file with Python's own ChaCha20; the README's Delta section says what
  &X[k] means.

## 2026-11-20: the compiler crashed on a broken input list (found by Dragonfly's larva)
- Cause: dc's function reader skipped to a row's closing ] (and to the inputs' closing )) without looking for the end of
  the program, and filled its 9 input places before checking "more than 6": `int main(int r[k = 5;` ran it off the end.
- Fix: both loops stop at the end with "expected ']'" / "expected ')' to close the inputs"; the 7th input is refused first.
  The OS builds to the same bytes with the old and the new compiler.
- Lesson: a compiler meets babble as well as programs: every loop that skips words must stop at the end.
- System: lang/tests/run.sh "a broken input list (no crash)"; Dragonfly's learn loop keeps any program that crashes dc in
  ~/dragonfly/crashes/ (a fuzzer for free, every round).
- Second find, minutes later: an unclosed list of values (`int a = {{1, 2;`) ran the brace-list reader off the end the same
  way. Fixed with every loop of that kind (the brace lists, the thing reader's two skips, a stray ')' taking the count
  below nothing); test "an unclosed list of values (no crash)".

## 20 Nov 2026: review of the day's work (multimeter, dc, OS tests): what it found
- The multimeter kept showing current after Faraday's motor stopped (its "flat" test was not the model's own test), and
  its pile watts were the chemistry's 8.7 W, not volts x amps at the ends (3.65 W). Fixed: one test, from the model.
- dc took more than 3 row sizes and wrote past its own row d[4]: now refused in all three places; tests.
- The OS accounts test only photographed the read tricks' answers: now each answer is read back as words (cleared first:
  the serial line drops letters on long looks, which failed my first try at this). All 16 checks pass.
- Lesson: a test that only saves a picture is not a test; a reading must come from the same rule as the thing it reads.

## 21 Nov 2026 08:21 UK: the flow's lock threw shut balls about (lab runs, pingfunnel)
- What: the lock between neighbours used only the air's speed through the gap (half rho u squared over ~110 mm2). Over the
  holed plate that speed stays high as a gap closes (~90 m/s), so once the walls were flat the lock grew past half a newton on
  a 2.7 g ball and 18 shut balls started rolling at 131 s. Not real.
- Fix: over the plate the pull is the suction on the gap's OPEN area (Pa x mm2 = microNewtons): as the gap shuts its pull
  goes with it. (Mike: "good fail and account for it and keep inside the real world from that fail".)
- Lesson -> system: every force is a pressure times the area it acts on, and that area is checked as things change shape;
  a run where things move after they should have settled is a fail to look for (the timeline shows "rolling").
Also this morning, caught by Delta at build (zero-free names: u60, u120, x0, y0, x0b; a take-away; 7 inputs; reserved words
mix, move): each a crash avoided before it ran.
