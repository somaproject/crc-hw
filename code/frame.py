#!/usr/bin/python

"""

"""
import re
import struct
import crcmod

CRCPOLY = 0x104C11DB7

def intflip(x, width=32):
    """ return X with its MSB as its LSB and vice versa """

    out = 0
    for i in range(width):
        out = (out << 1) | (x & 0x01)
        x = x >> 1
    print hex(x), hex(out)
    return out

def generateFCS(data):
    """
    Generates the ethernet frame check sequence, by computing
    the CRCPOLY-based CRC and then inverting and putting the MSB first. 

    note that CRC 
    """

    fcscrc = crcmod.Crc(CRCPOLY, initCrc=~0L, rev=True, initialize=True)
    fcscrc.update(data)
        
    i = struct.unpack('i', fcscrc.digest())[0]
    invcrc = struct.pack('I', ~i)

    return invcrc[3] + invcrc[2] + invcrc[1] + invcrc[0]

def computeCRC(data):
    fcscrc = crcmod.Crc(CRCPOLY, initCrc=~0L, rev=True, initialize=True)
    fcscrc.update(data)
    i = struct.unpack('i', fcscrc.digest())[0]
    invcrc = struct.pack('I', intflip(i))

    return invcrc[3] + invcrc[2] + invcrc[1] + invcrc[0]

def main():
    testdata = "\x00\x00\x00"
    fcs = genFCS(testdata)
    
    
    print [hex(ord(x)) for x in computeCRC(testdata +fcs)]
    

if __name__ == "__main__":
    main()
