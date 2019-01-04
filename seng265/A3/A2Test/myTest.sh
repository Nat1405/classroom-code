#/bin/bash

# Test assignment 2 implementation
# $1: test both infile and stdin


# Do a full test

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20;
do
	echo "Test case $i:"
	# Test input via arguments
	python3 ./sengfmt2.py in$i.txt > ./myout$iarg.txt
	diff -b out$i.txt ./myout$iarg.txt
	echo "Passed by infile"
	
	if [ "$1" = "both" ]; then
		# Test input via stdin
		python3 ./sengfmt.py < in$i.txt > ./myout$istdin.txt
		diff out$i.txt ./myout$istdin.txt
		echo "Passed by stdin"
	fi
done

