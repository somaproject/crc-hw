import struct
import random
import numpy as n
import sys
sys.path.append("../../code/")
import frame

# generate a frame, write it to disk

def genframe(fid, data, adulterate = False):

    crc = frame.generateFCS(data)
    outdata = data + crc
    

    l = len(outdata)
    if len(outdata) % 2 == 1:
        outdata += "\xFF"

    if adulterate:
        # corrupt the frame
        outdata = outdata[:2] + '\x17' + outdata[3:]

        fid.write("1 ")
    else:
        fid.write("0 ")

    fid.write("%d " % l)
    fid.write("%4.4X " % l)
    for i in range((l+1) / 2):
        d1 = struct.unpack('B', outdata[2*i])[0]
        d2 = struct.unpack('B', outdata[2*i+1])[0]
        fid.write("%2.2X%2.2X " % (d1, d2))
    fid.write('\n')
# first, simple even tests

fid = file("din.dat", 'w')
d = "\x00\x01"
genframe(fid, d)
d = "\x00\x01\x02\x03"
genframe(fid, d)
d = "\x00\x00\x00\x00\x00\x00\x00"
genframe(fid, d)
d = "\x00\x00\x00\x00\x00\x00\x00\x00"
genframe(fid, d)

for i in range(100):
    l = int(random.uniform(0, 1) * 100)
    x = n.random.uniform(0, 255, l).astype(n.uint8)
    d = ""
    for c in x:
        d += chr(c)

    corrupt = random.uniform(0, 1) > 0.9
    genframe(fid, d, corrupt)
    



                                                         
        
        
    
