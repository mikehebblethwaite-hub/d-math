#!/usr/bin/env python3
"""Referee for examples/formulas.delta (the counts that replace pi), for peers to rerun.

Runs the Delta program, reads its table (D numerals), and checks every number against a plain brute-force count of real
lattice points, made here with no formula at all:
  ring  = hex cells at graph distance exactly R      disc  = hex cells at graph distance <= R
  shell = close-packed balls exactly R touching steps out   ball = close-packed balls <= R steps out (12 touching neighbours)
Then checks the hex-step length of a circle: a circle of radius R walked only along the six hex directions is 4*sqrt(3)*R.
Python is only the referee here (an outside counter), not part of D.
Run: python3 -I lang/tests/formulas-referee.py     (from the d-math folder or anywhere)
"""
import itertools, math, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
LANG = os.path.dirname(HERE)


def d(s):
    """a D numeral (digits 1-9 A-D, no zero) as an ordinary integer"""
    v = 0
    for c in s:
        v = v * 13 + "123456789ABCD".index(c) + 1
    return v


def hexdist(q, r):
    return max(abs(q), abs(r), abs(q + r))


def fcc_steps(R):
    touching = [v for v in itertools.product((-1, 0, 1), repeat=3) if sorted(map(abs, v)) == [0, 1, 1]]
    start = (0, 0, 0)
    seen, front = {start: 0}, [start]
    for k in range(1, R + 1):
        nxt = []
        for p in front:
            for s in touching:
                q = (p[0] + s[0], p[1] + s[1], p[2] + s[2])
                if q not in seen:
                    seen[q] = k
                    nxt.append(q)
        front = nxt
    return seen


out = subprocess.run([os.path.join(LANG, "delta"), "run", os.path.join(LANG, "examples", "formulas.delta")],
                     capture_output=True, text=True, timeout=300).stdout
rows = [l.split() for l in out.splitlines() if l[:1].isdigit()]
if not rows:
    sys.exit("FAIL: formulas.delta printed no table")
S = fcc_steps(max(d(r[0]) for r in rows))
good = bad = 0
for row in rows:
    R = d(row[0])
    said = dict(ring=d(row[1]), disc=d(row[3]), shell=d(row[5]), ball=d(row[7]))
    cells = [(q, r) for q in range(-R, R + 1) for r in range(-R, R + 1)]
    counted = dict(ring=sum(hexdist(*c) == R for c in cells), disc=sum(hexdist(*c) <= R for c in cells),
                   shell=sum(v == R for v in S.values()), ball=sum(v <= R for v in S.values()))
    for k in said:
        if said[k] == counted[k]:
            good += 1
        else:
            bad += 1
            print(f"FAIL R={R} {k}: Delta says {said[k]}, counted {counted[k]}")


def hexnorm(phi):          # cost of one unit of travel in direction phi using only the six hex directions
    phi %= math.pi / 3
    return (math.sin(math.pi / 3 - phi) + math.sin(phi)) / math.sin(math.pi / 3)


N = 600000
L = sum(hexnorm(2 * math.pi * k / N) for k in range(N)) * 2 * math.pi / N
ring_ok = abs(L - 4 * math.sqrt(3)) < 1e-6
print(f"counts: {good} of {good + bad} match a brute-force count of real lattice points")
print(f"hex-step circle: length {L:.6f} R, 4*sqrt(3) = {4 * math.sqrt(3):.6f} -> {'same' if ring_ok else 'DIFFERENT'}"
      f" (2*pi = {2 * math.pi:.6f}: a different measuring system)")
sys.exit(1 if bad or not ring_ok else 0)
