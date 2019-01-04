#!/bin/bash

infile='crazy.txt'

gcc -std=c90 -Wall -ansi sengfmt.c -o sengfmt && ./sengfmt ./${infile} > ./my_out04.txt && diff -y ./my_out04.txt ./out04.txt
