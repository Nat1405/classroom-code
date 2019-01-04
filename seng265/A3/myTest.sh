#/bin/bash

# Test assignment 2 implementation
# $1: test both infile and stdin


# Do a full test

for i in 01 02 03 04 05 06  07_3 08 09_3 10;
do
	echo "Test case $i:"
	# Test input via arguments
	python3 ./sengfmt2.py in$i.txt > ./myout$iarg.txt
	diff out$i.txt ./myout$iarg.txt
	echo "Passed by infile"
	
	if [ "$1" = "both" ]; then
		# Test input via stdin
		python3 ./sengfmt2.py < in$i.txt > ./myout$istdin.txt
		diff out$i.txt ./myout$istdin.txt
		echo "Passed by stdin"
	fi
	
	if [ "$2" = "three" ]; then
		# Test input by class filename
		python3 formatter.py in$i.txt > myout$iarg.txt
		diff out$i.txt ./myout$iarg.txt
		echo "Passed by file to class"
	fi
done

