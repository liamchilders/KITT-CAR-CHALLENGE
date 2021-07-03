#include <xc.inc>

; CONFIG1
/*
  CONFIG  FOSC = INTOSC         ; Oscillator Selection Bits (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable (Brown-out Reset enabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
  CONFIG  IESO = ON             ; Internal/External Switchover Mode (Internal/External Switchover Mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)
*/
  CONFIG CONFIG1 = 0x3FE4

; CONFIG2
/*
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  CPUDIV = NOCLKDIV     ; CPU System Clock Selection Bit (NO CPU system divide)
  CONFIG  USBLSCLK = 48MHz      ; USB Low SPeed Clock Selection bit (System clock expects 48 MHz, FS/LS USB CLKENs divide-by is set to 8.)
  CONFIG  PLLMULT = 3x          ; PLL Multipler Selection Bit (3x Output Frequency Selected)
  CONFIG  PLLEN = DISABLED      ; PLL Enable Bit (3x or 4x PLL Disabled)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LPBOR = OFF           ; Low-Power Brown Out Reset (Low-Power BOR is disabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable (Low-voltage programming enabled)
*/
  CONFIG CONFIG2 = 0x3ECF

PSECT code
 BANKSEL OSCCON
 movlw 00111110B
 movwf OSCCON
 LED equ 255
 UTIL_DEL equ 255
 MAIN_DEL equ 10
 BANKSEL TRISC
 clrf TRISC
 BANKSEL TRISC
 movlw 0xFF
 movwf TRISA
 BANKSEL LATC
 clrf LATC
 ; everything above this line is simply setting up the processor at 16 MHz, using PORTC as our output for LED's.  Go ahead and copy & paste it.
 movlw 00000001B
 movwf LATC ; turn on first bit light
 
mainloop:
  movlw MAIN_DEL
  movwf 072H ; load up our third RAM with whatever decimal number is in the W register in the line above. This is how many times we'll call the utility delay. 
             ; We control how long the delay is with this number because everytime we call the utility_delay, we add 0.05 seconds to the delay
	     ; This current delay will be approximately 10 X 0.05 = 0.5 seconds.
  btfss LATC, 3
  goto main_delay_on
secondloop:
  movlw MAIN_DEL
  movwf 072H ; load up our third RAM with whatever decimal number is in the W register in the line above. This is how many times we'll call the utility delay. 
             ; We control how long the delay is with this number because everytime we call the utility_delay, we add 0.05 seconds to the delay
	     ; This current delay will be approximately 10 X 0.05 = 0.5 seconds.
  btfss LATC, 0
  goto second_delay_on
  goto mainloop
main_delay_on:
  call utility_delay  ; every time we hit this line, we wait around for 0.05 seconds
  decfsz 072H, 1 ; every time we come back from the utility delay, we count down on our third register till we hit 0. Then we turn the LED's off.
  goto main_delay_on
  lslf LATC, 1 ; move light left
  movlw MAIN_DEL
  movwf 072H ; load up our third RAM with whatever decimal number is in the W register in the line above. This is how many times we'll call the utility delay. 
             ; We control how long the delay is with this number because everytime we call the utility_delay, we add 0.05 seconds to the delay
	     ; This current delay will be approximately 10 X 0.05 = 0.5 seconds. 
  goto main_delay_off
second_delay_on:
  call utility_delay  ; every time we hit this line, we wait around for 0.05 seconds
  decfsz 072H, 1 ; every time we come back from the utility delay, we count down on our third register till we hit 0. Then we turn the LED's off.
  goto second_delay_on
  lsrf LATC, 1 ; move light right
  movlw MAIN_DEL
  movwf 072H ; load up our third RAM with whatever decimal number is in the W register in the line above. This is how many times we'll call the utility delay. 
             ; We control how long the delay is with this number because everytime we call the utility_delay, we add 0.05 seconds to the delay
	     ; This current delay will be approximately 10 X 0.05 = 0.5 seconds. 
  goto second_delay_off
main_delay_off:
  call utility_delay ; every time we hit this line, we wait around for 0.05 seconds
  decfsz 072H, 1 ; every time we come back from the utility delay, we count down on our third register till we hit 0. Then we go back and start over.
  goto main_delay_off
  goto mainloop
second_delay_off:
  call utility_delay ; every time we hit this line, we wait around for 0.05 seconds
  decfsz 072H, 1 ; every time we come back from the utility delay, we count down on our third register till we hit 0. Then we go back and start over.
  goto second_delay_off
  goto secondloop

utility_delay: ; this subroutine is a utility delay that counts down from 255 255 times. That's a total count of 65025. It takes approximately 0.05 seconds at 16 MHz
  movlw UTIL_DEL
  movwf 0070H ; load 255 into first register
  movlw UTIL_DEL
  movwf 0071H ; load 255 into second register
subloop:
  decfsz 0070H, 1 ; count down in first register till we hit 0
  goto subloop
  movlw UTIL_DEL
  movwf 0070H ; load 255 into first register again
  decfsz 0071H, 1 ; count down 1 on second register. If we're at 0, we've now gone through 255 loops of 255. Return back to the main program.
  goto subloop
  return
  
  end ; every program must have an end...at the end. 


