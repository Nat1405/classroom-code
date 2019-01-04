#!/bin/bash



gcc -std=c90 -Wall -ansi sengfmt.c -o sengfmt

for i in 01 02 03 04 05 06 07 08 09 10; do
	./sengfmt ./in${i}.txt > ./my_out${i}.txt 
# MAKE SURE TO CHANGE THIS TO COMPARE OUTPUTS NOT INPUTS!!!
	diff -b ./my_out${i}.txt ./out${i}.txt
done
