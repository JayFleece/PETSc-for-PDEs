#!/bin/bash

# run as (e.g.)
#   ./test_unfem.sh 3
# or
#   ./test_unfem.sh      (same as ./test_unfem.sh 4)

area[0]=0.5
area[1]=0.1
area[2]=0.02
area[3]=0.005
area[4]=0.001
area[5]=0.0002
area[6]=0.00005

# NOTE:   trap.7.*, generated by area[6] above, is finest level tested

# NOTE:   ${1:-4}  expands to $1 if set, otherwise 4

# generate .poly,.node,.ele files at each level of refinement
cd meshes/
triangle -pqa${area[0]} trap
for (( N=1; N<=${1:-4}; N++ )); do
    triangle -rpqa${area[$N]} trap.$N
done
cd ..

# generate .dat.node, .dat.ele files
for (( N=1; N<=${1:-4}; N++ )); do
    ./tri2petsc.py meshes/trap.$N trap.$N.dat
done

make unfem

# run unfem
for (( N=1; N<=${1:-4}; N++ )); do
    rm -f foo.txt
    ./unfem -un_mesh trap.$N.dat -snes_fd -quaddeg 1 -snes_max_funcs 100000 -log_view &> foo.txt
    'grep' result foo.txt
    'grep' SNESFunctionEval foo.txt | awk '{print $1,$2}'
    'grep' "Main Stage:" foo.txt | awk '{print $1,$2,$3,$4}'
done
rm -f foo.txt

