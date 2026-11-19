# Proof of when D was made, and by whom

D (the real world physical maths), Delta (the language, its compiler and assembler), the D Angle font and Delta Hex OS
are the work of Mike J Hebblethwaite (see LICENSE.md). These records show when the work existed, from sources that
cannot be changed by us afterwards:

- GitHub's own record: this repository was created on 18 Nov 2026 at 11:46:11 UTC (the GitHub API's `created_at` for
  mikehebblethwaite-hub/d-math). The first commit, 98fcdd4 "D math 0.01: move >, decompose D>, unknown ~", is dated
  18 Nov 2026 11:18:51 UTC.
- OpenTimestamps (Bitcoin): `commits-2026-11-19.txt` lists every commit to 19 Nov 2026 15:51 UTC (155: commit hash,
  tree hash, date, subject); `commits-2026-11-19.txt.ots` proves that list existed by the time its Bitcoin block was
  made. Because each commit hash covers all of its content and history, this proves the whole repository as it stood.
  Check it: `ots verify commits-2026-11-19.txt.ots` (and `git log --reverse --format='%H %T %aI %s'` matches the list).
  Confirmed: Bitcoin block 976604 (mined 19 Nov 2026 16:13 UTC, merkle root 7e379c0f9574cd7f...) holds it.
- Software Heritage (the archive of all public source code) was asked to keep a copy on 19 Nov 2026 15:51 UTC:
  https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/mikehebblethwaite-hub/d-math
- The Internet Archive's Wayback Machine took a copy of the repository page on 19 Nov 2026 at 15:52:02 UTC:
  https://web.archive.org/web/20261119155202/https://github.com/mikehebblethwaite-hub/d-math
