#!/usr/bin/python3
import sys
args = sys.argv
if (len(args) != 3):
    print("usage: ./judger.py std out")
    sys.exit(0)

std = open(args[1], "r")
out = open(args[2], "r")
u = std.readline()
v = out.readline()
cnts = 0
sentence = 0
cntw = 0
word = 0
while u != '':
    cnts += 1
    if u == v:
        sentence += 1
    for i in range(len(u)):
        cntw += 1
        if (u[i] == v[i]):
            word += 1
    u = std.readline()
    v = out.readline()

print("sentence accuracy: {:0f}, word accuracy: {:0f}".format(sentence / cnts, word / cntw))
