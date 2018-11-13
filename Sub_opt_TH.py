#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This is a sciprt for unit cell optimization using VASP
from os import system, chdir
from numpy import linspace

nodes=24 
POSCAR = open('POSCAR_initial','r').readlines() # Read POSCAR
with open("worklist", "w+") as w:
    w.write("label   ax        ay        az        bx        by        bz        Energy\n")
    with open("run.sh", "w+") as f:
        f.write("#! /bin/bash\n")
        label = 1
        for a in linspace(4.57, 4.59, 3):   # a vector
            for b in linspace(3.31, 3.33, 3):   # b vector 
                # Create the work file and copy the corresponding input files for VASP 
                # Notice: the original POSCAR should be named as POSCAR_initial
                system("mkdir opt%03d" % label)
                chdir("opt%03d" % label)
                system("ln -sf ../KPOINTS KPOINTS")
                system("ln -sf ../POTCAR POTCAR")
                system("ln -sf ../INCAR INCAR")
                        
                # Generate and replace the position vecotr of a and b
                POSCAR[2] = "    %.10f    %.10f    %.10f\n" %(a, 0.0, 0.0)
                POSCAR[3] = "    %.10f    %.10f    %.10f\n" %(0.0, b, 0.0)
                with open("POSCAR","w+") as P:
                    P.writelines(POSCAR)

                # Write the worklist 
                w.write("opt%03d  %2.6f  %2.6f  %2.6f  %2.6f  %2.6f  %2.6f\n" %(label,a, 0.0, 0.0, 0.0, b, 0.0))

                # Write the run.sh
                # Notice: Script of run.sh should be modifed when computation is performed on 
                #         differnent workload management platform like LSF and so on.
                f.write("cd opt%03d\n" % label)
                f.write("yhrun -n %d -p TH_NET1 vasp.std.5.4.1 > log\n" % nodes)
                f.write("cd ..\n\n")

                label += 1
                chdir("../")

# Submit
system("yhbatch -n %d -p TH_NET1 -J wyt.opt ./run.sh " % nodes)
            