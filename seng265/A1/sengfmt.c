/*
 *  * UVic SENG 265, Fall 2018, A#1
 *   *
 *    * This will contain a solution to sengfmt. In order to complete the
 *     * task of formatting a file, it must open and read the file (hint: 
 *      * using fopen() and fgets() method) and format the text content base on the 
 *       * commands in the file. The program should output the formated content 
 *        * to the command line screen by default (hint: using printf() method).
 *         *
 *          * Supported commands include:
 *           * ?width width :  Each line following the command will be formatted such 
 *            *                 that there is never more than width characters in each line 
 *             * ?mrgn left   :  Each line following the command will be indented left spaces 
 *              *                 from the left-hand margin.
 *               * ?fmt on/off  :  This is used to turn formatting on and off. 
 *                */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Enable debugging print statements*/
#define DEBUG 0
#define MAX_LINE_LEN 500


int check_for_commands(char *line, char*buffer, int *flags){
	if (strncmp(line, "?width", 6)==0){
		int offset=strlen("?width ");
		int width = atoi(line + offset);
		/*printf("Found one ?width %d\n", width);*/
		/*Set the width flag*/
		flags[0] = width;
		/* if margin previously set, set margin now*/
		if(flags[3]>0){
			flags[1]=flags[4];
		}
		/*Set the format flag on*/
		flags[2] = 1;
		return 0;

	}
	else if (strncmp(line, "?mrgn", 5)==0){
		int offset=strlen("?mrgn ");
		int mrgn=atoi(line + offset);
		/*printf("Found one ?mrgn %d\n", mrgn);*/
		/*set the mrgn flag or previous_set flag*/
		if (flags[0] > 0){
			flags[1]=mrgn;
		}
		else{
			flags[3]=mrgn;
		}
		return 0;

	}
	else if (strncmp(line, "?fmt", 4)==0){
		int fmt = 0;
		if (strncmp(line, "?fmt on", 7)==0){
			fmt = 1;
		}
		else if (strncmp(line, "?fmt off", 8)==0){
			fmt = 0;
			/*Dump whatever formatted stuff we have out of buffer */
			if (strlen(buffer)>1){
				buffer[strlen(buffer-1)]='\n';
				printf("%s", buffer);
				buffer[0]='\0';
			}
		}
		/*set the format flag*/
		flags[2] = fmt;
		/*printf("Found one ?fmt %d\n", fmt);*/
		return 0;
	}
	else{
		return 1;
	}
}

int add_line_to_buffer(char *line, char *buffer, int *flags){
	/*if fmt off just print the line out*/
	if (flags[2] == 0){
		printf("%s", line);
	}
	else{
		/* If we come to a blank line, dump the buffer and print a newline*/
		if (strncmp(line, "\n", 1)==0){
			buffer[strlen(buffer)-1]='\n';
			printf("%s\n", buffer);
			buffer[0]='\0';
			return 0;
		}

		/*tokenize our input line and add as many words as possible.
		 * when the buffer fills up, print it to stdout.
		 */
		char *tokenized = strtok(line, " \n");

		while(tokenized != NULL){
			/*is the buffer empty? If so pad with margin.*/
			if (strlen(buffer)==0){
				int i;
				for(i=0;i<flags[1];i++){
					buffer[i]=' ';
				}
				buffer[i]='\0';
			}
			/*Check if there is enough space in buffer for this word.
			 * if there is, add it to buffer with a space.
			 * if there isn't, replace last string with \n,
			 * print buffer and reset buffer length to zero.*/
			if ((strlen(tokenized)+strlen(buffer))<=flags[0]){
				strncat(buffer, tokenized, strlen(tokenized));
				strncat(buffer, " ", 1);
				tokenized = strtok(NULL, " \n");
			}
			else{
				/*replace trailing space with newline*/
				buffer[strlen(buffer)-1]='\n';
				printf("%s", buffer);
				buffer[0]='\0';
			}
		}
		

	}


	return 0;
}



int main(int argc, char *argv[]) {
	/*Setup*/
	FILE *infile;
	/* make line buffer and output buffer*/
	char line[MAX_LINE_LEN];
	char buffer[MAX_LINE_LEN];
	buffer[0]='\0';

	int flags[4];
	/*Initialize flags to default state*/
	flags[0]=0;
	flags[1]=0;
	flags[2]=0;
	flags[3]=0;

	/*printf("Value of flags\nwidth: %d\nmargins: %d\nfmt: %d\nmarg_pre_set: %d\n",
		flags[0], flags[1], flags[2], flags[3]);*/
	
	/* open the input file*/
	infile = fopen(argv[1], "r"); 
	if (infile == NULL) {
		fprintf(stderr, "%s: cannot open %s", argv[0], argv[1]);
		exit(1);
	}

	/* get a single line from file and print to stdout*/
	while (fgets(line, MAX_LINE_LEN, infile) > 0) {
		/*Check the line for commands. If one found, update flags
		 * and skip this line.*/
		int command_found = check_for_commands(line, buffer, flags);
		
		if (command_found == 0){
			continue;
		}
		else{
			add_line_to_buffer(line, buffer, flags);
		}

		/*printf("%s", line);*/
	}
	/*print whatever is left in buffer*/
	if (strlen(buffer)>1){
		buffer[strlen(buffer)-1]='\n';
		printf("%s", buffer);
	}
	exit(0);
}

