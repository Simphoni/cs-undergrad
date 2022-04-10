#!/usr/bin/python3
import sys
import math
import utils

uns_wei = 135

def evaluate(x:str)->str:
    tmp = 0
    py = list(x.split())
    
    try:
        candidates = utils.pinyin2chars[py[0]]
    except:
        return ""
    
    ratio = {}
    sumfreq = 0
    for c in candidates:
        try: tmp = utils.params[0][c]
        except: tmp = uns_wei
        ratio[c] = ( math.log(tmp), c )

    for cstr in py[1:]:
        new_ratio = {}
        try:    candidates = utils.pinyin2chars[cstr]
        except: return ""
        for i in candidates:
            new_ratio[i] = (-1e100, 0)
        for prev in ratio:
            ptup = ratio[prev]
            sumfreq = 0
            for i in candidates:
                try:    sumfreq += utils.params[prev][i]
                except: sumfreq += uns_wei
            for i in candidates:
                try:    tmp = utils.params[prev][i]
                except: tmp = uns_wei
                tup = new_ratio[i]
                if tup[0] < ptup[0] + math.log(tmp) - math.log(sumfreq):
                    new_ratio[i] = ( ptup[0] + math.log(tmp) - math.log(sumfreq), ptup[1] + i )
        ratio = new_ratio
    best = -1e100
    who = ""
    for i in ratio:
        if ratio[i][0] > best:
            best = ratio[i][0]
            who = ratio[i][1]
    return who


if __name__ == "__main__":
    utils.load_params()
    utils.load_mappings()
    args = sys.argv
    if (len(args) != 3):
        print("usage: a.py input_file_name output_file_name")
        sys.exit(0)
    with open(args[1], "r") as f:
        with open (args[2], "w") as o:
            x = f.readline()
            while x != "":
                o.write(evaluate(x) + "\n")
                x = f.readline()
