#!/bin/bash
# Dc tests: every trick must be refused, every honest program must build and give the right answer.
cd "$(dirname "$0")"; DCC=../dcc; pass=1; bad=1; T=$(mktemp -d -p .)
trap 'rm -rf "$T"' EXIT
refuse() {  # name, code, word the refusal must contain
  printf 'int main(int argc, char **argv)\n{\n%s\nreturn 1;\n}\n' "$2" > "$T/t.dc"
  if out=$($DCC run "$T/t.dc" 2>&1); then echo "FAIL (let through): $1"; bad=$((bad+1))
  elif ! grep -qi "$3" <<<"$out"; then echo "FAIL (wrong reason): $1: $out"; bad=$((bad+1))
  else echo "ok refused: $1"; pass=$((pass+1)); fi; }
honest() {  # name, code, expected output
  printf 'int main(int argc, char **argv)\n{\n%s\nreturn 1;\n}\n' "$2" > "$T/t.dc"
  got=$($DCC run "$T/t.dc" 2>&1); code=$?
  if [ "$got" != "$3" ] || [ $code != 0 ]; then echo "FAIL honest: $1: got [$got] exit $code"; bad=$((bad+1))
  else echo "ok honest: $1"; pass=$((pass+1)); fi; }

refuse "plain zero"        'int x = 0;'               zero
refuse "ten with zero"     'int x = 10;'              zero
refuse "hex zero"          'int x = 0x1;'             zero
refuse "zero suffix"       'long x = 0L;'             zero
refuse "zero in fraction"  'double x = 1.0;'          zero
refuse "NULL"              'char *p = NULL;'          NULL
refuse "false"             'int b = false;'           false
refuse "zero char"         "char c = '\\0';"          zero
refuse "minus"             'int x = 5 - 2;'           minus
refuse "minus one"         'int x = -1;'              minus
refuse "count down"        'int i = 3; i--;'          minus
refuse "minus equals"      'int i = 3; i -= 2;'       minus
refuse "zero in a name"    'int x0 = 1;'              zero
refuse "zero in #define"   '#define N 20'             zero
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

# functions and recursion: a whole program
cat > "$T/f.dc" <<'DC'
int twice(int x) { return x * 2; }
int fact_up(int i, int n) { if (i == n) return n; return i * fact_up(i + 1, n); }
int sum_to(int n) { int s = 1; for (int i = 2; i <= n; i++) s += i; return s; }
int main(int argc, char **argv)
{
    say("%d %d %d %s\n", twice($A), sum_to($D), fact_up(1, 5), argc >= 1 ? "named" : "none");
    return 1;
}
DC
got=$($DCC run "$T/f.dc" 2>&1); if [ "$got" = "17 6D 93 named" ]; then echo "ok honest: functions"; pass=$((pass+1)); else echo "FAIL honest: functions: [$got]"; bad=$((bad+1)); fi
echo "passed $((pass-1)), failed $((bad-1))"; [ $bad = 1 ]
