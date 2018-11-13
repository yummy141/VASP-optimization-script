#!/usr/bin/env python
# -*- coding: utf-8 -*-
from os import listdir, system, path, getcwd, chdir
line = 2
pwd = getcwd()
dirs = listdir("./")
worklist = path.join(pwd,"worklist")
Energy_minimum = 999999999999
for i in dirs: 
    # The path should be directory
    path_new = path.join(pwd, i)
    if path.isdir(path_new)==False:
        continue

    # Change the path
    chdir(path_new)

    if path.isfile("OUTCAR"):
        # Find/log the minimum energy and the corresponding POSCAR
        OUTCAR = open("OUTCAR", "r").readlines()
        for l in OUTCAR[::-1]:
            if "free  energy   TOTEN" in l:
                Energy = float(l.split()[-2])
                break
        
        if Energy < Energy_minimum:
            Energy_minimum = Energy
            POSCAR_best = open("POSCAR","r").readlines()
    else:
        print "No OUTCAR exists in %s" %path_new
        Energy = -1
    # Write the energy to the worklist(see Sub_opt_TH.sh)
    # Notice: This works because 'find' command output the directories in an ascending order
    #         which is exactly the same as our executation order
    system("sed -i '%ds/$/  %f/' %s" % (line, Energy, worklist))    
    line += 1 

print "Best POSCAR:\n%s%sMinimum Energy: %f eV" % (POSCAR_best[2], POSCAR_best[3], Energy_minimum)