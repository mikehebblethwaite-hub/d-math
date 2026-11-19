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
