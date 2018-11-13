#!/bin/bash
# To get free energy in all folders which include OUTCAR 
# and add the energy to worklist(see see Sub_opt_TH.sh).
path=`pwd`
worklist=$path/worklist
line=2
Energy_minimum=9999999999
for i in $(find $path -name OUTCAR | sed 's/\/OUTCAR//g') ; do 
    # Change the path
    cd $i 

    # This is for test: output the line 3 and line 4 of POSCAR
    # head -4 POSCAR|tail -2 

    # Find/log the minimum energy and the corresponding POSCAR
    Energy=`grep TOTEN OUTCAR|tail -1|awk '{print $5}'` 
    result=$(awk -va=$Energy -vb=$Energy_minimum 'BEGIN{print a<b?1:0}')
    if [ $result -eq 1 ];then
        Energy_minimum=$Energy
        vector_a=`awk 'NR==3 {print; exit}' POSCAR`
        vector_b=`awk 'NR==4 {print; exit}' POSCAR`
    fi
    # Write the energy to the worklist(see Sub_opt_TH.sh)
    # Notice: This works because 'find' command output the directories in an ascending order
    #         which is exactly the same as our executation order
    sed -i "${line}s/$/  ${Energy}/" $worklist
    
    # Go back to the original path
    line=$(($line+1)) 
    cd $path; 
done

echo -e "Best POSCAR:\n$vector_a\n$vector_b\nEnergy_minimum: $Energy_minimum eV"  
