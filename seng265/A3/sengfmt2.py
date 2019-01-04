#!/opt/local/bin/python

import sys
import fileinput
import argparse
import logging
import formatter

def main():
    """
    Creates an instance of the formatter and process the lines
    """
    # Get lines; either from file or stdin
    lines = setup()
    form = formatter.Formatter(inputlines=lines)
    result = form.get_lines()
    for line in result:
        print(line)


def setup():
    """Sets up:
        - Logging: sends debug messages to debug.log
        - Input stream, either first argument or stdin

    Returns:
        - lines: all lines of the appropriate input with newlines removed.
    """
    # Various Code snippets from python3 docs
    # Setup logging
    logging.basicConfig(filename='mainDebug.log',level=logging.DEBUG)
    # Try to get input file from command line; if unavailable try to get stdin.
    parser = argparse.ArgumentParser(description='Look for an input file.')
    parser.add_argument('filename', metavar='f', type=str, nargs='*',
                    help='a filename to get input from')
    args = parser.parse_args()
    try:
        with open(args.filename[0]) as f:
            lines = f.readlines()
    except IndexError:
        logging.debug('No file specified at command line; using stdin.')
        with sys.stdin as f:
            lines = f.readlines()
    lines = [x.rstrip('\n') for x in lines]
    return lines



if __name__ == "__main__":
    main()
