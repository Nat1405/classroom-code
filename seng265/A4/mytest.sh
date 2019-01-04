#!/bin/bash

gcc -std=c90 sengencode.c -Wall -ansi -o sengencode
echo "Finished compiling, starting execution."
./sengencode
