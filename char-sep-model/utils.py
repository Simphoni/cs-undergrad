#!/usr/bin/pypy3
import json
import pickle

# global variables

params = {}

pinyin2chars = {}
srcfile = []
charlist = {}
pat = "../2016-{:0>2d}.txt"
mon = [ 2,4,5,6,7,8,9,10,11 ]
paramfile = "params.txt"
charlistfile = "charlist.txt"
for i in mon:
    srcfile.append(pat.format(i))

# operators
    
def load_params()->None:
    global params
    with open(paramfile, "rb") as f:
        params = pickle.load(f)

def store_params()->None:
    with open(paramfile, "wb") as f:
        pickle.dump(params, f)

def load_mappings()->None:
    global charlist
    with open(charlistfile, "r", encoding="gbk") as f:
        s = f.readline();
        for i in s:
            charlist[i] = 1
    with open("mappings.txt", "r", encoding="gbk") as f:
        table = f.readlines()
        for line in table:
            x = list(line.split())
            if (len(x) <= 1):
                continue
            pinyin = x[0]
            tab = []
            for i in x[1:]:
                if i in charlist:
                    tab.append(i)
            pinyin2chars[pinyin] = tab

def insert(rawstr:str)->None:
    global params
    val = json.loads(rawstr)
    sentence = val["html"] + "," + val['title']
    # 0 for freq count
    for i in range(len(sentence) - 1):
        i = 
        if i in charlist and j in charlist:
            # update char freq
            try:    params[0][i] += 1
            except: params[0][i] = 1
            # update pair freq
            try:    params[i][j] += 1
            except: params[i][j] = 1


def calc_params():
    global params
    for i in charlist:
        params[i] = {}
    params[0] = {}
    for filename in srcfile:
        with open(filename, "r", encoding="gbk") as f:
            cnt = 0
            sentence = f.readline()
            while sentence != '':
                insert(sentence)
                sentence = f.readline()
                cnt += 1
                if (cnt % 2500 == 0):
                    print("{} in {}".format(cnt, filename))
        
if __name__ == "__main__":
    load_mappings()
    calc_params()
    store_params()
