/*
For use with Parallax EM4100-type RFID Reader
(Parallax Part No. 28140)


Chris Lockfort
devnull@csh.rit.edu
*/

/*
* Copyright (c) 2010  Chris Lockfort
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
*
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

#include <SoftwareSerial.h>

#define not_enable 2
#define serial_in 3
#define tag_size 10

char last_tag[tag_size];
char current_tag[tag_size];

SoftwareSerial rfid_reader = SoftwareSerial( serial_in , not_enable );

void setup(){
 Serial.begin(9600);
 pinMode(serial_in, INPUT);
 pinMode(not_enable, OUTPUT);
 rfid_reader.begin(2400);
 digitalWrite(not_enable, 0);
 zero_arrays();
}

void loop(){
 listen(1);
 if(strcmp()){
   print_tag_to_hw_serial();
 }
 listen(0);
 if(strcmp()){
   print_tag_to_hw_serial();
 }
}


/* Explanation: Parallax recommends reading twice in rapid succession to determine if tag was not random noise */
void listen(boolean first_time){
 char ch = rfid_reader.read(); /* This call will block */
 if(ch == 0x0A){ /* LINE FEED = START OF DATA */
   for(int i=0; i<tag_size+1; ++i){
      char serial_read=rfid_reader.read();

      /* START SUPER-PARANOID CONTINGENCY PLANS FOR SITUATIONS THAT PROBABLY WON'T HAPPEN */
      if(serial_read == 0x0A){
         i=0; /* Alright, we lost something here. There's a new tag coming in. */
      }
      if(serial_read == 0x0D && i != tag_size){
        i=0; /* Alright, it ended prematurely, we lost some bytes. Let's try again, shall we? */
      }
      /* END ENGINEERING "COVER MY ASS" MANUEVER */

      if(i != tag_size){
        if(first_time){
          current_tag[i]=serial_read;
        }
        else{
          last_tag[i]=serial_read;
        }
      }
   }
 }
}

bool strcmp(){ /* return true if arrays are the same */
 for(int i=0; i<tag_size; ++i){
   if(current_tag[i] != last_tag[i]){
     return false;
   }
 }
 return true;
}

void print_tag_to_hw_serial(){
for(int i=0; i<tag_size; ++i){
 Serial.print(last_tag[i]);
}
Serial.println();
}

/* I'm 95% sure this is unncessary with today's version of avr-gcc,
 but I don't want to depend on the compiler's internals not changing. */
void zero_arrays(){ 
  for(int i=0; i<tag_size; ++i){
     last_tag[i]=0;
     current_tag[i]=0;
  }
}
