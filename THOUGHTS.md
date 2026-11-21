# Thoughts for later

Ideas to try once the things they belong to are complete (Mike, 19 Nov 2026: "put compression as thoughts later, to try
some other ways after completion"). Not promises: each is tried, measured, and kept only if it wins.

## Compression (after .hexi, .pngi, .mp4i and .mp3i work)

The rule that bounds every idea here (Mike, 19 Nov 2026): data passed to other systems must open there without learning
anything new. So what leaves our systems is compressed in a standard way every system already reads (zip/gzip deflate;
PNG, MP4, MP3 inside the media packs), and our own zip in Delta must write those same standard bytes. Our own ways below are
for inside our own systems only, or sit inside a standard wrapper that still opens anywhere.

- .hexi today: key frames, "=" for unchanged, runs, warmth within 2 hundredths; zip on top when sent (72 KB a frame
  written, about 19 KB zipped, with every cell changing).
- Try: writing each cell as its change from the cell beside it (neighbours are close in warmth: the hex way).
- Try: a change from what the air's own rule predicts (the reader runs the same moves; only the surprise is written).
- Try: coarser where nothing is happening, finer where it is (as MP3 keeps what is heard and drops what is not).
- Try: numbers in fewer letters (D digits as 4 bits each, packed, for sending; the words stay words).
- Try: our own zip (deflate) against plain zip, and against a hex-shaped dictionary of common runs.
- Measure each on the same recordings (calm room, door open, candle near): size, time to write, time to read.

## Our own formats as standards, maybe

Mike, 19 Nov 2026: "people may or may not adopt it as a standard, who knows, so future us will see the notes". If .hexi
(or our own compression) is taken up by others, it becomes something other systems already read, and can travel without
the standard wrapper. Until then it travels wrapped. Future us: look at who reads .hexi before dropping the wrapper; keep
HEXI.md complete and plain, so anyone can build a reader from it alone.

## Mike's current theory (21 Nov 2026, 08:14 UK; his words)
"When photons of light are slowed to particles, if 3, the flowing wave of the surrounding neighbour light forces them to hex,
producing matter." Also his: "the hole flow goes through is space time which seems to be a lattice of holes per three";
"the funnel is gravity, the path of falling"; "all one thing ... same in a different state dependent on neighbours and their
current condition".
What the ball-and-flow lab says so far (lang/lab/runs, 21 Nov): cold balls in a flow jam (lab and Mike's bench agree); the hex
came only once the balls were pliable (heat) and the flow pulled their walls into the gaps; a hole under every three lets
one Henry close a whole field. In the analogue the "slowing" (a pliable state) looks necessary. A likeness to test, not proof.
