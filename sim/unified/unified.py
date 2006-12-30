#!/usr/bin/python
"""
Generate the various files telling us how to handle the data

"""
import numpy as n



fiddin = file('din.dat', 'w')
fidresults = file('results.dat', 'w')

for i in range(10, 200):
    for j in range(10):
        fiddin.write("0 0000\n")
    fiddin.write("1 %4.4X\n" % i)
    x = n.random.randint(0, 2**16-1, (i+1)/2).astype(n.uint16)
    for w in x:
        fiddin.write("1 %4.4X\n" % w)
    fiddin.write("0 0000\n")
    

    if n.random.rand() > 0.9:
        fidresults.write("1 5\n")
    else:
        fidresults.write("0\n")
