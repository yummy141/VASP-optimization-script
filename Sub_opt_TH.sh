#!/bin/bash
# This is a sciprt for unit cell optimization using VASP

# Generate run.sh on TH_NET1
# Notice: Script of run.sh should be modifed when computation is performed on 
#         differnent workload management platform like LSF and so on.
startdir=`pwd`
nodes=12 
run=$startdir/run.sh
printf '#! /bin/bash\n' > $run
printf 'yhrun -n %s -p TH_NET1 vasp.std.5.4.1 > log\n' $nodes >> $run

worklist=$startdir/worklist
printf 'label   ax        ay        az        bx        by        bz        Energy\n' > $worklist

# Generate the sequence of numbers among a and b direction
# Notice: seq has higher precision than awk
i=$(seq 4.57 0.01 4.59)
j=$(seq 3.31 0.01 3.33)
# i=$(awk 'BEGIN{for(i=4.57;i<=4.58;i+=0.01)print i}')
# j=$(awk 'BEGIN{for(j=3.31;j<=3.32;j+=0.01)print j}')

label=$(awk 'BEGIN{printf("%03d",1)}')
for a in $i    # a vector 
do
    for b in $j    # b vector    
    do
        # Create the work file and copy the corresponding input files for VASP 
        # Notice: the original POSCAR should be named as POSCAR_initial
        mkdir opt$label
        cd opt$label
        cp ../run.sh ./
        cp ../POSCAR_initial POSCAR   
        ln -sf ../KPOINTS KPOINTS
        ln -sf ../POTCAR POTCAR
        ln -sf ../INCAR INCAR

        # Generate the position vecotr of a and b
        ax=$(awk -v a=$a 'BEGIN{printf("%.10f",a)}')
        ay=$(awk -v a=$a 'BEGIN{printf("%.10f",0)}')
        az=$(awk -v a=$a 'BEGIN{printf("%.10f",0)}')
        bx=$(awk -v b=$b 'BEGIN{printf("%.10f",0)}')
        by=$(awk -v b=$b 'BEGIN{printf("%.10f",b)}')
        bz=$(awk -v b=$b 'BEGIN{printf("%.10f",0)}')

        # Replace the corresponding lines in POSCAR
        sed -i "3c\    $ax    $ay    $az" POSCAR
        sed -i "4c\    $bx    $by    $bz" POSCAR
       
        # This is just for Test 
        # cp POSCAR ../POSCAR$label
        
        # Submit the job
        # Notice: change your task name!
        yhbatch -n $nodes -p TH_NET1 -J wyt.opt ./run.sh
        
        # Echo position vecotrs to the worklist
        printf "opt%s  %f  %f  %f  %f  %f  %f\n" $label $ax $ay $az $bx $by $bz >> $worklist

        # Increase the label and go back to the original directory
        label=$(awk -v l=$label 'BEGIN{printf("%03d",l+1)}')
        cd ..
    done
done 
