#!/usr/bin/python 
import math
from bitstring import Bits
file_out = open('cosLUT.txt', 'w')
for i in range (0, 91):
    cos_theta = math.cos(math.radians(i))
    cos_theta = float(cos_theta)
    cos_theta = int(math.floor(cos_theta * math.pow(2,8)))
    a = Bits(int =cos_theta, length = 20)

    to_write = '10\'d' + str(i) + ': cos_theta = 20\'b' + str(a.bin) + ';\n'
    file_out.write(to_write)
file_out.close()

file_out_sin = open('sinLUT.txt', 'w')
for i in range (0, 91):
    sin_theta = math.sin(math.radians(i))
    sin_theta = float(sin_theta)
    sin_theta = int(math.floor(sin_theta * math.pow(2,8)))
    a = Bits(int =sin_theta, length = 20)

    to_write = '10\'d' + str(i) + ': sin_theta = 20\'b' + str(a.bin) + ';\n'
    file_out_sin.write(to_write)
file_out_sin.close()

file_out = open('arctanLUT_new.txt', 'w')
arctan = Bits(int = 0, length = 10)
for i in range (0, int(math.pow(2, 11))): #value in front of d.p.
    for f in range(0, int(math.pow(2, 8))): #value behind d.p. always positivie
        fraction = float(f)
        fraction = fraction / float(math.pow(2,8)) 
        arctan_past = arctan.bin
        arctan = int(math.degrees(math.atan(i + fraction))) #always positive
        arctan = Bits(int = arctan, length = 10)
        top_11b = Bits(uint = i, length = 11)
        bot_8b = Bits(uint = f, length = 8)
        
        to_write = '20\'b0' + str(top_11b.bin) + str(bot_8b.bin) + ': temp_theta = 10\'d' + str(arctan.bin) + ';\n'
        if (arctan_past != arctan.bin): 
            file_out.write(to_write)
file_out.close()

file_out = open('mif.txt', 'w')

for numer in range (1,57): 
    for denom in range(1, 640): 
        address = (numer-1)*639 + (denom-1)
        fraction = float(numer)/float(denom)
        integer = int(math.floor(fraction))
        fraction = fraction - integer
        fraction = int(fraction * math.pow(2, 8))
        integer = Bits(uint = integer, length = 6)
        fraction = Bits(uint = fraction, length = 8)
        to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
        file_out.write(to_write)
for denom in range(1, 12):
    if denom == 1: 
        for numer in range(0, 57):
            address = numer+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)
    if denom == 2: 
        for numer in range(0, 114): 
            address = numer + 57+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)
    if denom == 3: 
        for numer in range(0, 171):
            address = numer +57+114+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 4: 
        for numer in range(0, 228):
            address = numer +57+114+171+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 5: 
        for numer in range(0, 285):
            address = numer + 57 + 114 + 171 + 228+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 6: 
        for numer in range(0, 342):
            address = numer + 57 + 114 + 171 + 228 + 285+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 7: 
        for numer in range(0, 399):
            address = numer + 57 + 114 + 171 + 228 + 285 + 342+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 8: 
        for numer in range(0, 456):
            address = numer + 57 + 114 + 171 + 228 + 285 + 342 +399+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 9: 
        for numer in range(0, 513):
            address = numer + 57 + 114 + 171 + 228 + 285 + 342+399+456+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 10: 
        for numer in range(0, 570):
            address = numer+57+114+171+228+285+342+399+456+513+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)

    if denom == 11: 
        for numer in range(0, 627):
            address = numer+57+114+171+228+285+342+399+456+513+570+35784
            fraction = float(numer)/float(denom)
            integer = int(math.floor(fraction))
            fraction = fraction - integer
            fraction = int(fraction * math.pow(2, 8))
            integer = Bits(uint = integer, length = 6)
            fraction = Bits(uint = fraction, length = 8)
            to_write = str(address) + ' : ' + str(integer.bin) + str(fraction.bin) + ';\n'
            file_out.write(to_write)
file_out.close()