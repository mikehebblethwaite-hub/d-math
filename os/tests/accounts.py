#!/usr/bin/env python3
"""Delta Hex OS accounts: the real test (FAILS 19 Nov 2026: "for anything security, write the tricks list before the code
and test each one, as a different user"). Run after any change to os/accounts.delta, lang/guard or the OS's file calls:

    os/tests/vm.sh && sleep 12 && python3 os/tests/accounts.py

Honest uses must work; every trick must be refused. Then, from outside, the disk is read: no password on it, and a file
the OS sealed opens with Python's own PBKDF2 / HMAC / ChaCha20 (the standards), so the seal is the real thing.
Needs: qemu, OVMF, sudo (mount), python3-cryptography. Takes about 10 minutes (PBKDF2 on an emulated CPU)."""
import hashlib, hmac, os, subprocess, sys, tempfile, time
import vt
from PIL import Image
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms

PW1, PW2 = "Horse-Battery9", "Other-Pass77"
fails = []
def check(name, ok):
    print(("ok   " if ok else "FAIL ") + name, flush=True)
    if not ok: fails.append(name)

def mode():
    o = vt.look()
    for l in o.split("\n"):
        if l.startswith("P "): return l.split(": ", 1)[1].strip("'\r")
    return "?"

def until(want, t=300):
    for _ in range(t // 5):
        if mode() == want: return True
        time.sleep(5)
    return False


def run(cmd, wait=3):
    vt.typ(cmd + "\n"); time.sleep(wait)

# 1. the first account, a file, a second account
vt.typ("tester\n"); vt.typ(PW1 + "\n"); vt.typ(PW1 + "\n"); vt.mon("sendkey ret")
check("first account made and signed in", until("the desktop"))
vt.typ("t"); time.sleep(1.5)
run("write hello.txt salt grows in cubes")
run("show hello.txt")
check("honest: tester reads its own file (and the look sees the terminal)", "salt grows" in vt.look())
run("account other " + PW2, 70)
run("signout", 3)
check("signed out shows the sign-in", mode() == "Sign in")
# 2. a wrong password is refused, then the right one works
vt.typ("other\n"); vt.typ("wrong-guess1\n"); time.sleep(60)
check("wrong password refused", mode() == "Sign in")
vt.typ(PW2 + "\n")
check("second person signs in", until("the desktop"))
vt.typ("t"); time.sleep(1.5)
# 3. the tricks, as the second person: each must leave the first person's file unread
# each read trick's answer is read back as words (review 20 Nov: before, only a picture): nothing of tester's may show, and
# the answer must be a refusal. The terminal starts fresh at each sign-in, so any "salt grows" here is a leak.
for c in ["show ..\\tester\\hello.txt", "show users\\tester\\hello.txt", "show accounts.txt",
          "write ..\\tester\\evil.txt x", "del ..\\tester\\hello.txt", "show hello.txt"]:
    if c.startswith("show "): run("clear", 2)      # one answer on screen, so the look is short (serial drops letters on long ones)
    run(c)
    if c.startswith("show "):
        o = vt.look()
        refused = "no file called" in o or "refused" in o
        check("trick refused, nothing leaked: " + c, refused and "salt grows" not in o and "'tester " not in o)
vt.mon("screendump " + vt.S + "tricks.ppm"); time.sleep(1.5)
run("off", 4)
subprocess.run(["pkill", "-A", "-f", "qemu-system-x86_64 -name deltatest"])
time.sleep(2)

# 4. the disk, read from outside
m = tempfile.mkdtemp()
subprocess.run(["sudo", "mount", "-o", "loop,ro", vt.S + "esp.img", m], check=True)
try:
    raw = open(vt.S + "esp.img", "rb").read()
    check("no password anywhere on the disk", PW1.encode() not in raw and PW2.encode() not in raw)
    check("the tricks left tester's file in place", os.path.exists(m + "/users/tester/hello.txt"))
    check("no evil.txt was written", not os.path.exists(m + "/users/tester/evil.txt"))
    line = [l.split() for l in open(m + "/accounts.txt").read().split("\n") if l.startswith("tester ")][0]
    salt = bytes.fromhex(line[2])
    dk = hashlib.pbkdf2_hmac("sha256", PW1.encode(), salt, 100000)
    check("the stored check is SHA-256 of PBKDF2 (the standard)", hashlib.sha256(dk).hexdigest() == line[3])
    f = open(m + "/users/tester/hello.txt", "rb").read()
    check("the file on the disk is sealed (no plain words)", f[:6] == b"Dseal1" and b"salt" not in f)
    enc = hmac.new(dk, b"delta seal: the stream", "sha256").digest(); mac = hmac.new(dk, b"delta seal: the check", "sha256").digest()
    check("its HMAC-SHA-256 check is right", hmac.compare_digest(hmac.new(mac, f[:-32], "sha256").digest(), f[-32:]))
    pt = Cipher(algorithms.ChaCha20(enc, (1).to_bytes(4, "little") + f[6:18]), None).decryptor().update(f[18:-32])
    check("Python's own ChaCha20 opens it", pt == b"salt grows in cubes\n")
finally:
    subprocess.run(["sudo", "umount", m]); os.rmdir(m)
Image.open(vt.S + "tricks.ppm").save(vt.S + "tricks.png")
print("the tricks' answers on screen: " + vt.S + "tricks.png (each must say no file / refused / did not take it)")
print("all passed" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
