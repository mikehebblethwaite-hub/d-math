# drive the test VM: keys through the monitor, read the serial line (Perch lines from the OS)
import socket, sys, time
import os
S=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'run')+'/'
def mon(cmd):
    s=socket.socket(socket.AF_UNIX); s.connect(S+'mon.sock'); time.sleep(0.2); s.recv(65536)
    s.sendall((cmd+'\n').encode()); time.sleep(0.15); s.close()
KM={'\\':'backslash',' ':'spc','-':'minus','.':'dot','/':'slash',':':'shift-semicolon','*':'shift-8','\n':'ret','\t':'tab','!':'shift-1','@':'shift-2'}
def typ(t):
    for c in t:
        k=KM.get(c) or (('shift-'+c.lower()) if c.isupper() else c)
        mon('sendkey '+k); time.sleep(0.08)
ser=None
def serial():
    global ser
    if ser is None:
        ser=socket.socket(socket.AF_UNIX); ser.connect(S+'ser.sock'); ser.setblocking(False)
    out=b''
    t=time.time()
    while time.time()-t<1.5:
        try: out+=ser.recv(65536)
        except BlockingIOError: time.sleep(0.1)
    return out.decode('latin1')
def look():
    serial(); mon('sendkey ctrl-p'); time.sleep(0.3); typ('look\n'); time.sleep(2.5); return serial()
if __name__=='__main__':
    for a in sys.argv[1:]:
        if a=='look': print(look())
        elif a.startswith('wait:'): time.sleep(float(a[5:]))
        elif a.startswith('key:'): mon('sendkey '+a[4:]); time.sleep(0.3)
        else: typ(a.replace('\\n','\n').replace('\\t','\t'))
