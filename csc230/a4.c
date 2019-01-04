/*
 * a4.c
 *
 * Created: 11/23/2018 5:03:26 PM
 * Author : ncomeau
 * Tested on A-BOAR
 */ 

#include "CSC230.h"
#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316

// global variables
//flag for scrolling state (started or stopped)
int scrolling = 1;
//flag for scroll delay flag. 0 low, 1 med-low, 2 med, 3 med-high, 4 
int scrolldelay = 500;

void copy_chars(char *l1ptr, char *l2ptr, char *line1, char *line2, char *msg1, char *msg2);
void my_delay(int n);
//Button checking code and other code snippets taken from labs
unsigned short poll_adc();
void short_to_hex(unsigned short v, char* str);

ISR(TIMER0_OVF_vect){
	// Check which buttons were pressed and update scrolling and scrolldelay global variable
	unsigned short result = poll_adc();
	
	if (result < ADC_BTN_RIGHT){
		//Right button was pressed
		scrolldelay--;
	}
	else if (result < ADC_BTN_UP){
		//UP button was pressed
		scrolling = 0;
	}
	else if (result < ADC_BTN_DOWN){
		//Down button was pressed
		scrolling = 1;
	}
	else if (result < ADC_BTN_LEFT){
		//LEFT button was pressed
		scrolldelay++;
	}
	else if (result < ADC_BTN_SELECT){
		//Select button was pressed
	}
	
}

void timer0_setup(){
	//You can also enable output compare mode or use other
	//timers (as you would do in assembly).

	TIMSK0 = 0x01;
	TCNT0 = 0x00;
	TCCR0A = 0x00;
	TCCR0B = 0x05; //Prescaler of 64
}

int main(void)
{
    //Make global variables
	char *msg1 = "This is the first line. BUY MORE POP.";
	char *msg2 = "This is the second line. BUY LESS POP.";
	//Each only hold 16 chars plus null terminator.
	char line1[17] = "";
	line1[17]=0;
	char line2[17] = "";
	line2[17]=0;
	// pointers to march through messages
	char *l1ptr = msg1;
	char *l2ptr = msg2;
	
	//ADC Set up
	ADCSRA = 0x87;
	ADMUX = 0x40;
	
	//Timer and interrupt setup
	timer0_setup();
	sei();
	
	// initialize lcd
	lcd_init();
	// clear lcd
	lcd_xy(0,0);
	lcd_puts("");
	lcd_xy(0,1);
	lcd_puts("");
	
    while (1) 
    {
		//display line1 and line2
		lcd_xy(0,0);
		lcd_puts(line1);
		lcd_xy(0,1);
		lcd_puts(line2);
		//copy 16 chars from msg1 and msg2 to line1 and line2
		copy_chars(l1ptr, l2ptr, line1, line2, msg1, msg2);
		//move the pointers forward, wrapping around when appropriate
		if (scrolling){
			l1ptr++;
			l2ptr++;
		}
		if (*l1ptr==0){
			l1ptr=msg1;
		}
		if (*l2ptr==0){
			l2ptr=msg2;
		}
		// delay
		my_delay(scrolldelay);
    }
}

void copy_chars(char *l1ptr, char *l2ptr, char *line1, char *line2, char *msg1, char *msg2){
	// Copies 16 chars from l1ptr into line1.
	for(int i=0; i<16; i++){
		//if *l1ptr = 0, set l1ptr to msg1
		if (*(l1ptr+i)==0){
			l1ptr = msg1-i;
		}
		line1[i] = *(l1ptr+i);
	}
	// Copies 16 chars from l2ptr into line2
	for(int i=0; i<16; i++){
		//if *l2ptr = 0, set l2ptr to msg2
		if (*(l2ptr+i)==0){
			l2ptr = msg2-i;
		}
		line2[i] = *(l2ptr+i);
	}
}

void my_delay(int n){
	// wrapper around delay ms, credit to https://www.avrfreaks.net/forum/how-use-delay-variable
	while(n--){
		_delay_ms(1);
	}
}

unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}

void short_to_hex(unsigned short v, char* str){
	char hex_chars[] = "0123456789ABCDEF";
	str[0] = '0';
	str[1] = 'x';
	str[2] = hex_chars[(v>>12)&0xf];
	str[3] = hex_chars[(v>>8)&0xf];
	str[4] = hex_chars[(v>>4)&0xf];
	str[5] = hex_chars[v&0xf];
	str[6] = '\0';
}
