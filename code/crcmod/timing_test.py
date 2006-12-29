#-----------------------------------------------------------------------------
# Compare the execution time of CRC to the md5 module.
#
# Copyright (c) 2004  Raymond L. Buvel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#-----------------------------------------------------------------------------

import crcmod, md5
import timeit

# Build a common data set using random bytes.
from random import randint
data = ''.join([chr(randint(0,255)) for i in xrange(10000)])
del i,randint

def polyFromBits(bits):
    p = 0L
    for n in bits:
        p = p | (1L << n)
    return p

# Use the generator polynomial from Standard ECMA-182 "Data Interchange on
# 12,7 mm 48-Track Magnetic Tape Cartridges -DLT1 Format-", December 1992.
g64 = polyFromBits([64, 62, 57, 55, 54, 53, 52, 47, 46, 45, 40, 39, 38, 37,
            35, 33, 32, 31, 29, 27, 24, 23, 22, 21, 19, 17, 13, 12, 10, 9, 7,
            4, 1, 0])

crc = crcmod.Crc(g64)

# This is the standard AUTODIN-II polynomial which appears to be used in a
# wide variety of standards and applications.
#
# Note this 32-bit CRC overrides the 64-bit version created above.  It is used
# because the timing is comparable to the MD5 algorithm.  To use the 64-bit
# version, just comment out this one (or change the name).

g32 = 0x104C11DB7
crc = crcmod.Crc(g32)

su1 = '''from __main__ import crc, data
m = crc.new()
'''
s1 = 'm.update(data)'

t1 = timeit.Timer(s1, su1)

su2 = '''from __main__ import md5, data
m = md5.new()
'''
s2 = 'm.update(data)'

t2 = timeit.Timer(s2, su2)

su3 = '''from __main__ import data
from binascii import crc32
'''
s3 = 'crc32(data)'

t3 = timeit.Timer(s3, su3)

def timePerIter(lst):
    low = 1e6*min(lst)/iter
    high = 1e6*max(lst)/iter
    return low,high

print 'Timing in microseconds per iteration'
print 'min and max of 10 repetitions'
#iter = 100 # Use this for Python implementation
iter = 10000 # Use this for extension module
t1t = t1.repeat(10, iter)
print '  CRC: %8.1f, %8.1f' % (timePerIter(t1t))

iter = 10000 # always use this for md5 and crc32
t2t = t2.repeat(10, iter)
print '  md5: %8.1f, %8.1f' % (timePerIter(t2t))
t3t = t3.repeat(10, iter)
print 'crc32: %8.1f, %8.1f' % (timePerIter(t3t))
