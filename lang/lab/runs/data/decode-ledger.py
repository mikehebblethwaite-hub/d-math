import sys,re
def d(s):
    if s=="~": return 0
    v=0
    for c in s: v=v*13+"123456789ABCD".index(c)+1
    return v
rel=[]
for l in open(sys.argv[1]):
    m=re.match(r"release (\S+): at (\S+) s, the gap by row (\S+) ball (\S+) shut: (\S+) microlitres of air out, (\S+) nJ",l)
    if m: rel.append(tuple(d(x) for x in m.groups())); continue
    if l.startswith(("the release ledger","  by size","  in time")):
        print(re.sub(r"\b([1-9A-D]+)\b", lambda m: str(d(m.group(1))) if all(c in "123456789ABCD" for c in m.group(1)) else m.group(1), l.rstrip()))
if rel:
    print("first 3 releases:", [(r[1], r[2], r[3], r[4]-1, r[5]-1) for r in rel[:3]], "(s, row, ball, ul, nJ)")
    print("last 3 releases:", [(r[1], r[2], r[3], r[4]-1, r[5]-1) for r in rel[-3:]])
    import collections
    c=collections.Counter(r[1] for r in rel); print("releases per second, busiest 5:", c.most_common(5))
