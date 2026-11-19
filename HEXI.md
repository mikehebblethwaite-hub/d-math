# .hexi: hex cells over time, with their words

Mike, 19 Nov 2026: "wind and so on: make a new format of your own ending with i". Photos are `.pngi`, video `.mp4i`,
sound `.mp3i`; what moves in a room's air (warmth, carbon dioxide, and the wind once the air carries momentum), the
waves in the tank, anything kept in hex cells, is `.hexi`.

It is plain lines of words and D numerals (no zero, no negatives), so a bot reads it straight, as Perch reads a screen.

```
hexi 1                                   the format and its version
what 'the lab and the wave room: the air'  what was recorded
grid hex 14 2D 14 1 foot                 cells across, deep, high (D numerals), and how big each is
rows half a cell along in turn           how the hex rows sit
field t warmth thousandths of a kelvin   each field: its letter, name and unit
field c carbon dioxide parts per million
step 8 seconds                           the room's time between frames
f 1D base t A357D c 2A7                  a frame: its step, and each field's lowest value this frame
t 5 5 6 ...                              one line per layer, floor first: each cell's value above the base, plus 1
c 1 1 2 ...
s 'the lab 20.1 above freezing (base 10: 20.1 C); the outside door open; Dragonfly in the room'
end check 4B1C...                        the check over every line above (missing end: the recording was cut)
```

Values are written above the frame's lowest value plus 1, so they stay small and are never nothing. A run of the same
value may be written `N*v` (N cells of v). New fields (`w` wind across, `v` wind up, `u` wind along) need no new
version: a reader takes the fields the file names.

The check is a rolling sum over the bytes (times 131, kept below the prime 2147483647). It shows a broken or cut file;
it is not a seal. When Delta has bit words it will be SHA-256, bound as the media packs are.
