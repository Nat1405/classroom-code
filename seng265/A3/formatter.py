#!/opt/local/bin/python

import sys
import argparse
import sys
import logging
import re
import calendar

class Formatter:
    """Format text input for seng265."""

    def __init__(self, filename=None, inputlines=None):
        # variable to store result
        self.processedLines = ""
        # Get lines
        if filename:
            self.inputLines = self.openFile(filename)
        elif inputlines:
            self.inputLines = inputlines
        # Token buffer and status dictionary
        self.tokens, self.statusDict = self.setup()
        logging.debug(f'Initial state: {self.statusDict}')

        # Do the formatting
        self.format()
        #self.printVariables()

    def format(self):
        """Format input"""
        tokens = self.tokens
        statusDict = self.statusDict
        lines = self.inputLines
        for i, line in enumerate(lines):
            index = i+1
            if len(line)==0:
                tokens=self.writeTokens(tokens,statusDict)
                self.processedLines += "\n"
                #print()
                continue
            if self.checkIfCommand(line):
                tokens = self.writeTokens(tokens, statusDict)
                statusDict = self.parseCommand(line, statusDict, index)
                logging.debug(f'New state: {statusDict}')
                continue
            # If fmt off
            if not statusDict["fmt"]:
                self.processedLines += line + "\n"
                #print(line)
                continue
            if not statusDict["maxwidth"]:
                if len(line)>1:
                    #print((' '*statusDict["mrgn"])+line)
                    self.processedLines += (' '*statusDict["mrgn"])+line + "\n"
                else:
                    self.processedLines += "\n"
                    #print()
                continue
            tokens = self.addTokens(line, tokens, statusDict)
        # Hit end of file; write the last tokens
        self.writeTokens(tokens, statusDict)

    def checkIfCommand(self, line):
        """"""
        try:
            if line[0]=='?':
                return True
        except IndexError:
            if len(line)==0:
                return False
        return False

    def writeTokens(self, tokens, statusDict):
        """Justify and possible capitalize a str greedily then print to stdout"""
        outputstring = ""
        mrgn, maxwidth, cap = statusDict["mrgn"], statusDict["maxwidth"], statusDict["cap"]
        # Print greedily line by line
        while len(tokens)>0:
            outputstring = " "*mrgn
            logging.debug(f'Writing tokens with: {mrgn} {maxwidth} {cap}')
            # Calculate how many tokens to greedily capture
            tokens, tokensToWrite = self.divideTokens(tokens, maxwidth, mrgn)
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
            self.processedLines += outputstring + "\n"
            #print(outputstring)
        return tokens


    def divideTokens(self, tokens, maxwidth, mrgn):
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

    def parseCommand(self, line, statusDict, index):
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
        elif line[:4]=="?cap":
            if line[5:7]=="on":
                logging.debug(f'Line {index}: ?cap on')
                statusDict["cap"]=True
            else:
                logging.debug(f'Line {index}: ?cap off')
                statusDict["cap"]=False
            return statusDict

        # Parse ?replace pattern1 pattern2
        elif line[:8] == "?replace":
            # Split line into three pieces and add last two to statusDict
            split = line.split()
            statusDict["replace"] = []
            statusDict["replace"].extend(split[1:3])
            return statusDict

        # Parse ?monthabbr [off/on]
        elif line[:10] == "?monthabbr":
            split = line.split()
            if split[1] == "on":
                statusDict['month'] = True
            elif split[1] == "off":
                statusDict['month'] = False
            return statusDict

    def addTokens(self, line, tokens, statusDict):
        """"""
        # Look through tokens and replace if needed
        if statusDict["replace"]:
            # Do the replacement
            line = re.sub(statusDict["replace"][0], statusDict["replace"][1], line)
        # Replace month if needed
        if statusDict["month"]:
            # Search for the month pattern and get mm, dd, yyyy
            # based on example from lecture slides
            # Month pattern
            matchobj = re.search("((\d{2})[\/\-\.](\d{2})[\/\-\.](\d{4}))", line)
            if matchobj:
                pattern, mm, dd, yyyy = matchobj.groups()
                replacement = calendar.month_abbr[int(mm)] + f". {dd}, {yyyy}"
                line = re.sub(pattern, replacement, line)

        moreTokens = [x for x in line.split(' ') if x!= '']
        tokens.extend(moreTokens)
        return tokens


    def setup(self):
        """
        Sets up:
            - Token buffer
            - statusDict
            - Logging
        """
        # Set up logging
        logging.basicConfig(filename='classDebug.log',level=logging.DEBUG)
        # Set up token buffer
        tokens = []
        # Create status dictionary. We'll use it to pass around program state.
        statusDict = {"maxwidth":None, "mrgn":0, "fmt":True, "cap":False, "replace":None, "month":False}
        return tokens, statusDict

    def openFile(self, filename):
        """Open a file to get lines"""
        with open(filename) as f:
            lines = f.readlines()
        lines = [x.rstrip('\n') for x in lines]
        return lines

    def printVariables(self):
        """Print info."""
        print(self.tokens)
        print(self.statusDict)
        print(self.inputLines)
        print(self.processedLines)

    def get_lines(self):
        lines = self.processedLines.split("\n")
        #if len(lines) == 1:
        #    lines[0] += "\n"
        lines = lines[:-1]
        return lines

if __name__ == "__main__":
    # Test method to try using class by itself
    parser = argparse.ArgumentParser(description='Look for an input file.')
    parser.add_argument('filename', metavar='f', type=str, nargs='*',
           help='a filename to get input from')
    args = parser.parse_args()
    form = Formatter(filename=args.filename[0])
    for l in form.get_lines():
        print(l)
