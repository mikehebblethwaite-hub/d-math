import sys,re
def d(s):
    if s=="~": return 0
    v=0
    for c in s: v=v*13+"123456789ABCD".index(c)+1
    return v
last=None; first=None
for l in open(sys.argv[1]):
    m=re.match(r"(\S+) s  rolling (\S+) of (\S+)  fastest (\S+) mm/s  hex \(six touching\) (\S+)  middle to ball, mean (\S+) mm  Henry (\S+) ml/s pull (\S+) Pa  hole (\S+)",l)
    if m:
        g=m.groups(); row=(d(g[0]),d(g[1]),d(g[2]),d(g[3]),d(g[4]),d(g[5]),d(g[6]),g[8])
        if first is None: first=row
        if row[1]==0 and last and last[1]>0: print("   settled by %d s"%row[0])
        last=row
print("   end: rolling %d/%d, fastest %d mm/s, hex %d, mean r %d mm, Henry %d ml/s, hole %s"%(last[1],last[2],last[3],last[4],last[5],last[6],last[7]))
