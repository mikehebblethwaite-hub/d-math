#!/bin/bash
# Delta tests: every trick must be refused, every honest program must build and give the right answer.
cd "$(dirname "$0")"; DELTA=../delta; pass=1; bad=1; T=$(mktemp -d -p .)
trap 'rm -rf "$T"' EXIT
refuse() {  # name, code, word the refusal must contain
  printf 'int main(int argc, char **argv)\n{\n%s\nreturn 1;\n}\n' "$2" > "$T/t.delta"
  if out=$($DELTA run "$T/t.delta" 2>&1); then echo "FAIL (let through): $1"; bad=$((bad+1))
  elif ! grep -qi "$3" <<<"$out"; then echo "FAIL (wrong reason): $1: $out"; bad=$((bad+1))
  else echo "ok refused: $1"; pass=$((pass+1)); fi; }
honest() {  # name, code, expected output
  printf 'int main(int argc, char **argv)\n{\n%s\nreturn 1;\n}\n' "$2" > "$T/t.delta"
  got=$($DELTA run "$T/t.delta" 2>&1); code=$?
  if [ "$got" != "$3" ] || [ $code != 0 ]; then echo "FAIL honest: $1: got [$got] exit $code"; bad=$((bad+1))
  else echo "ok honest: $1"; pass=$((pass+1)); fi; }

refuse "plain 0"        'int x = 0;' 'digits 1-9 A-D'
refuse "ten written 10"     'int x = 10;' 'digits 1-9 A-D'
refuse "hex 0x"          'int x = 0x1;' 'digits 1-9 A-D'
refuse "0L"       'long x = 0L;' 'digits 1-9 A-D'
refuse "1.0"  'double x = 1.0;' 'digits 1-9 A-D'
refuse "NULL"              'char *p = NULL;'          NULL
refuse "false"             'int b = false;'           false
refuse "zero char"         "char c = '\\0';"          zero
refuse "take away"             'int x = 5 - 2;' moved
refuse "-1"         'int x = -1;' moved
refuse "count down"        'int i = 3; i--;' moved
refuse "-="      'int i = 3; i -= 2;' moved
refuse "0 in a name"    'int x0 = 1;' 'always something'
refuse "#define 20"   '#define N 20' 'digits 1-9 A-D'
refuse "move too many"     'int a = 2, b = 1; move 3 from a to b;' 'cannot move'

honest "D numerals"        'say("%d %d %d\n", $A, $D, 11);'                     'A D 11'
honest "ten is A, 14 is 11" 'int x = 9 + 1; say("%d %d\n", x, x + 4);'          'A 11'
honest "row from 1"        'int r[3] = {7, 8, 9}; say("%d %d\n", r[1], r[3]);'  '7 9'
honest "zero in a string"  'say("0 is only in words: %s\n", "10");'            '0 is only in words: 10'
honest "zero in a comment" '// 0 and 10 and -1 here are only words
say("%d\n", 2);'                                                              '2'
honest "pointer"           'int a = 5; int *q = &a; *q += 2; say("%d\n", a);'  '7'
honest "loop and if"       'int n = 1; while (n < $D) { n += 3; if (n > 9) break; } if (n == $A) say("ten\n"); else say("%d\n", n);' 'ten'
honest "row step up"       'int r[2] = {4, 5}; r[2]++; ++r[1]; say("%d %d\n", r[1], r[2]);' '5 6'
honest "words one by one"  'char *w = "hen"; for (int i = 1; w[i]; i++) say("%c.", w[i]); say("\n");' 'h.e.n.'
honest "char row"          'char b[4] = "ab"; b[3] = (char)78; say("%s\n", b);' 'abc'
refuse "struct (not yet)"  'struct p { int a; } s; say("%d\n", s.a);'   'struct'
honest "move keeps total"  'int a = 4, b = 1; move 4 from a to b; say("%d %d\n", a, b);' '~ 5'
honest "letters in names"  'int Bob = 2, ABCD = 3; say("%d\n", Bob + ABCD);'    '5'
honest "index by sum"      'int r[4] = {1,2,3,4}; int k = 2; say("%d\n", r[k + 1]);' '3'
honest "2D row"            'int g[2][3] = {{1,2,3},{4,5,6}}; say("%d\n", g[2][3]);' '6'
refuse "D> without ~"      'int a = 7, p = 1, q = 1; a D> p + q;'                 'ends with ~'
refuse "D> naming the ~"   'int a = 7, p = 1, r = 1; a D> p ~ r;'                 'no name'
refuse "D> too little"      'int a = 2, p = 1, q = 1, r = 1; a D> p + q + r ~;'    'too little'
refuse "D> amounts too big" 'int a = 3, p = 1, q = 1; a D> 2 p + 2 q ~;'          'too little'
refuse "D> some amounts"    'int a = 6, p = 1, q = 1; a D> 2 p + q ~;'            'every known part'
refuse "D> past lowest"     'int a = 4, p = 1, q = 1; a D> p + q ~; a D> p + q ~;' 'lowest point'
refuse "D> into words"      'int a = 4; char *w = "x"; a D> w ~;'                 'whole number'
honest "D> even"            'int a = $C, x = 1, y = 1, z = 1; a D> x + y + z ~; say("%d %d %d %d\n", x, y, z, a);' '5 5 5 ~'
honest "D> amounts"        'int a = $A, s = 1, h = 1; a D> 3 s + 2 h ~; say("%d %d %d %d\n", s, h, ~, a);' '4 3 5 ~'
honest "D> rest to ~"       'int a = 7, p = 1, q = 1; a D> p + q ~; say("%d %d %d\n", p, q, ~);' '4 4 1'
honest "D> keeps the total" 'int a = $D, p = 1, q = 1; a D> 4 p + 3 q ~; say("%d\n", p + q + ~);' '12'
honest "D > is still compare" 'int D = 2; if (D > 1) say("yes\n");'               'yes'

# spent energy goes to neighbours; the total always stays the same
last() {  # name, code, expected last line
  printf 'int main(int argc, char **argv)\n{\n%s\nreturn 1;\n}\n' "$2" > "$T/t.delta"
  got=$(timeout 20 $DELTA run "$T/t.delta" 2>&1 | tail -1)
  if [ "$got" != "$3" ]; then echo "FAIL honest: $1: got [$got]"; bad=$((bad+1))
  else echo "ok honest: $1"; pass=$((pass+1)); fi; }
NET='int battery = $D, wire = 1, lamp = 1, air = 1; store battery, lamp, air; neighbours battery: wire; neighbours wire: lamp, air;'
last "flow: wire loses heat"  "$NET conduct wire loss 1; spend 5 from battery; say(\"%d %d %d %d\\n\", battery, lamp, air, ~);" '8 4 3 ~'
last "flow: total kept"       "$NET conduct wire loss 1; spend 5 from battery; say(\"%d\\n\", battery + wire + lamp + air + ~);" '13'
last "flow: heat to all"      "$NET conduct wire loss 6; spend 9 from battery; say(\"%d %d %d %d\\n\", battery, lamp, air, ~);" '6 5 4 ~'
last "flow: heat total kept"  "$NET conduct wire loss 6; spend 9 from battery; say(\"%d\\n\", battery + wire + lamp + air + ~);" '13'
last "flow: lone store, Shrug"    'int s = 3; store s; spend 1 from s; say("%d %d\n", s, shrug());' 'Shrug 1 ¯\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.'
honest "Shrug: reads it"         'int s = 3; store s; spend 2 from s; say("%d %d\n", s, shrug()); return 1;' "$(printf 'spend 2 from s (now 1)\n  2 spent goes to the Shrug: s has no neighbours given, where it goes is not known yet\n1 2\nShrug 2 ¯\\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.')"
last "Shrug: none when all known" 'int a = 3, b = 1; store a, b; neighbours a: b; spend 2 from a; say("%d %d\n", b, shrug());' '3 ~'
refuse "flow: spend too much" "$NET conduct wire loss 1; spend $(printf '$')CD from battery;" 'cannot move'
refuse "flow: going round"    'int a = 5, b = 1; conduct a loss 1, b loss 1; neighbours a: b; spend 2 from a;' 'going round'
refuse "flow: bad words"      'int a = 5; conduct a 1;' 'loss'

# things: parts, its own ~, its own functions
prog() {  # name, whole program, expected output, [refuse word]
  printf '%s\n' "$2" > "$T/p.delta"
  got=$(timeout 20 $DELTA run "$T/p.delta" 2>&1); code=$?
  if [ -n "$4" ]; then
    if [ $code = 0 ] || ! grep -qi "$4" <<<"$got"; then echo "FAIL refuse: $1: [$got]"; bad=$((bad+1)); else echo "ok refused: $1"; pass=$((pass+1)); fi
  elif [ "$got" != "$3" ] || [ $code != 0 ]; then echo "FAIL honest: $1: got [$got] exit $code"; bad=$((bad+1))
  else echo "ok honest: $1"; pass=$((pass+1)); fi; }
M='int main(int argc, char **argv)'
honest "row values worked out"  'char *w = "ab"; int r[2] = {2 * 3, w[2]}; say("%d %c\n", r[1], r[2]);' '6 b'
prog "thing parts"        "thing pt { int a, b; }; $M { thing pt p = {1 + 2, 4}; say(\"%d %d %d\\n\", p.a, p.b, p.~); return 1; }" '3 4 ~'
prog "thing function"     "thing pt { int a, b; void up(int n) { a += n; } int sum() { return a + b; } }; $M { thing pt p = {3, 4}; p.up(2); say(\"%d\\n\", p.sum()); return 1; }" '9'
prog "own ~ on D>"        "thing pl { int flesh, s, h; void eat() { flesh D> s + h ~; } }; $M { thing pl p = {7, 1, 1}; p.eat(); say(\"%d %d %d %d %d\\n\", p.flesh, p.s, p.h, p.~, ~); return 1; }" '~ 4 4 1 1'
prog "whole copy"         "thing pt { int a, b; }; $M { thing pt p = {5, 6}, q; q = p; q.a += 1; say(\"%d %d %d\\n\", p.a, q.a, q.b); return 1; }" '5 6 6'
prog "place and arrow"    "thing pt { int a; }; void up(thing pt *p) { p->a += 2; } $M { thing pt p = {1}; up(&p); thing pt *q = &p; say(\"%d\\n\", q->a); return 1; }" '3'
prog "thing in a thing"   "thing seed { int x; }; thing fruit { thing seed s; int y; }; $M { thing fruit f; f.s.x = 4; f.y = 2; say(\"%d %d\\n\", f.s.x, f.y); return 1; }" '4 2'
prog "row of things"      "thing pt { int a; }; $M { thing pt r[3]; for (int i = 1; i <= 3; i++) r[i].a = i * 2; say(\"%d\\n\", r[3].a); return 1; }" '6'
prog "parts as neighbours" "thing lamp { int glow, wire; }; $M { thing lamp l = {1, 1}; int cell = 9; store cell, l.glow; conduct l.wire loss 1; neighbours cell: l.wire; neighbours l.wire: l.glow; spend 3 from cell; say(\"%d %d\\n\", cell, l.glow); return 1; }" $'spend 3 from cell (now 6)\n  l.wire gets 3: passes 2 on, 1 to heat\n    l.glow takes 2 (store, now 3)\n    1 heat to l.glow, the lowest neighbour (now 4)\n6 4'
prog "no such part"       "thing pt { int a; }; $M { thing pt p; p.b = 1; return 1; }" '' 'no part'
prog "thing given whole"  "thing pt { int a; }; void f(thing pt p) { } $M { return 1; }" '' 'by its place'
prog "thing holds itself" "thing pt { thing pt inner; };  $M { return 1; }" '' 'cannot hold itself'
prog "thing not made"     "$M { thing ghost g; return 1; }" '' 'not made'

# vessels: always full; something must go in to let something out
V="thing tank { int gas, air, heat; };"
prog "vessel: swap in and out"  "$V $M { thing tank t = {9}; vessel t; int sky = 99; move 4 from t.gas to sky and 4 from sky to t.air; say(\"%d %d\\n\", t.gas, t.air); return 1; }" '5 4'
prog "vessel: emptied, crushed" "$V $M { thing tank t = {9}; vessel t; int pipe = 1; move 5 from t.gas to pipe; return 1; }" '' 'BLAM'
prog "vessel: set lower, crushed" "$V $M { thing tank t = {9}; vessel t; t.gas = 2; return 1; }" '' 'crushed'
prog "vessel: D> inside stays full" "$V $M { thing tank t = {9}; vessel t; t.gas D> t.air + t.heat ~; say(\"%d %d %d\\n\", t.air, t.heat, t.~); return 1; }" '4 4 1'
prog "vessel: words part"   "thing jar { int gas; char *label; }; $M { thing jar j; vessel j; return 1; }" '' 'whole number'
prog "vessel: not a thing"  "$M { int n = 3; vessel n; return 1; }" '' 'thing with parts'
honest "move and move"      'int a = 5, b = 1, c = 2; move 2 from a to b and 1 from c to a; say("%d %d %d\n", a, b, c);' '4 3 1'

# leaks: no store is solid
last "leak: total kept"     'int h = $D, sky = 1, brick = 9, room = 1, ground = 1; store h leak 3, brick leak 2; store sky, room, ground; neighbours h: sky; neighbours brick: room, ground; tick 3; say("%d\n", h + sky + brick + room + ground + ~);' '1C'
last "leak: evens out"      'int s = 3, air = 1; store s leak 5; store air; neighbours s: air; tick 2; say("%d %d\n", s, air);' '2 2'
last "leak: not to more"    'int s = 3, air = 9; store s leak 5; store air; neighbours s: air; tick; say("%d %d\n", s, air);' '3 9'
last "leak: no neighbours"  'int s = 3; store s leak 1; tick; say("%d\n", s);' '3'
prog "leak: vessel crushed" "thing tank { int gas, air; }; $M { thing tank t = {9}; vessel t; int sky = 1; store t.gas leak 2; store sky; neighbours t.gas: sky; tick; return 1; }" '' 'BLAM'
refuse "leak: no amount"    'int s = 3; store s leak;' 'leak N'

# wear: outside forces break things down; never presume the amount stays
last "wear: rubber in sun"  'int rubber = $D, dust = 1, gas = 1; int sun = 8; wear rubber by sun per 4 D> dust + gas ~; tick 3; say("%d %d %d\n", rubber, dust, gas);' '7 4 4'
last "wear: total kept"     'int r = $D, d = 1, g = 1, s = 3; wear r by s D> d + g ~; tick 4; say("%d\n", r + d + g + ~);' '12'
last "wear: wears away"     'int r = 3, d = 1, s = 2; wear r by s D> d ~; tick 3; say("%d %d\n", r, d);' '~ 4'
last "wear: thing part"     'int sun = 1; int roof[2] = {9, 1}; wear roof[1] by sun D> roof[2] ~; tick 2; say("%d %d\n", roof[1], roof[2]);' '7 3'
refuse "wear: no ~"         'int r = 3, d = 1, s = 1; wear r by s D> d;' 'ends with ~'
refuse "wear: no known part" 'int r = 3, s = 1; wear r by s D> ~;' 'known part'
refuse "wear: needs a neighbour" 'int r = 3, d = 1; wear r 1 D> d ~;' 'what wears it'
last "wear: weak sun"       'int r = 9, d = 1, sun = 3; wear r by sun per 4 D> d ~; tick 2; say("%d %d\n", r, d);' '9 1'
last "tick runs on"         'int r = 9, d = 1, sun = 1; wear r by sun D> d ~; tick; tick; say("%d\n", r);' '7'

# mixing: a thing next to a thing; shared parts even out, more to less
A="thing air { int hydrogen, oxygen; };"
prog "mix: things even out" "$A $M { thing air t = {\$D, 1}, r = {1, 9}; mix t, r; tick 2; say(\"%d %d %d %d\\n\", t.hydrogen, t.oxygen, r.hydrogen, r.oxygen); return 1; }" "$(printf 'tick 1\n  t.hydrogen leaks 6 to r.hydrogen (now 7, r.hydrogen now 7)\n  r.hydrogen holds: no neighbour holds less\n  t.oxygen holds: no neighbour holds less\n  r.oxygen leaks 4 to t.oxygen (now 5, t.oxygen now 5)\ntick 2\n  t.hydrogen holds: no neighbour holds less\n  r.hydrogen holds: no neighbour holds less\n  t.oxygen holds: no neighbour holds less\n  r.oxygen holds: no neighbour holds less\n7 5 7 5')"
last "mix: numbers"         'int a = 9, b = 3; mix a, b; tick; say("%d %d %d\n", a, b, a + b);' '6 6 C'
prog "mix: nothing shared" "thing p { int x; }; thing q { int y; }; $M { thing p a; thing q b; mix a, b; return 1; }" '' 'no parts in common'

# room: a move needs somewhere to go
honest "room: fits in"       'int tank = 9, pump = $D; fits tank $D; move 4 from pump to tank; say("%d %d\n", tank, pump);' 'D 9'
TV='int tank = $D, pump = $D, valve = 1, pipe = 1, sky = 1; fits tank $D, valve 3, pipe 2; store tank, valve, pipe, sky; neighbours tank: valve, pipe; neighbours valve: sky;'
last "overflow: to room"     "$TV move 3 from pump to tank; say(\"%d %d %d\\n\", tank, valve, pipe);" 'D 3 2'
last "overflow: passes on"   "$TV move 3 from pump to tank; move 2 from pump to tank; say(\"%d %d %d %d\\n\", tank, valve, pipe, sky);" 'D 3 2 3'
last "overflow: total kept"  "$TV move 3 from pump to tank; move 2 from pump to tank; say(\"%d\\n\", tank + valve + pipe + sky + pump);" '23'
last "overflow: to the air"  'int tank = $D, pump = 5, sky = $DD; fits tank $D; store tank, sky; neighbours tank: sky; move 1 from pump to tank; say("%d %d\n", tank, sky);' 'D 111'
last "rupture: dead end"     'int tank = $D, pump = 5, pipe = 2; fits tank $D, pipe 2; store tank, pipe; neighbours tank: pipe; move 1 from pump to tank; say("%d %d %d\n", tank, pipe, tank + pipe + pump);' '11 2 17'
last "rupture: no neighbours" 'int tank = $D, pump = 5; fits tank $D; move 1 from pump to tank; say("%d %d\n", tank, shrug());' 'Shrug 11 ¯\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.'
last "room: store full, back" 'int cell = 9, lamp = 1; fits lamp 3; store cell, lamp; neighbours cell: lamp; spend 5 from cell; say("%d %d\n", cell, lamp);' '7 3'
last "room: leak to full"    'int s = 9, air = 2; fits air 2; store s leak 3; store air; neighbours s: air; tick; say("%d %d\n", s, air);' '9 2'
last "room: wear part full"  'int r = 9, d = 1, sun = 2; fits d 2; wear r by sun D> d ~; tick; say("%d %d\n", r, d);' '8 2'
prog "rupture: vessel"       "thing tank { int gas, air; }; $M { thing tank t = {9}; vessel t; int sky = 9; move 1 from sky to t.air; say(\"%d %d\\n\", t.gas, t.air); return 1; }" "$(printf 'BANG! t ruptured: more went in than it holds\n  9 goes to the Shrug: no neighbours given, where it goes is not known yet\n  1 goes to the Shrug: no neighbours given, where it goes is not known yet\n~ ~\nShrug A ¯\\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.')"
refuse "room: fits on words" 'char *w = "x"; fits w 3;' 'whole number'

# the base rule: 1 less in a thing is 1 more in its lowest neighbour; heat cascades
LOW='int tank = 9, sky = 4, ground = 2, pipe = 3; store tank, sky, ground, pipe; neighbours tank: sky, ground, pipe;'
last "lowest: move with no to"  "$LOW move 2 from tank; say(\"%d %d\\n\", tank, ground);" '7 4'
last "lowest: set lower"        "$LOW tank = 3; say(\"%d %d %d %d\\n\", tank, sky, ground, pipe);" '3 5 5 5'
last "lowest: total kept"       "$LOW move 2 from tank; tank /= 2; say(\"%d\\n\", tank + sky + ground + pipe);" '15'
refuse "lowest: no neighbours"  'int a = 5; move 2 from a;' 'say where it goes'
CAS='int battery = $D, wire = 1, lamp = 1, air = 1, wall = 1, ground = 1; store battery, lamp, air, wall, ground; conduct wire loss 1; neighbours battery: wire; neighbours wire: lamp; neighbours lamp: air; neighbours air: wall, ground; spend 8 from battery;'
last "heat cascades"            "$CAS say(\"%d %d %d %d\\n\", lamp, air, wall, ground);" '5 3 2 1'
last "cascade: total kept"      "$CAS say(\"%d\\n\", battery + wire + lamp + air + wall + ground + ~);" '15'

# shrug N from x;  a loss not traced yet
last "shrug off a loss"      'int core = 5, coil = 1; store core, coil; neighbours core: coil; shrug 2 from core; say("%d %d\n", core, shrug());' 'Shrug 2 ¯\_(ツ)_/¯ where did that go? Investigate to bring the Shrug down.'
got=$(timeout 20 $DELTA run ../examples/motor.delta 2>&1); rm -f ../examples/motor
if grep -q "first build: load got 2 of C spent, Shrug 2" <<<"$got" && grep -q "second build added nothing to the Shrug" <<<"$got"; then echo "ok honest: motor: first shrugs 2, second traces all"; pass=$((pass+1)); else echo "FAIL honest: motor example: [$got]"; bad=$((bad+1)); fi

# functions and recursion: a whole program
cat > "$T/f.delta" <<'DC'
int twice(int x) { return x * 2; }
int fact_up(int i, int n) { if (i == n) return n; return i * fact_up(i + 1, n); }
int sum_to(int n) { int s = 1; for (int i = 2; i <= n; i++) s += i; return s; }
int main(int argc, char **argv)
{
    say("%d %d %d %s\n", twice($A), sum_to($D), fact_up(1, 5), argc >= 1 ? "named" : "none");
    return 1;
}
DC
got=$($DELTA run "$T/f.delta" 2>&1); if [ "$got" = "17 6D 93 named" ]; then echo "ok honest: functions"; pass=$((pass+1)); else echo "FAIL honest: functions: [$got]"; bad=$((bad+1)); fi
echo "passed $((pass-1)), failed $((bad-1))"; [ $bad = 1 ]
