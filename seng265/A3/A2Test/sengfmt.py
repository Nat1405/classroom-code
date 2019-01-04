#!/usr/bin/env python3

# File: sengfmt.py
# Student Name  : Nathaniel Comeau
# SENG 265 - Assignment 2

import argparse
import sys
import logging

def main():
    # Setup and get stream to read from
    lines, tokens, statusDict = setup()
    logging.debug(f'Initial state: {statusDict}')

    for i, line in enumerate(lines):
        index = i+1
        if len(line)==0:
            tokens=writeTokens(tokens,statusDict)
            print()
            continue
        if checkIfCommand(line):
            tokens = writeTokens(tokens, statusDict)
            statusDict = parseCommand(line, statusDict, index)
            logging.debug(f'New state: {statusDict}')
            continue
        # If fmt off
        if not statusDict["fmt"]:
            print(line)
            continue
        if not statusDict["maxwidth"]:
            if len(line)>1:
                print((' '*statusDict["mrgn"])+line)
            else:
                print()
            continue
        tokens = addTokens(line, tokens)
    # Hit end of file; write the last tokens
    writeTokens(tokens, statusDict)

def setup():
    """Sets up:
        - Logging: sends debug messages to debug.log
        - Input stream, either first argument or stdin
        - Token buffer: list to hold tokens

    Returns:
        - lines: all lines of the appropriate input with newlines removed.
        - tokens: empty list
        - statusDict: dictionary of program state variables.
    """
    # Various Code snippets from python3 docs
    # Setup logging
    logging.basicConfig(filename='debug.log',level=logging.DEBUG)
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
    # Set up token buffer
    tokens = []
    # Create status dictionary. We'll use it to pass around program state.
    statusDict = {"maxwidth":None, "mrgn":0, "fmt":True, "cap":False}
    return lines, tokens, statusDict

def checkIfCommand(line):
    """"""
    try:
        if line[0]=='?':
            return True
    except IndexError:
        if len(line)==0:
            return False
    return False

def writeTokens(tokens, statusDict):
    """Justify and possible capitalize a str greedily then print to stdout"""
    outputstring = ""
    mrgn, maxwidth, cap = statusDict["mrgn"], statusDict["maxwidth"], statusDict["cap"]
    # Print greedily line by line
    while len(tokens)>0:
        outputstring = " "*mrgn
        logging.debug(f'Writing tokens with: {mrgn} {maxwidth} {cap}')
        # Calculate how many tokens to greedily capture
        tokens, tokensToWrite = divideTokens(tokens, maxwidth, mrgn)
        if len(tokensToWrite) == 0:
            continue
        if len(tokensToWrite) == 1:
            outputstring = (" "*mrgn)+tokensToWrite[0]
        else:
            # Calculate # spaces for each slot
            sumWords = 0
            for i in range(len(tokensToWrite)):
                sumWords += len(tokensToWrite[i])
            eachSlot = (maxwidth-mrgn-sumWords)//(len(tokensToWrite)-1)
            # Calculate # extra spaces to distribute
            extraSpaces = (maxwidth-mrgn-sumWords)%(len(tokensToWrite)-1)
            for i in range(len(tokensToWrite)-1):
                outputstring += tokensToWrite[i]
                # Figure out how many spaces to add
                toAdd = eachSlot
                if i < extraSpaces:
                    toAdd += 1
                outputstring += " "*toAdd
            outputstring += tokensToWrite[-1]
        if cap:
            outputstring = outputstring.upper()
        print(outputstring)
    return tokens


def divideTokens(tokens, maxwidth, mrgn):
    """Greedily take as many tokens as possible and """
    # Calculate how many tokens to greedily capture
    i = 0
    count = maxwidth-mrgn
    while count >0 and i<len(tokens):
        # Subtract length of each word plus 1 space from space available
        count -= len(tokens[i])
        count -= 1
        i+=1
    # Deal with case that line butts right up against end
    if count<-1:
        i -= 1
    tokensToWrite = tokens[:i]
    #logging.debug(f'TokensToWrite: {tokensToWrite}')
    tokens = tokens[i:]
    return tokens, tokensToWrite

def parseCommand(line, statusDict, index):
    """"""
    # Parse ?maxwidth [+-]x
    if line[:9]=="?maxwidth":
        if line[10] =='+' or line[10] =='-':
            delta = int(line[10:])
            logging.debug(f'Line {index}: ?maxwidth += {delta} ')
            statusDict["maxwidth"]+= delta
        else:
            value = int(line[10:])
            logging.debug(f'Line {index}: ?maxwidth = {value} ')
            statusDict["maxwidth"] = value
        # Verify 20<=maxwidth<=150
        if statusDict["maxwidth"]<20:
            logging.debug(f'Line {index}: Tried to set maxwidth below 20. maxwidth = 20.')
            statusDict["maxwidth"] = 20
        if statusDict["maxwidth"]>150:
            logging.debug(f'Line {index}: Tried to set maxwidth above 150. maxwidth = 150.')
            statusDict["maxwidth"] = 150
        # It's possible to set max width so that mrgn violates
        # 0<=mrgn<=maxwidth-20.
        # Check that mrgn<=maxwidth-20; if not set to 20.
        if statusDict["mrgn"] > statusDict["maxwidth"]-20:
            statusDict["mrgn"] = statusDict["maxwidth"]-20
        return statusDict

    # Parse ?mrgn [+-]x
    elif line[:5]=="?mrgn":
        # Check for +-
        if line[6] == '+' or line[6]=='-':
            delta = int(line[6:])
            logging.debug(f'Line {index}: ?mrgn += {delta} ')
            statusDict["mrgn"]+= delta
        else:
            value = int(line[6:])
            logging.debug(f'Line {index}: ?mrgn = {value} ')
            statusDict["mrgn"]= value
        # Verify that 0<=mrgn<=maxwidth-20
        if statusDict["mrgn"] < 0:
            logging.debug(f'Line {index}: Tried to set mrgn below 0. mrgn = 0.')
            statusDict["mrgn"] = 0
        if statusDict["maxwidth"]:
            if statusDict["mrgn"] > statusDict["maxwidth"]-20:
                logging.debug(f'Line {index}: Tried to set mrgn too high. mrgn = maxwidth - 20 = {statusDict["maxwidth"]-20}.')
                statusDict["mrgn"] = statusDict["maxwidth"]-20
        return statusDict

    # Parse ?fmt 'on' || 'off'
    elif line[:4]=="?fmt":
        if line[5:7]=="on":
            logging.debug(f'Line {index}: ?fmt on')
            statusDict["fmt"]=True
        else:
            logging.debug(f'Line {index}: ?fmt off')
            statusDict["fmt"]=False
        return statusDict

    # Parse ?cap 'on' || 'off'
    if line[:4]=="?cap":
        if line[5:7]=="on":
            logging.debug(f'Line {index}: ?cap on')
            statusDict["cap"]=True
        else:
            logging.debug(f'Line {index}: ?cap off')
            statusDict["cap"]=False
        return statusDict

def addTokens(line, tokens):
    """"""
    moreTokens = [x for x in line.split(' ') if x!= '']
    tokens.extend(moreTokens)
    return tokens


if __name__ == "__main__":
    main()
