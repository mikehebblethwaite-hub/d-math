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
honest "pointer arrow"     'struct p { int a; } s = {5}, *q = &s; say("%d\n", q->a);' '5'
honest "move keeps total"  'int a = 4, b = 1; move 4 from a to b; say("%d %d\n", a, b);' '~ 5'
honest "letters in names"  'int Bob = 2, ABCD = 3; say("%d\n", Bob + ABCD);'    '5'
honest "index by sum"      'int r[4] = {1,2,3,4}; int k = 2; say("%d\n", r[k + 1]);' '3'
honest "2D row"            'int g[2][3] = {{1,2,3},{4,5,6}}; say("%d\n", g[2][3]);' '6'
echo "passed $((pass-1)), failed $((bad-1))"; [ $bad = 1 ]
