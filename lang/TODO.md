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
- Photos in Delta Hex OS default to .pngi (Mike, 19 Nov 2026: "default operating photos are pngi format"): a picture is
  kept as a media pack (~/coop-kit/MEDIA-PACK.md idea, public form to write here): the PNG exactly as made, plus Perch's
  words for it, bound by the PNG's hash. The OS already says its own screen as Perch words (Ctrl+P look), so a picture of
  the screen carries its words from the source, not guessed from pixels. Needs: a PNG writer in Delta (stored deflate
  blocks, CRC-32, Adler-32), SHA-256 in Delta, then a "photo" command and key that writes NAME.pngi to the boot drive.
- Video in Delta Hex OS defaults to .mp4i (Mike, 19 Nov 2026: "default video are mp4i"): the MP4 exactly as made, plus
  Perch's words for it over time (what was on screen and heard, per stretch), bound by the MP4's hash. Needs, after the
  .pngi work: an MP4 writer in Delta (the boxes: ftyp, moov, mdat; a first codec the OS can write itself), then a
  record key/command for the screen.
- Sound in Delta Hex OS defaults to .mp3i (Mike, 19 Nov 2026: "sound is mp3i"): the MP3 exactly as made, plus Perch's
  words for what is heard over time, bound by the MP3's hash. Needs an MP3 writer in Delta (or MP3 frames from the
  sound card's own samples) after the .pngi and .mp4i work.
- Our own zip (deflate) in Delta: data sent to other places or bots is always compressed (Mike, 19 Nov 2026). Serves .hexi
  (zipped to send) and the PNG inside .pngi.
