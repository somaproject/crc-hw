#!/usr/bin/python

"""
generate fake frame data for us to use in generating packets

"""
import re
import struct
import sys
sys.path.append('../../code')
import crcmod
import frame
import numpy


dinfid = file('din.dat', 'w')
doutfid = file('dout.dat', 'w')


def genframe(data, prespace = 5):
    """ write the string data to the files as a frame,
    appending the proper length data and computing the crc
    """

    # write as input
    for i in range(prespace):
        dinfid.write("0 0000\n")

    
    l = len(data)
    dinfid.write("1 %4.4X\n" % l)
    din = data + '\x00'
    for i in range((l+1)/2):
        dinfid.write("1 %2.2X%2.2X\n" % (ord(din[i*2]),
                                         ord(din[i*2+1])))
    dinfid.write("0 0000\n")

    # write as output

    crc = frame.generateFCS(data)
    outdata = data + crc
    
    lo = len(outdata)

    doutfid.write("%d " % lo)
    doutfid.write("%4.4X " % lo)
    dout = outdata + '\x00'
    for i in range((lo + 1)/2):
        doutfid.write('%2.2X%2.2X ' % (ord(dout[i*2]),
                                       ord(dout[i*2+1])))
    
    doutfid.write('\n')
    
def main():
    d = "\x00\x00\x00\x01"
    genframe(d)
    
    d = "\x00\x01\x02\x03\x04\x05"
    genframe(d)
    
    d = "\x00\x01\x02\x03\x04\x05\x06"
    genframe(d)

    # random data generation
    for i in range(10, 200):
        x = [chr(s) for s in numpy.random.randint(0, 255, i)]
        y = "".join(x)
        genframe(y)
        
        
    
if __name__ == "__main__":
    main()
