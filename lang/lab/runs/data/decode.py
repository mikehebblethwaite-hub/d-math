import sys, re
def d(s):
    if s == "~": return 0
    v = 0
    for c in s: v = v * 13 + "123456789ABCD".index(c) + 1
    return v
for line in open(sys.argv[1]):
    m = re.match(r"(\S+) s  warmth (\S+) tenths C  soft (\S+) of (\S+)  flat (\S+)  hex (\S+) of (\S+) inner  gaps shut (\S+) of (\S+)  pull (\S+) Pa  air (\S+) ml/s  melted (\S+)", line)
    if m:
        g = [d(x) for x in m.groups()]
        print("%5d s  %5.1f C  soft %4d/%d  flat %4d  hex %4d/%d  gaps shut %4d/%d  pull %6d Pa  air %6.1f l/s  melted %d" % (g[0], g[1]/10, g[2], g[3], g[4], g[5], g[6], g[7], g[8], g[9], g[10]/1000, g[11]))
    elif not line.startswith(("ping", "Henry")): print(line.rstrip())
