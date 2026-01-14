
_timer0_init_1ms:

;embeddedproj_15.c,34 :: 		void timer0_init_1ms(void)
;embeddedproj_15.c,38 :: 		OPTION_REG = 0x02;
	MOVLW      2
	MOVWF      OPTION_REG+0
;embeddedproj_15.c,44 :: 		TMR0 = 0x06;
	MOVLW      6
	MOVWF      TMR0+0
;embeddedproj_15.c,46 :: 		INTCON &= (unsigned char)~0x04; // clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;embeddedproj_15.c,47 :: 		INTCON |= 0xA0; // GIE + T0IE
	MOVLW      160
	IORWF      INTCON+0, 1
;embeddedproj_15.c,48 :: 		}
L_end_timer0_init_1ms:
	RETURN
; end of _timer0_init_1ms

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;embeddedproj_15.c,50 :: 		void interrupt(void)
;embeddedproj_15.c,52 :: 		if(INTCON & 0x04) { // T0IF
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;embeddedproj_15.c,53 :: 		TMR0 = 0x06; // reload
	MOVLW      6
	MOVWF      TMR0+0
;embeddedproj_15.c,54 :: 		INTCON &= (unsigned char)~0x04; // clear flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;embeddedproj_15.c,55 :: 		sys_ms++;
	MOVF       _sys_ms+0, 0
	MOVWF      R0+0
	MOVF       _sys_ms+1, 0
	MOVWF      R0+1
	MOVF       _sys_ms+2, 0
	MOVWF      R0+2
	MOVF       _sys_ms+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _sys_ms+0
	MOVF       R0+1, 0
	MOVWF      _sys_ms+1
	MOVF       R0+2, 0
	MOVWF      _sys_ms+2
	MOVF       R0+3, 0
	MOVWF      _sys_ms+3
;embeddedproj_15.c,56 :: 		buzz_tick++;
	MOVF       _buzz_tick+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _buzz_tick+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _buzz_tick+0
	MOVF       R0+1, 0
	MOVWF      _buzz_tick+1
;embeddedproj_15.c,57 :: 		if(buzz_tick >= 2000) buzz_tick = 0;
	MOVLW      7
	SUBWF      _buzz_tick+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt166
	MOVLW      208
	SUBWF      _buzz_tick+0, 0
L__interrupt166:
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt1
	CLRF       _buzz_tick+0
	CLRF       _buzz_tick+1
L_interrupt1:
;embeddedproj_15.c,58 :: 		}
L_interrupt0:
;embeddedproj_15.c,59 :: 		}
L_end_interrupt:
L__interrupt165:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

embeddedproj_15_wait_ms:

;embeddedproj_15.c,61 :: 		static void wait_ms(unsigned int ms)
;embeddedproj_15.c,63 :: 		unsigned long t0 = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      R9+0
	MOVF       _sys_ms+1, 0
	MOVWF      R9+1
	MOVF       _sys_ms+2, 0
	MOVWF      R9+2
	MOVF       _sys_ms+3, 0
	MOVWF      R9+3
;embeddedproj_15.c,64 :: 		while((unsigned long)(sys_ms - t0) < (unsigned long)ms) { }
L_embeddedproj_15_wait_ms2:
	MOVF       _sys_ms+0, 0
	MOVWF      R5+0
	MOVF       _sys_ms+1, 0
	MOVWF      R5+1
	MOVF       _sys_ms+2, 0
	MOVWF      R5+2
	MOVF       _sys_ms+3, 0
	MOVWF      R5+3
	MOVF       R9+0, 0
	SUBWF      R5+0, 1
	MOVF       R9+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+1, 0
	SUBWF      R5+1, 1
	MOVF       R9+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+2, 0
	SUBWF      R5+2, 1
	MOVF       R9+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R9+3, 0
	SUBWF      R5+3, 1
	MOVF       FARG_embeddedproj_15_wait_ms_ms+0, 0
	MOVWF      R1+0
	MOVF       FARG_embeddedproj_15_wait_ms_ms+1, 0
	MOVWF      R1+1
	CLRF       R1+2
	CLRF       R1+3
	MOVF       R1+3, 0
	SUBWF      R5+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_ms168
	MOVF       R1+2, 0
	SUBWF      R5+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_ms168
	MOVF       R1+1, 0
	SUBWF      R5+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_ms168
	MOVF       R1+0, 0
	SUBWF      R5+0, 0
L_embeddedproj_15_wait_ms168:
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_wait_ms3
	GOTO       L_embeddedproj_15_wait_ms2
L_embeddedproj_15_wait_ms3:
;embeddedproj_15.c,65 :: 		}
L_end_wait_ms:
	RETURN
; end of embeddedproj_15_wait_ms

_pwm_init:

;embeddedproj_15.c,73 :: 		void pwm_init(void)
;embeddedproj_15.c,75 :: 		TRISC = 0x09; // RC0,RC3 inputs; RC1,RC2,RC4..RC7 outputs
	MOVLW      9
	MOVWF      TRISC+0
;embeddedproj_15.c,77 :: 		T2CON = 0x07;
	MOVLW      7
	MOVWF      T2CON+0
;embeddedproj_15.c,79 :: 		PR2 = 250;
	MOVLW      250
	MOVWF      PR2+0
;embeddedproj_15.c,81 :: 		CCP1CON = 0x0C;
	MOVLW      12
	MOVWF      CCP1CON+0
;embeddedproj_15.c,82 :: 		CCP2CON = 0x0C;
	MOVLW      12
	MOVWF      CCP2CON+0
;embeddedproj_15.c,84 :: 		CCPR1L = 0;
	CLRF       CCPR1L+0
;embeddedproj_15.c,85 :: 		CCPR2L = 0;
	CLRF       CCPR2L+0
;embeddedproj_15.c,87 :: 		CCP1CON &= 0xCF;
	MOVLW      207
	ANDWF      CCP1CON+0, 1
;embeddedproj_15.c,88 :: 		CCP2CON &= 0xCF;
	MOVLW      207
	ANDWF      CCP2CON+0, 1
;embeddedproj_15.c,89 :: 		}
L_end_pwm_init:
	RETURN
; end of _pwm_init

_pwm_left:

;embeddedproj_15.c,91 :: 		void pwm_left(unsigned char val) {
;embeddedproj_15.c,92 :: 		if(val>255)val = 255;
	MOVF       FARG_pwm_left_val+0, 0
	SUBLW      255
	BTFSC      STATUS+0, 0
	GOTO       L_pwm_left4
	MOVLW      255
	MOVWF      FARG_pwm_left_val+0
L_pwm_left4:
;embeddedproj_15.c,93 :: 		CCPR1L = (unsigned char)val;
	MOVF       FARG_pwm_left_val+0, 0
	MOVWF      CCPR1L+0
;embeddedproj_15.c,95 :: 		CCP1CON = CCP1CON & 0xCF;   // 1100 1111
	MOVLW      207
	ANDWF      CCP1CON+0, 1
;embeddedproj_15.c,96 :: 		}
L_end_pwm_left:
	RETURN
; end of _pwm_left

_pwm_right:

;embeddedproj_15.c,98 :: 		void pwm_right(unsigned char val) {
;embeddedproj_15.c,99 :: 		if(val>255)val = 255;
	MOVF       FARG_pwm_right_val+0, 0
	SUBLW      255
	BTFSC      STATUS+0, 0
	GOTO       L_pwm_right5
	MOVLW      255
	MOVWF      FARG_pwm_right_val+0
L_pwm_right5:
;embeddedproj_15.c,100 :: 		CCPR2L = (unsigned char)val;
	MOVF       FARG_pwm_right_val+0, 0
	MOVWF      CCPR2L+0
;embeddedproj_15.c,102 :: 		CCP2CON = CCP2CON & 0xCF;   // 1100 1111
	MOVLW      207
	ANDWF      CCP2CON+0, 1
;embeddedproj_15.c,103 :: 		}
L_end_pwm_right:
	RETURN
; end of _pwm_right

_pivot_right:

;embeddedproj_15.c,110 :: 		void pivot_right(void)
;embeddedproj_15.c,112 :: 		PORTC &= (unsigned char)(~(L_IN1 | L_IN2));     // left wheel stopped (RC4,RC5 = 0)
	MOVLW      207
	ANDWF      PORTC+0, 1
;embeddedproj_15.c,113 :: 		PORTC = (PORTC | R_IN3) & (unsigned char)(~R_IN4);  // right wheel forward (RC6=1, RC7=0)
	MOVLW      64
	IORWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      127
	ANDWF      R0+0, 0
	MOVWF      PORTC+0
;embeddedproj_15.c,114 :: 		}
L_end_pivot_right:
	RETURN
; end of _pivot_right

_pivot_left:

;embeddedproj_15.c,116 :: 		void pivot_left(void)
;embeddedproj_15.c,118 :: 		PORTC &= (unsigned char)(~(R_IN3 | R_IN4));     // right wheel stopped (RC6,RC7 = 0)
	MOVLW      63
	ANDWF      PORTC+0, 1
;embeddedproj_15.c,119 :: 		PORTC = (PORTC | L_IN1) & (unsigned char)(~L_IN2);   // left wheel forward
	MOVLW      16
	IORWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      223
	ANDWF      R0+0, 0
	MOVWF      PORTC+0
;embeddedproj_15.c,120 :: 		}
L_end_pivot_left:
	RETURN
; end of _pivot_left

_motor_stop:

;embeddedproj_15.c,122 :: 		void motor_stop(void)
;embeddedproj_15.c,125 :: 		PORTC &= (unsigned char)(~(L_IN1 | L_IN2 | R_IN3 | R_IN4));
	MOVLW      15
	ANDWF      PORTC+0, 1
;embeddedproj_15.c,126 :: 		}
L_end_motor_stop:
	RETURN
; end of _motor_stop

_motor_forward:

;embeddedproj_15.c,128 :: 		void motor_forward(void)
;embeddedproj_15.c,130 :: 		PORTC = (PORTC | L_IN1) & (unsigned char)(~L_IN2);
	MOVLW      16
	IORWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      223
	ANDWF      R0+0, 0
	MOVWF      PORTC+0
;embeddedproj_15.c,131 :: 		PORTC = (PORTC | R_IN3) & (unsigned char)(~R_IN4);
	MOVLW      64
	IORWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      127
	ANDWF      R0+0, 0
	MOVWF      PORTC+0
;embeddedproj_15.c,132 :: 		}
L_end_motor_forward:
	RETURN
; end of _motor_forward

_left_90:

;embeddedproj_15.c,134 :: 		void left_90(void){
;embeddedproj_15.c,136 :: 		pivot_left();
	CALL       _pivot_left+0
;embeddedproj_15.c,137 :: 		pwm_right(0);
	CLRF       FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,138 :: 		pwm_right(TURN_PWM);
	MOVLW      180
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,139 :: 		wait_ms(400); // prev 440
	MOVLW      144
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVLW      1
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,140 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,141 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,142 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,143 :: 		}
L_end_left_90:
	RETURN
; end of _left_90

_right_90:

;embeddedproj_15.c,145 :: 		void right_90(void){
;embeddedproj_15.c,147 :: 		pivot_right();
	CALL       _pivot_right+0
;embeddedproj_15.c,148 :: 		pwm_left(0);
	CLRF       FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,149 :: 		pwm_left(TURN_PWM);
	MOVLW      180
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,150 :: 		wait_ms(400);
	MOVLW      144
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVLW      1
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,151 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,152 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,153 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,154 :: 		}
L_end_right_90:
	RETURN
; end of _right_90

_line_left:

;embeddedproj_15.c,160 :: 		unsigned char line_left(void) {
;embeddedproj_15.c,161 :: 		return (PORTB & 0x02) ? 1 : 0; // just returns RB1 ( left sensor )
	BTFSS      PORTB+0, 1
	GOTO       L_line_left6
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_line_left7
L_line_left6:
	CLRF       R1+0
L_line_left7:
	MOVF       R1+0, 0
	MOVWF      R0+0
;embeddedproj_15.c,162 :: 		}
L_end_line_left:
	RETURN
; end of _line_left

_line_right:

;embeddedproj_15.c,163 :: 		unsigned char line_right(void){
;embeddedproj_15.c,164 :: 		return (PORTB & 0x01) ? 1 : 0; // just returns RB0 ( right sensor )
	BTFSS      PORTB+0, 0
	GOTO       L_line_right8
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_line_right9
L_line_right8:
	CLRF       R1+0
L_line_right9:
	MOVF       R1+0, 0
	MOVWF      R0+0
;embeddedproj_15.c,165 :: 		}
L_end_line_right:
	RETURN
; end of _line_right

_sensor_left:

;embeddedproj_15.c,171 :: 		unsigned char sensor_left(void) {
;embeddedproj_15.c,172 :: 		return (PORTB & 0x20) ? 1 : 0; // just returns RB5 ( left sensor )
	BTFSS      PORTB+0, 5
	GOTO       L_sensor_left10
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_sensor_left11
L_sensor_left10:
	CLRF       R1+0
L_sensor_left11:
	MOVF       R1+0, 0
	MOVWF      R0+0
;embeddedproj_15.c,173 :: 		}
L_end_sensor_left:
	RETURN
; end of _sensor_left

_sensor_right:

;embeddedproj_15.c,174 :: 		unsigned char sensor_right(void){
;embeddedproj_15.c,175 :: 		return (PORTB & 0x10) ? 1 : 0; // just returns RB4 ( right sensor )
	BTFSS      PORTB+0, 4
	GOTO       L_sensor_right12
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_sensor_right13
L_sensor_right12:
	CLRF       R1+0
L_sensor_right13:
	MOVF       R1+0, 0
	MOVWF      R0+0
;embeddedproj_15.c,176 :: 		}
L_end_sensor_right:
	RETURN
; end of _sensor_right

embeddedproj_15_timer1_init_us:

;embeddedproj_15.c,180 :: 		static void timer1_init_us(void)
;embeddedproj_15.c,187 :: 		T1CON = 0x11;
	MOVLW      17
	MOVWF      T1CON+0
;embeddedproj_15.c,188 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;embeddedproj_15.c,189 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;embeddedproj_15.c,192 :: 		PIE1 &= (unsigned char)~0x01; // TMR1IE = 0
	MOVLW      254
	ANDWF      PIE1+0, 1
;embeddedproj_15.c,193 :: 		PIR1 &= (unsigned char)~0x01; // clear TMR1IF
	MOVLW      254
	ANDWF      PIR1+0, 1
;embeddedproj_15.c,194 :: 		}
L_end_timer1_init_us:
	RETURN
; end of embeddedproj_15_timer1_init_us

embeddedproj_15_t1_now_us:

;embeddedproj_15.c,196 :: 		static unsigned int t1_now_us(void)
;embeddedproj_15.c,199 :: 		unsigned char h = TMR1H;
	MOVF       TMR1H+0, 0
	MOVWF      R6+0
;embeddedproj_15.c,200 :: 		unsigned char l = TMR1L;
	MOVF       TMR1L+0, 0
	MOVWF      R7+0
;embeddedproj_15.c,201 :: 		return ((unsigned int)h << 8) | (unsigned int)l;
	MOVF       R6+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	MOVF       R4+0, 0
	MOVWF      R2+1
	CLRF       R2+0
	MOVF       R7+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R2+0, 0
	IORWF      R0+0, 1
	MOVF       R2+1, 0
	IORWF      R0+1, 1
;embeddedproj_15.c,202 :: 		}
L_end_t1_now_us:
	RETURN
; end of embeddedproj_15_t1_now_us

embeddedproj_15_t1_wait_us:

;embeddedproj_15.c,204 :: 		static void t1_wait_us(unsigned int us)
;embeddedproj_15.c,206 :: 		unsigned int t0 = t1_now_us();
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_t1_wait_us_t0_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_t1_wait_us_t0_L0+1
;embeddedproj_15.c,207 :: 		while((unsigned int)(t1_now_us() - t0) < us) { }
L_embeddedproj_15_t1_wait_us14:
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       embeddedproj_15_t1_wait_us_t0_L0+0, 0
	SUBWF      R0+0, 0
	MOVWF      R2+0
	MOVF       embeddedproj_15_t1_wait_us_t0_L0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      R0+1, 0
	MOVWF      R2+1
	MOVF       FARG_embeddedproj_15_t1_wait_us_us+1, 0
	SUBWF      R2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_t1_wait_us185
	MOVF       FARG_embeddedproj_15_t1_wait_us_us+0, 0
	SUBWF      R2+0, 0
L_embeddedproj_15_t1_wait_us185:
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_t1_wait_us15
	GOTO       L_embeddedproj_15_t1_wait_us14
L_embeddedproj_15_t1_wait_us15:
;embeddedproj_15.c,208 :: 		} // uses the current value of t1 and counts in micro seconds till we reach the exact parameter we gave it.
L_end_t1_wait_us:
	RETURN
; end of embeddedproj_15_t1_wait_us

embeddedproj_15_adc_init_an0:

;embeddedproj_15.c,210 :: 		static void adc_init_an0(void)
;embeddedproj_15.c,213 :: 		TRISA |= 0x01;
	BSF        TRISA+0, 0
;embeddedproj_15.c,216 :: 		ADCON1 = 0x8E;
	MOVLW      142
	MOVWF      ADCON1+0
;embeddedproj_15.c,218 :: 		ADCON0 = 0x81;
	MOVLW      129
	MOVWF      ADCON0+0
;embeddedproj_15.c,220 :: 		t1_wait_us(50);
	MOVLW      50
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,221 :: 		}
L_end_adc_init_an0:
	RETURN
; end of embeddedproj_15_adc_init_an0

embeddedproj_15_adc_read_an0:

;embeddedproj_15.c,223 :: 		static unsigned int adc_read_an0(void)
;embeddedproj_15.c,226 :: 		ADCON0 &= 0xC7;           // clear CHS bits (5:3)
	MOVLW      199
	ANDWF      ADCON0+0, 1
;embeddedproj_15.c,229 :: 		t1_wait_us(30);
	MOVLW      30
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,232 :: 		ADCON0 |= ADC_GO_MASK;
	BSF        ADCON0+0, 2
;embeddedproj_15.c,235 :: 		while(ADCON0 & ADC_GO_MASK) { }
L_embeddedproj_15_adc_read_an016:
	BTFSS      ADCON0+0, 2
	GOTO       L_embeddedproj_15_adc_read_an017
	GOTO       L_embeddedproj_15_adc_read_an016
L_embeddedproj_15_adc_read_an017:
;embeddedproj_15.c,237 :: 		return ((unsigned int)ADRESH << 8) | (unsigned int)ADRESL;
	MOVF       ADRESH+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	MOVF       R4+0, 0
	MOVWF      R2+1
	CLRF       R2+0
	MOVF       ADRESL+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R2+0, 0
	IORWF      R0+0, 1
	MOVF       R2+1, 0
	IORWF      R0+1, 1
;embeddedproj_15.c,238 :: 		}
L_end_adc_read_an0:
	RETURN
; end of embeddedproj_15_adc_read_an0

embeddedproj_15_buzzer_init:

;embeddedproj_15.c,241 :: 		static void buzzer_init(void)
;embeddedproj_15.c,243 :: 		TRISB &= (unsigned char)~BUZZER_MASK; // RB2 output
	MOVLW      251
	ANDWF      TRISB+0, 1
;embeddedproj_15.c,244 :: 		PORTB &= (unsigned char)~BUZZER_MASK; // start OFF
	MOVLW      251
	ANDWF      PORTB+0, 1
;embeddedproj_15.c,245 :: 		}
L_end_buzzer_init:
	RETURN
; end of embeddedproj_15_buzzer_init

embeddedproj_15_buzzer_on:

;embeddedproj_15.c,247 :: 		static void buzzer_on(void)
;embeddedproj_15.c,249 :: 		PORTB |= BUZZER_MASK;
	BSF        PORTB+0, 2
;embeddedproj_15.c,250 :: 		}
L_end_buzzer_on:
	RETURN
; end of embeddedproj_15_buzzer_on

embeddedproj_15_buzzer_off:

;embeddedproj_15.c,252 :: 		static void buzzer_off(void)
;embeddedproj_15.c,254 :: 		PORTB &= (unsigned char)~BUZZER_MASK;
	MOVLW      251
	ANDWF      PORTB+0, 1
;embeddedproj_15.c,255 :: 		}
L_end_buzzer_off:
	RETURN
; end of embeddedproj_15_buzzer_off

embeddedproj_15_ultrasonic_init:

;embeddedproj_15.c,257 :: 		static void ultrasonic_init(void)
;embeddedproj_15.c,260 :: 		TRISD = (TRISD | (US_ECHO_F)) & (unsigned char)~(US_TRIG_F);
	MOVLW      8
	IORWF      TRISD+0, 0
	MOVWF      R0+0
	MOVLW      251
	ANDWF      R0+0, 0
	MOVWF      TRISD+0
;embeddedproj_15.c,262 :: 		PORTD = PORTD & (unsigned char)~(US_TRIG_F);
	MOVLW      251
	ANDWF      PORTD+0, 1
;embeddedproj_15.c,264 :: 		}
L_end_ultrasonic_init:
	RETURN
; end of embeddedproj_15_ultrasonic_init

embeddedproj_15_ultrasonic_trigger:

;embeddedproj_15.c,266 :: 		static void ultrasonic_trigger(unsigned char trig_mask)
;embeddedproj_15.c,268 :: 		PORTD = PORTD & (unsigned char)~trig_mask;	// force trigger low to make sure no weird leftover state
	COMF       FARG_embeddedproj_15_ultrasonic_trigger_trig_mask+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ANDWF      PORTD+0, 1
;embeddedproj_15.c,269 :: 		t1_wait_us(2); // make sure you start from clean low level
	MOVLW      2
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,271 :: 		PORTD = PORTD | trig_mask;	// force trigger high
	MOVF       FARG_embeddedproj_15_ultrasonic_trigger_trig_mask+0, 0
	IORWF      PORTD+0, 1
;embeddedproj_15.c,272 :: 		t1_wait_us(US_TRIGGER_PULSE_US); // keeps trigger high for 15us
	MOVLW      15
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	CLRF       FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,274 :: 		PORTD = PORTD & (unsigned char)~trig_mask; // force trigger low again.
	COMF       FARG_embeddedproj_15_ultrasonic_trigger_trig_mask+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ANDWF      PORTD+0, 1
;embeddedproj_15.c,275 :: 		}
L_end_ultrasonic_trigger:
	RETURN
; end of embeddedproj_15_ultrasonic_trigger

embeddedproj_15_echo_width_us:

;embeddedproj_15.c,277 :: 		static unsigned int echo_width_us(unsigned char echo_mask)
;embeddedproj_15.c,282 :: 		t0 = t1_now_us();
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_echo_width_us_t0_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_echo_width_us_t0_L0+1
;embeddedproj_15.c,283 :: 		while((PORTD & echo_mask) == 0) {
L_embeddedproj_15_echo_width_us18:
	MOVF       FARG_embeddedproj_15_echo_width_us_echo_mask+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_echo_width_us19
;embeddedproj_15.c,284 :: 		if((unsigned int)(t1_now_us() - t0) > US_WAIT_RISE_TIMEOUT_US) {
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       embeddedproj_15_echo_width_us_t0_L0+0, 0
	SUBWF      R0+0, 0
	MOVWF      R2+0
	MOVF       embeddedproj_15_echo_width_us_t0_L0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      R0+1, 0
	MOVWF      R2+1
	MOVF       R2+1, 0
	SUBLW      117
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_echo_width_us194
	MOVF       R2+0, 0
	SUBLW      48
L_embeddedproj_15_echo_width_us194:
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_echo_width_us20
;embeddedproj_15.c,285 :: 		return 0;
	CLRF       R0+0
	CLRF       R0+1
	GOTO       L_end_echo_width_us
;embeddedproj_15.c,286 :: 		}
L_embeddedproj_15_echo_width_us20:
;embeddedproj_15.c,287 :: 		}
	GOTO       L_embeddedproj_15_echo_width_us18
L_embeddedproj_15_echo_width_us19:
;embeddedproj_15.c,290 :: 		t0 = t1_now_us(); // reset t0 to current t1 time
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_echo_width_us_t0_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_echo_width_us_t0_L0+1
;embeddedproj_15.c,291 :: 		while((PORTD & echo_mask) != 0) {
L_embeddedproj_15_echo_width_us21:
	MOVF       FARG_embeddedproj_15_echo_width_us_echo_mask+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_embeddedproj_15_echo_width_us22
;embeddedproj_15.c,292 :: 		if((unsigned int)(t1_now_us() - t0) > US_WAIT_FALL_TIMEOUT_US) {
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       embeddedproj_15_echo_width_us_t0_L0+0, 0
	SUBWF      R0+0, 0
	MOVWF      R2+0
	MOVF       embeddedproj_15_echo_width_us_t0_L0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      R0+1, 0
	MOVWF      R2+1
	MOVF       R2+1, 0
	SUBLW      136
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_echo_width_us195
	MOVF       R2+0, 0
	SUBLW      184
L_embeddedproj_15_echo_width_us195:
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_echo_width_us23
;embeddedproj_15.c,293 :: 		return 0;
	CLRF       R0+0
	CLRF       R0+1
	GOTO       L_end_echo_width_us
;embeddedproj_15.c,294 :: 		}
L_embeddedproj_15_echo_width_us23:
;embeddedproj_15.c,295 :: 		}
	GOTO       L_embeddedproj_15_echo_width_us21
L_embeddedproj_15_echo_width_us22:
;embeddedproj_15.c,297 :: 		return (unsigned int)(t1_now_us() - t0);
	CALL       embeddedproj_15_t1_now_us+0
	MOVF       embeddedproj_15_echo_width_us_t0_L0+0, 0
	SUBWF      R0+0, 1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       embeddedproj_15_echo_width_us_t0_L0+1, 0
	SUBWF      R0+1, 1
;embeddedproj_15.c,298 :: 		}
L_end_echo_width_us:
	RETURN
; end of embeddedproj_15_echo_width_us

embeddedproj_15_ultrasonic_read_cm:

;embeddedproj_15.c,300 :: 		static unsigned int ultrasonic_read_cm(unsigned char trig_mask, unsigned char echo_mask)
;embeddedproj_15.c,304 :: 		ultrasonic_trigger(trig_mask);
	MOVF       FARG_embeddedproj_15_ultrasonic_read_cm_trig_mask+0, 0
	MOVWF      FARG_embeddedproj_15_ultrasonic_trigger_trig_mask+0
	CALL       embeddedproj_15_ultrasonic_trigger+0
;embeddedproj_15.c,305 :: 		us = echo_width_us(echo_mask);
	MOVF       FARG_embeddedproj_15_ultrasonic_read_cm_echo_mask+0, 0
	MOVWF      FARG_embeddedproj_15_echo_width_us_echo_mask+0
	CALL       embeddedproj_15_echo_width_us+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_ultrasonic_read_cm_us_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_ultrasonic_read_cm_us_L0+1
;embeddedproj_15.c,307 :: 		if(us == 0) return 0;
	MOVLW      0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_ultrasonic_read_cm197
	MOVLW      0
	XORWF      R0+0, 0
L_embeddedproj_15_ultrasonic_read_cm197:
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_ultrasonic_read_cm24
	CLRF       R0+0
	CLRF       R0+1
	GOTO       L_end_ultrasonic_read_cm
L_embeddedproj_15_ultrasonic_read_cm24:
;embeddedproj_15.c,310 :: 		return (unsigned int)(us / 58);
	MOVLW      58
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       embeddedproj_15_ultrasonic_read_cm_us_L0+0, 0
	MOVWF      R0+0
	MOVF       embeddedproj_15_ultrasonic_read_cm_us_L0+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
;embeddedproj_15.c,311 :: 		}
L_end_ultrasonic_read_cm:
	RETURN
; end of embeddedproj_15_ultrasonic_read_cm

_ir_sensors:

;embeddedproj_15.c,313 :: 		void ir_sensors(unsigned char base1, unsigned char curve_base1, unsigned char slow1, unsigned char trimL1, unsigned char trimR1)
;embeddedproj_15.c,316 :: 		unsigned char L = sensor_left();
	CALL       _sensor_left+0
	MOVF       R0+0, 0
	MOVWF      ir_sensors_L_L0+0
;embeddedproj_15.c,317 :: 		unsigned char R = sensor_right();
	CALL       _sensor_right+0
	MOVF       R0+0, 0
	MOVWF      ir_sensors_R_L0+0
;embeddedproj_15.c,318 :: 		if(L == 1 && R == 1){
	MOVF       ir_sensors_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors27
	MOVF       ir_sensors_R_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors27
L__ir_sensors147:
;embeddedproj_15.c,319 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,320 :: 		pwm_left(base1 + trimL1 + 20);
	MOVF       FARG_ir_sensors_trimL1+0, 0
	ADDWF      FARG_ir_sensors_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	MOVLW      20
	ADDWF      FARG_pwm_left_val+0, 1
	CALL       _pwm_left+0
;embeddedproj_15.c,321 :: 		pwm_right(base1 + trimR1 + 20);
	MOVF       FARG_ir_sensors_trimR1+0, 0
	ADDWF      FARG_ir_sensors_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	MOVLW      20
	ADDWF      FARG_pwm_right_val+0, 1
	CALL       _pwm_right+0
;embeddedproj_15.c,322 :: 		}
	GOTO       L_ir_sensors28
L_ir_sensors27:
;embeddedproj_15.c,323 :: 		else if(L == 0 && R == 0){ // both see wall - almost impossible so do motor_stop()
	MOVF       ir_sensors_L_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors31
	MOVF       ir_sensors_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors31
L__ir_sensors146:
;embeddedproj_15.c,324 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,325 :: 		pwm_left(base1 + trimL1 + 20);
	MOVF       FARG_ir_sensors_trimL1+0, 0
	ADDWF      FARG_ir_sensors_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	MOVLW      20
	ADDWF      FARG_pwm_left_val+0, 1
	CALL       _pwm_left+0
;embeddedproj_15.c,326 :: 		pwm_right(base1 + trimR1 + 20);
	MOVF       FARG_ir_sensors_trimR1+0, 0
	ADDWF      FARG_ir_sensors_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	MOVLW      20
	ADDWF      FARG_pwm_right_val+0, 1
	CALL       _pwm_right+0
;embeddedproj_15.c,327 :: 		}
	GOTO       L_ir_sensors32
L_ir_sensors31:
;embeddedproj_15.c,328 :: 		else if(L == 1 && R == 0){ // right sees wall, speed right up / slow left down.
	MOVF       ir_sensors_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors35
	MOVF       ir_sensors_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_ir_sensors35
L__ir_sensors145:
;embeddedproj_15.c,329 :: 		pivot_left();
	CALL       _pivot_left+0
;embeddedproj_15.c,330 :: 		pwm_right(curve_base1);
	MOVF       FARG_ir_sensors_curve_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,331 :: 		pwm_left(slow1);
	MOVF       FARG_ir_sensors_slow1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,332 :: 		}
	GOTO       L_ir_sensors36
L_ir_sensors35:
;embeddedproj_15.c,334 :: 		pivot_right();
	CALL       _pivot_right+0
;embeddedproj_15.c,335 :: 		pwm_left(curve_base1);
	MOVF       FARG_ir_sensors_curve_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,336 :: 		pwm_right(slow1);
	MOVF       FARG_ir_sensors_slow1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,337 :: 		}
L_ir_sensors36:
L_ir_sensors32:
L_ir_sensors28:
;embeddedproj_15.c,338 :: 		}
L_end_ir_sensors:
	RETURN
; end of _ir_sensors

_line_follow_step_final:

;embeddedproj_15.c,340 :: 		void line_follow_step_final(unsigned char base1, unsigned char curve_base1, unsigned char trimL1, unsigned char trimR1, unsigned char slow1)
;embeddedproj_15.c,342 :: 		unsigned char L = line_left();
	CALL       _line_left+0
	MOVF       R0+0, 0
	MOVWF      line_follow_step_final_L_L0+0
;embeddedproj_15.c,343 :: 		unsigned char R = line_right();
	CALL       _line_right+0
	MOVF       R0+0, 0
	MOVWF      line_follow_step_final_R_L0+0
;embeddedproj_15.c,345 :: 		if(L == 1 && R == 1){
	MOVF       line_follow_step_final_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final39
	MOVF       line_follow_step_final_R_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final39
L__line_follow_step_final150:
;embeddedproj_15.c,346 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,347 :: 		pwm_left(slow1);
	MOVF       FARG_line_follow_step_final_slow1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,348 :: 		pwm_right(slow1);
	MOVF       FARG_line_follow_step_final_slow1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,349 :: 		}
	GOTO       L_line_follow_step_final40
L_line_follow_step_final39:
;embeddedproj_15.c,350 :: 		else if(L == 0 && R == 0){
	MOVF       line_follow_step_final_L_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final43
	MOVF       line_follow_step_final_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final43
L__line_follow_step_final149:
;embeddedproj_15.c,351 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,352 :: 		pwm_left(base1 + trimL1);
	MOVF       FARG_line_follow_step_final_trimL1+0, 0
	ADDWF      FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,353 :: 		pwm_right(base1 + trimR1);
	MOVF       FARG_line_follow_step_final_trimR1+0, 0
	ADDWF      FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,354 :: 		}
	GOTO       L_line_follow_step_final44
L_line_follow_step_final43:
;embeddedproj_15.c,355 :: 		else if(L == 1 && R == 0){
	MOVF       line_follow_step_final_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final47
	MOVF       line_follow_step_final_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step_final47
L__line_follow_step_final148:
;embeddedproj_15.c,356 :: 		pivot_left();
	CALL       _pivot_left+0
;embeddedproj_15.c,357 :: 		pwm_right(base1 + trimR1 + 40);
	MOVF       FARG_line_follow_step_final_trimR1+0, 0
	ADDWF      FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	MOVLW      40
	ADDWF      FARG_pwm_right_val+0, 1
	CALL       _pwm_right+0
;embeddedproj_15.c,358 :: 		pwm_left(base1);
	MOVF       FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,359 :: 		}
	GOTO       L_line_follow_step_final48
L_line_follow_step_final47:
;embeddedproj_15.c,361 :: 		pivot_right();
	CALL       _pivot_right+0
;embeddedproj_15.c,362 :: 		pwm_left(base1 + trimL1 + 40);
	MOVF       FARG_line_follow_step_final_trimL1+0, 0
	ADDWF      FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	MOVLW      40
	ADDWF      FARG_pwm_left_val+0, 1
	CALL       _pwm_left+0
;embeddedproj_15.c,363 :: 		pwm_right(base1);
	MOVF       FARG_line_follow_step_final_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,364 :: 		}
L_line_follow_step_final48:
L_line_follow_step_final44:
L_line_follow_step_final40:
;embeddedproj_15.c,365 :: 		}
L_end_line_follow_step_final:
	RETURN
; end of _line_follow_step_final

_line_follow_step:

;embeddedproj_15.c,367 :: 		void line_follow_step(unsigned char base1, unsigned char curve_base1, unsigned char trimL1, unsigned char trimR1)
;embeddedproj_15.c,369 :: 		unsigned char L = line_left();
	CALL       _line_left+0
	MOVF       R0+0, 0
	MOVWF      line_follow_step_L_L0+0
;embeddedproj_15.c,370 :: 		unsigned char R = line_right();
	CALL       _line_right+0
	MOVF       R0+0, 0
	MOVWF      line_follow_step_R_L0+0
;embeddedproj_15.c,372 :: 		if(L == 1 && R == 1){
	MOVF       line_follow_step_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step51
	MOVF       line_follow_step_R_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step51
L__line_follow_step153:
;embeddedproj_15.c,373 :: 		left_90();
	CALL       _left_90+0
;embeddedproj_15.c,374 :: 		}
	GOTO       L_line_follow_step52
L_line_follow_step51:
;embeddedproj_15.c,375 :: 		else if(L == 0 && R == 0){
	MOVF       line_follow_step_L_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step55
	MOVF       line_follow_step_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step55
L__line_follow_step152:
;embeddedproj_15.c,376 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,377 :: 		pwm_left(base1 + trimL1);
	MOVF       FARG_line_follow_step_trimL1+0, 0
	ADDWF      FARG_line_follow_step_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,378 :: 		pwm_right(base1 + trimR1);
	MOVF       FARG_line_follow_step_trimR1+0, 0
	ADDWF      FARG_line_follow_step_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,379 :: 		}
	GOTO       L_line_follow_step56
L_line_follow_step55:
;embeddedproj_15.c,380 :: 		else if(L == 1 && R == 0){
	MOVF       line_follow_step_L_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step59
	MOVF       line_follow_step_R_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_line_follow_step59
L__line_follow_step151:
;embeddedproj_15.c,381 :: 		pivot_left();
	CALL       _pivot_left+0
;embeddedproj_15.c,382 :: 		pwm_right(curve_base1 + trimR1);
	MOVF       FARG_line_follow_step_trimR1+0, 0
	ADDWF      FARG_line_follow_step_curve_base1+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,383 :: 		pwm_left(0);
	CLRF       FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,384 :: 		}
	GOTO       L_line_follow_step60
L_line_follow_step59:
;embeddedproj_15.c,386 :: 		pivot_right();
	CALL       _pivot_right+0
;embeddedproj_15.c,387 :: 		pwm_left(curve_base1 + trimL1);
	MOVF       FARG_line_follow_step_trimL1+0, 0
	ADDWF      FARG_line_follow_step_curve_base1+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,388 :: 		pwm_right(0);
	CLRF       FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,389 :: 		}
L_line_follow_step60:
L_line_follow_step56:
L_line_follow_step52:
;embeddedproj_15.c,390 :: 		}
L_end_line_follow_step:
	RETURN
; end of _line_follow_step

_line_follow_boost_ms:

;embeddedproj_15.c,392 :: 		void line_follow_boost_ms(unsigned char base_boost, unsigned char curve_boost, unsigned char trimL1, unsigned char trimR1, unsigned int duration_ms)
;embeddedproj_15.c,394 :: 		unsigned long start = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      line_follow_boost_ms_start_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      line_follow_boost_ms_start_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      line_follow_boost_ms_start_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      line_follow_boost_ms_start_L0+3
;embeddedproj_15.c,396 :: 		while((unsigned long)(sys_ms - start) < (unsigned long)duration_ms)
L_line_follow_boost_ms61:
	MOVF       _sys_ms+0, 0
	MOVWF      R5+0
	MOVF       _sys_ms+1, 0
	MOVWF      R5+1
	MOVF       _sys_ms+2, 0
	MOVWF      R5+2
	MOVF       _sys_ms+3, 0
	MOVWF      R5+3
	MOVF       line_follow_boost_ms_start_L0+0, 0
	SUBWF      R5+0, 1
	MOVF       line_follow_boost_ms_start_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     line_follow_boost_ms_start_L0+1, 0
	SUBWF      R5+1, 1
	MOVF       line_follow_boost_ms_start_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     line_follow_boost_ms_start_L0+2, 0
	SUBWF      R5+2, 1
	MOVF       line_follow_boost_ms_start_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     line_follow_boost_ms_start_L0+3, 0
	SUBWF      R5+3, 1
	MOVF       FARG_line_follow_boost_ms_duration_ms+0, 0
	MOVWF      R1+0
	MOVF       FARG_line_follow_boost_ms_duration_ms+1, 0
	MOVWF      R1+1
	CLRF       R1+2
	CLRF       R1+3
	MOVF       R1+3, 0
	SUBWF      R5+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__line_follow_boost_ms202
	MOVF       R1+2, 0
	SUBWF      R5+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__line_follow_boost_ms202
	MOVF       R1+1, 0
	SUBWF      R5+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__line_follow_boost_ms202
	MOVF       R1+0, 0
	SUBWF      R5+0, 0
L__line_follow_boost_ms202:
	BTFSC      STATUS+0, 0
	GOTO       L_line_follow_boost_ms62
;embeddedproj_15.c,398 :: 		line_follow_step(base_boost, curve_boost, trimL1, trimR1);
	MOVF       FARG_line_follow_boost_ms_base_boost+0, 0
	MOVWF      FARG_line_follow_step_base1+0
	MOVF       FARG_line_follow_boost_ms_curve_boost+0, 0
	MOVWF      FARG_line_follow_step_curve_base1+0
	MOVF       FARG_line_follow_boost_ms_trimL1+0, 0
	MOVWF      FARG_line_follow_step_trimL1+0
	MOVF       FARG_line_follow_boost_ms_trimR1+0, 0
	MOVWF      FARG_line_follow_step_trimR1+0
	CALL       _line_follow_step+0
;embeddedproj_15.c,399 :: 		}
	GOTO       L_line_follow_boost_ms61
L_line_follow_boost_ms62:
;embeddedproj_15.c,400 :: 		}
L_end_line_follow_boost_ms:
	RETURN
; end of _line_follow_boost_ms

_servo_write_us:

;embeddedproj_15.c,402 :: 		void servo_write_us(unsigned int us)
;embeddedproj_15.c,404 :: 		PORTD |= SERVO_MASK;
	BSF        PORTD+0, 4
;embeddedproj_15.c,405 :: 		t1_wait_us(us);                 // 1000–2000 us
	MOVF       FARG_servo_write_us_us+0, 0
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	MOVF       FARG_servo_write_us_us+1, 0
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,406 :: 		PORTD &= (unsigned char)~SERVO_MASK;
	MOVLW      239
	ANDWF      PORTD+0, 1
;embeddedproj_15.c,408 :: 		t1_wait_us(20000 - us);         // rest of 20ms frame
	MOVF       FARG_servo_write_us_us+0, 0
	SUBLW      32
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+0
	MOVF       FARG_servo_write_us_us+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      78
	MOVWF      FARG_embeddedproj_15_t1_wait_us_us+1
	CALL       embeddedproj_15_t1_wait_us+0
;embeddedproj_15.c,409 :: 		}
L_end_servo_write_us:
	RETURN
; end of _servo_write_us

_raise_flag:

;embeddedproj_15.c,411 :: 		void raise_flag(void)
;embeddedproj_15.c,414 :: 		for(k=0; k<50; k++)           // ~1 second
	CLRF       raise_flag_k_L0+0
	CLRF       raise_flag_k_L0+1
L_raise_flag63:
	MOVLW      0
	SUBWF      raise_flag_k_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__raise_flag205
	MOVLW      50
	SUBWF      raise_flag_k_L0+0, 0
L__raise_flag205:
	BTFSC      STATUS+0, 0
	GOTO       L_raise_flag64
;embeddedproj_15.c,415 :: 		servo_write_us(2000);     // try 1800–2200 as needed
	MOVLW      208
	MOVWF      FARG_servo_write_us_us+0
	MOVLW      7
	MOVWF      FARG_servo_write_us_us+1
	CALL       _servo_write_us+0
;embeddedproj_15.c,414 :: 		for(k=0; k<50; k++)           // ~1 second
	INCF       raise_flag_k_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       raise_flag_k_L0+1, 1
;embeddedproj_15.c,415 :: 		servo_write_us(2000);     // try 1800–2200 as needed
	GOTO       L_raise_flag63
L_raise_flag64:
;embeddedproj_15.c,416 :: 		}
L_end_raise_flag:
	RETURN
; end of _raise_flag

embeddedproj_15_parking_marker_seen:

;embeddedproj_15.c,420 :: 		static unsigned char parking_marker_seen(void)
;embeddedproj_15.c,426 :: 		if((unsigned long)(sys_ms - last_ms) < 10) return 0;
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       embeddedproj_15_parking_marker_seen_last_ms_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       embeddedproj_15_parking_marker_seen_last_ms_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     embeddedproj_15_parking_marker_seen_last_ms_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       embeddedproj_15_parking_marker_seen_last_ms_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     embeddedproj_15_parking_marker_seen_last_ms_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       embeddedproj_15_parking_marker_seen_last_ms_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     embeddedproj_15_parking_marker_seen_last_ms_L0+3, 0
	SUBWF      R1+3, 1
	MOVLW      0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_parking_marker_seen207
	MOVLW      0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_parking_marker_seen207
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_parking_marker_seen207
	MOVLW      10
	SUBWF      R1+0, 0
L_embeddedproj_15_parking_marker_seen207:
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_parking_marker_seen66
	CLRF       R0+0
	GOTO       L_end_parking_marker_seen
L_embeddedproj_15_parking_marker_seen66:
;embeddedproj_15.c,427 :: 		last_ms = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      embeddedproj_15_parking_marker_seen_last_ms_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      embeddedproj_15_parking_marker_seen_last_ms_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      embeddedproj_15_parking_marker_seen_last_ms_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      embeddedproj_15_parking_marker_seen_last_ms_L0+3
;embeddedproj_15.c,429 :: 		if(line_left() && line_right()) {
	CALL       _line_left+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_embeddedproj_15_parking_marker_seen69
	CALL       _line_right+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_embeddedproj_15_parking_marker_seen69
L_embeddedproj_15_parking_marker_seen154:
;embeddedproj_15.c,430 :: 		if(seen < 20) seen++;
	MOVLW      20
	SUBWF      embeddedproj_15_parking_marker_seen_seen_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_parking_marker_seen70
	INCF       embeddedproj_15_parking_marker_seen_seen_L0+0, 1
L_embeddedproj_15_parking_marker_seen70:
;embeddedproj_15.c,431 :: 		} else {
	GOTO       L_embeddedproj_15_parking_marker_seen71
L_embeddedproj_15_parking_marker_seen69:
;embeddedproj_15.c,432 :: 		seen = 0;
	CLRF       embeddedproj_15_parking_marker_seen_seen_L0+0
;embeddedproj_15.c,433 :: 		}
L_embeddedproj_15_parking_marker_seen71:
;embeddedproj_15.c,435 :: 		return (seen >= 5);   // needs ~50ms stable now
	MOVLW      5
	SUBWF      embeddedproj_15_parking_marker_seen_seen_L0+0, 0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
;embeddedproj_15.c,436 :: 		}
L_end_parking_marker_seen:
	RETURN
; end of embeddedproj_15_parking_marker_seen

_beeping:

;embeddedproj_15.c,438 :: 		void beeping (unsigned char parked){
;embeddedproj_15.c,439 :: 		if(parked && (buzz_tick < 1000)){
	MOVF       FARG_beeping_parked+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_beeping74
	MOVLW      3
	SUBWF      _buzz_tick+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__beeping209
	MOVLW      232
	SUBWF      _buzz_tick+0, 0
L__beeping209:
	BTFSC      STATUS+0, 0
	GOTO       L_beeping74
L__beeping155:
;embeddedproj_15.c,440 :: 		buzzer_on();
	CALL       embeddedproj_15_buzzer_on+0
;embeddedproj_15.c,441 :: 		}else {
	GOTO       L_beeping75
L_beeping74:
;embeddedproj_15.c,442 :: 		buzzer_off();
	CALL       embeddedproj_15_buzzer_off+0
;embeddedproj_15.c,443 :: 		}
L_beeping75:
;embeddedproj_15.c,444 :: 		}
L_end_beeping:
	RETURN
; end of _beeping

embeddedproj_15_park_right:

;embeddedproj_15.c,448 :: 		static void park_right(void)
;embeddedproj_15.c,451 :: 		motor_stop();
	CALL       _motor_stop+0
;embeddedproj_15.c,452 :: 		wait_ms(150);
	MOVLW      150
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	CLRF       FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,455 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,456 :: 		pwm_left(slow);
	MOVLW      40
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,457 :: 		pwm_right(slow);
	MOVLW      40
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,458 :: 		wait_ms(800);
	MOVLW      32
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVLW      3
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,462 :: 		right_90();
	CALL       _right_90+0
;embeddedproj_15.c,465 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,466 :: 		pwm_left(slow);
	MOVLW      40
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,467 :: 		pwm_right(slow);
	MOVLW      40
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,468 :: 		wait_ms(200);
	MOVLW      200
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	CLRF       FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,471 :: 		motor_stop();
	CALL       _motor_stop+0
;embeddedproj_15.c,472 :: 		wait_ms(200);
	MOVLW      200
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	CLRF       FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,473 :: 		}
L_end_park_right:
	RETURN
; end of embeddedproj_15_park_right

embeddedproj_15_wait_front_le:

;embeddedproj_15.c,475 :: 		static unsigned int wait_front_le(unsigned int cm, unsigned int sample_ms)
;embeddedproj_15.c,479 :: 		wait_ms(sample_ms);
	MOVF       FARG_embeddedproj_15_wait_front_le_sample_ms+0, 0
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVF       FARG_embeddedproj_15_wait_front_le_sample_ms+1, 0
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,480 :: 		dF = ultrasonic_read_cm(US_TRIG_F, US_ECHO_F);
	MOVLW      4
	MOVWF      FARG_embeddedproj_15_ultrasonic_read_cm_trig_mask+0
	MOVLW      8
	MOVWF      FARG_embeddedproj_15_ultrasonic_read_cm_echo_mask+0
	CALL       embeddedproj_15_ultrasonic_read_cm+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_wait_front_le_dF_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_wait_front_le_dF_L0+1
;embeddedproj_15.c,482 :: 		if(dF != 0 && dF <= cm) return dF;  // obstacle found
	MOVLW      0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_le212
	MOVLW      0
	XORWF      R0+0, 0
L_embeddedproj_15_wait_front_le212:
	BTFSC      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_le78
	MOVF       embeddedproj_15_wait_front_le_dF_L0+1, 0
	SUBWF      FARG_embeddedproj_15_wait_front_le_cm+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_le213
	MOVF       embeddedproj_15_wait_front_le_dF_L0+0, 0
	SUBWF      FARG_embeddedproj_15_wait_front_le_cm+0, 0
L_embeddedproj_15_wait_front_le213:
	BTFSS      STATUS+0, 0
	GOTO       L_embeddedproj_15_wait_front_le78
L_embeddedproj_15_wait_front_le156:
	MOVF       embeddedproj_15_wait_front_le_dF_L0+0, 0
	MOVWF      R0+0
	MOVF       embeddedproj_15_wait_front_le_dF_L0+1, 0
	MOVWF      R0+1
	GOTO       L_end_wait_front_le
L_embeddedproj_15_wait_front_le78:
;embeddedproj_15.c,483 :: 		else return 0;
	CLRF       R0+0
	CLRF       R0+1
;embeddedproj_15.c,484 :: 		}
L_end_wait_front_le:
	RETURN
; end of embeddedproj_15_wait_front_le

embeddedproj_15_wait_front_ge_stable:

;embeddedproj_15.c,486 :: 		static void wait_front_ge_stable(unsigned int cm, unsigned char stable_needed, unsigned int sample_ms)
;embeddedproj_15.c,488 :: 		unsigned char stable = 0;
	CLRF       embeddedproj_15_wait_front_ge_stable_stable_L0+0
;embeddedproj_15.c,491 :: 		while(stable < stable_needed)
L_embeddedproj_15_wait_front_ge_stable80:
	MOVF       FARG_embeddedproj_15_wait_front_ge_stable_stable_needed+0, 0
	SUBWF      embeddedproj_15_wait_front_ge_stable_stable_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_embeddedproj_15_wait_front_ge_stable81
;embeddedproj_15.c,493 :: 		wait_ms(sample_ms);
	MOVF       FARG_embeddedproj_15_wait_front_ge_stable_sample_ms+0, 0
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVF       FARG_embeddedproj_15_wait_front_ge_stable_sample_ms+1, 0
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,495 :: 		dF = ultrasonic_read_cm(US_TRIG_F, US_ECHO_F);
	MOVLW      4
	MOVWF      FARG_embeddedproj_15_ultrasonic_read_cm_trig_mask+0
	MOVLW      8
	MOVWF      FARG_embeddedproj_15_ultrasonic_read_cm_echo_mask+0
	CALL       embeddedproj_15_ultrasonic_read_cm+0
	MOVF       R0+0, 0
	MOVWF      embeddedproj_15_wait_front_ge_stable_dF_L0+0
	MOVF       R0+1, 0
	MOVWF      embeddedproj_15_wait_front_ge_stable_dF_L0+1
;embeddedproj_15.c,496 :: 		if(dF != 0 && dF >= cm) stable++;
	MOVLW      0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_ge_stable215
	MOVLW      0
	XORWF      R0+0, 0
L_embeddedproj_15_wait_front_ge_stable215:
	BTFSC      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_ge_stable84
	MOVF       FARG_embeddedproj_15_wait_front_ge_stable_cm+1, 0
	SUBWF      embeddedproj_15_wait_front_ge_stable_dF_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_wait_front_ge_stable216
	MOVF       FARG_embeddedproj_15_wait_front_ge_stable_cm+0, 0
	SUBWF      embeddedproj_15_wait_front_ge_stable_dF_L0+0, 0
L_embeddedproj_15_wait_front_ge_stable216:
	BTFSS      STATUS+0, 0
	GOTO       L_embeddedproj_15_wait_front_ge_stable84
L_embeddedproj_15_wait_front_ge_stable157:
	INCF       embeddedproj_15_wait_front_ge_stable_stable_L0+0, 1
	GOTO       L_embeddedproj_15_wait_front_ge_stable85
L_embeddedproj_15_wait_front_ge_stable84:
;embeddedproj_15.c,497 :: 		else stable = 0;
	CLRF       embeddedproj_15_wait_front_ge_stable_stable_L0+0
L_embeddedproj_15_wait_front_ge_stable85:
;embeddedproj_15.c,498 :: 		}
	GOTO       L_embeddedproj_15_wait_front_ge_stable80
L_embeddedproj_15_wait_front_ge_stable81:
;embeddedproj_15.c,499 :: 		}
L_end_wait_front_ge_stable:
	RETURN
; end of embeddedproj_15_wait_front_ge_stable

embeddedproj_15_turn_and_clear:

;embeddedproj_15.c,503 :: 		static void turn_and_clear(TurnDir dir, unsigned char base_pwm, unsigned char trimL1, unsigned char trimR1)
;embeddedproj_15.c,506 :: 		if(dir == TURN_RIGHT) {
	MOVF       FARG_embeddedproj_15_turn_and_clear_dir+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_embeddedproj_15_turn_and_clear86
;embeddedproj_15.c,507 :: 		right_90();
	CALL       _right_90+0
;embeddedproj_15.c,508 :: 		} else {
	GOTO       L_embeddedproj_15_turn_and_clear87
L_embeddedproj_15_turn_and_clear86:
;embeddedproj_15.c,509 :: 		left_90();
	CALL       _left_90+0
;embeddedproj_15.c,510 :: 		}
L_embeddedproj_15_turn_and_clear87:
;embeddedproj_15.c,513 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,514 :: 		pwm_left(base_pwm + trimL1);
	MOVF       FARG_embeddedproj_15_turn_and_clear_trimL1+0, 0
	ADDWF      FARG_embeddedproj_15_turn_and_clear_base_pwm+0, 0
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,515 :: 		pwm_right(base_pwm + trimR1);
	MOVF       FARG_embeddedproj_15_turn_and_clear_trimR1+0, 0
	ADDWF      FARG_embeddedproj_15_turn_and_clear_base_pwm+0, 0
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,518 :: 		wait_front_ge_stable(30, 3, 25);
	MOVLW      30
	MOVWF      FARG_embeddedproj_15_wait_front_ge_stable_cm+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_wait_front_ge_stable_cm+1
	MOVLW      3
	MOVWF      FARG_embeddedproj_15_wait_front_ge_stable_stable_needed+0
	MOVLW      25
	MOVWF      FARG_embeddedproj_15_wait_front_ge_stable_sample_ms+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_wait_front_ge_stable_sample_ms+1
	CALL       embeddedproj_15_wait_front_ge_stable+0
;embeddedproj_15.c,519 :: 		}
L_end_turn_and_clear:
	RETURN
; end of embeddedproj_15_turn_and_clear

_main:

;embeddedproj_15.c,522 :: 		void main(void)
;embeddedproj_15.c,526 :: 		unsigned int ldr = 0;
;embeddedproj_15.c,527 :: 		unsigned long last_ldr_ms = 0;
	CLRF       main_last_ldr_ms_L0+0
	CLRF       main_last_ldr_ms_L0+1
	CLRF       main_last_ldr_ms_L0+2
	CLRF       main_last_ldr_ms_L0+3
	CLRF       main_dark_cnt_L0+0
	CLRF       main_bright_cnt_L0+0
	CLRF       main_mode_L0+0
	CLRF       main_us_flag_L0+0
	CLRF       main_turn_counter_L0+0
	CLRF       main_obstacle_seen_L0+0
	CLRF       main_t_L0+0
	CLRF       main_t_L0+1
	CLRF       main_t_L0+2
	CLRF       main_t_L0+3
	CLRF       main_tunnel_boost_done_L0+0
	CLRF       main_step_start_ms_L0+0
	CLRF       main_step_start_ms_L0+1
	CLRF       main_step_start_ms_L0+2
	CLRF       main_step_start_ms_L0+3
	CLRF       main_hit_cnt_L0+0
	CLRF       main_parked_L0+0
	CLRF       main_parking_seen_L0+0
;embeddedproj_15.c,558 :: 		TRISB |= 0x03;                 // RB0,RB1 inputs (line sensors)
	MOVLW      3
	IORWF      TRISB+0, 1
;embeddedproj_15.c,559 :: 		TRISD |= 0x03;                 // RB0,RB1 inputs (ir sensors for ultrasonic)
	MOVLW      3
	IORWF      TRISD+0, 1
;embeddedproj_15.c,561 :: 		TRISD &= (unsigned char)~SERVO_MASK;   // RD4 output
	MOVLW      239
	ANDWF      TRISD+0, 1
;embeddedproj_15.c,562 :: 		PORTD &= (unsigned char)~SERVO_MASK;   // start low
	MOVLW      239
	ANDWF      PORTD+0, 1
;embeddedproj_15.c,564 :: 		TRISB |= (unsigned char) 0x70;  // RB4,RB5,RB6 input
	MOVLW      112
	IORWF      TRISB+0, 1
;embeddedproj_15.c,566 :: 		TRISB &= (unsigned char)~0x80; // RB7 output (LED)
	MOVLW      127
	ANDWF      TRISB+0, 1
;embeddedproj_15.c,567 :: 		PORTB &= (unsigned char)~0x80; // LED off
	MOVLW      127
	ANDWF      PORTB+0, 1
;embeddedproj_15.c,569 :: 		buzzer_init();                 // RB2 output, OFF
	CALL       embeddedproj_15_buzzer_init+0
;embeddedproj_15.c,571 :: 		TRISC = 0x09;                  // RC0,RC3 input; RC1,RC2,RC4..RC7 outputs
	MOVLW      9
	MOVWF      TRISC+0
;embeddedproj_15.c,572 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;embeddedproj_15.c,574 :: 		timer0_init_1ms();
	CALL       _timer0_init_1ms+0
;embeddedproj_15.c,575 :: 		pwm_init();
	CALL       _pwm_init+0
;embeddedproj_15.c,577 :: 		timer1_init_us();              // needed for ADC acquisition + ultrasonic timing
	CALL       embeddedproj_15_timer1_init_us+0
;embeddedproj_15.c,578 :: 		ultrasonic_init();
	CALL       embeddedproj_15_ultrasonic_init+0
;embeddedproj_15.c,579 :: 		adc_init_an0();
	CALL       embeddedproj_15_adc_init_an0+0
;embeddedproj_15.c,582 :: 		while(sys_ms < 3000) { }
L_main88:
	MOVLW      0
	SUBWF      _sys_ms+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main219
	MOVLW      0
	SUBWF      _sys_ms+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main219
	MOVLW      11
	SUBWF      _sys_ms+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main219
	MOVLW      184
	SUBWF      _sys_ms+0, 0
L__main219:
	BTFSC      STATUS+0, 0
	GOTO       L_main89
	GOTO       L_main88
L_main89:
;embeddedproj_15.c,583 :: 		PORTB |= 0x80;                 // LED on
	BSF        PORTB+0, 7
;embeddedproj_15.c,586 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,587 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,588 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,591 :: 		line_follow_boost_ms(180, 180, trimL, trimR, 400);   // 0.4 sec boost (tune)
	MOVLW      180
	MOVWF      FARG_line_follow_boost_ms_base_boost+0
	MOVLW      180
	MOVWF      FARG_line_follow_boost_ms_curve_boost+0
	MOVLW      4
	MOVWF      FARG_line_follow_boost_ms_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_boost_ms_trimR1+0
	MOVLW      144
	MOVWF      FARG_line_follow_boost_ms_duration_ms+0
	MOVLW      1
	MOVWF      FARG_line_follow_boost_ms_duration_ms+1
	CALL       _line_follow_boost_ms+0
;embeddedproj_15.c,592 :: 		line_follow_boost_ms(30, 30, trimL, trimR, 100);   // 0.4 sec boost (tune)
	MOVLW      30
	MOVWF      FARG_line_follow_boost_ms_base_boost+0
	MOVLW      30
	MOVWF      FARG_line_follow_boost_ms_curve_boost+0
	MOVLW      4
	MOVWF      FARG_line_follow_boost_ms_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_boost_ms_trimR1+0
	MOVLW      100
	MOVWF      FARG_line_follow_boost_ms_duration_ms+0
	MOVLW      0
	MOVWF      FARG_line_follow_boost_ms_duration_ms+1
	CALL       _line_follow_boost_ms+0
;embeddedproj_15.c,594 :: 		while((PORTB & START_BUTTON) != 0){
	MOVLW      64
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main91
;embeddedproj_15.c,595 :: 		while(1)
L_main92:
;embeddedproj_15.c,597 :: 		while(mode == 0)
L_main94:
	MOVF       main_mode_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main95
;embeddedproj_15.c,600 :: 		line_follow_step(base, curve_base, trimL, trimR);
	MOVLW      50
	MOVWF      FARG_line_follow_step_base1+0
	MOVLW      180
	MOVWF      FARG_line_follow_step_curve_base1+0
	MOVLW      4
	MOVWF      FARG_line_follow_step_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_step_trimR1+0
	CALL       _line_follow_step+0
;embeddedproj_15.c,603 :: 		if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       main_last_ldr_ms_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_last_ldr_ms_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_last_ldr_ms_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_last_ldr_ms_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+3, 0
	SUBWF      R1+3, 1
	MOVLW      0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main220
	MOVLW      0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main220
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main220
	MOVLW      20
	SUBWF      R1+0, 0
L__main220:
	BTFSS      STATUS+0, 0
	GOTO       L_main96
;embeddedproj_15.c,605 :: 		last_ldr_ms = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      main_last_ldr_ms_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      main_last_ldr_ms_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      main_last_ldr_ms_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      main_last_ldr_ms_L0+3
;embeddedproj_15.c,606 :: 		ldr = adc_read_an0();
	CALL       embeddedproj_15_adc_read_an0+0
;embeddedproj_15.c,609 :: 		if(ldr > LDR_THRESHOLD) {
	MOVF       R0+1, 0
	SUBLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__main221
	MOVF       R0+0, 0
	SUBLW      144
L__main221:
	BTFSC      STATUS+0, 0
	GOTO       L_main97
;embeddedproj_15.c,610 :: 		if(dark_cnt < 20) dark_cnt++;
	MOVLW      20
	SUBWF      main_dark_cnt_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main98
	INCF       main_dark_cnt_L0+0, 1
L_main98:
;embeddedproj_15.c,611 :: 		bright_cnt = 0;
	CLRF       main_bright_cnt_L0+0
;embeddedproj_15.c,612 :: 		} else {
	GOTO       L_main99
L_main97:
;embeddedproj_15.c,613 :: 		dark_cnt = 0;
	CLRF       main_dark_cnt_L0+0
;embeddedproj_15.c,614 :: 		bright_cnt = 0;
	CLRF       main_bright_cnt_L0+0
;embeddedproj_15.c,615 :: 		}
L_main99:
;embeddedproj_15.c,617 :: 		if(dark_cnt >= 5) {          // ~100ms dark -> entered tunnel
	MOVLW      5
	SUBWF      main_dark_cnt_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main100
;embeddedproj_15.c,618 :: 		mode = 1;
	MOVLW      1
	MOVWF      main_mode_L0+0
;embeddedproj_15.c,619 :: 		dark_cnt = 0;
	CLRF       main_dark_cnt_L0+0
;embeddedproj_15.c,620 :: 		bright_cnt = 0;
	CLRF       main_bright_cnt_L0+0
;embeddedproj_15.c,621 :: 		buzzer_on();
	CALL       embeddedproj_15_buzzer_on+0
;embeddedproj_15.c,622 :: 		}
L_main100:
;embeddedproj_15.c,623 :: 		}
L_main96:
;embeddedproj_15.c,625 :: 		}
	GOTO       L_main94
L_main95:
;embeddedproj_15.c,628 :: 		while(mode == 1)
L_main101:
	MOVF       main_mode_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main102
;embeddedproj_15.c,630 :: 		if(tunnel_boost_done == 0) {
	MOVF       main_tunnel_boost_done_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main103
;embeddedproj_15.c,631 :: 		line_follow_boost_ms(230, 230, trimL, trimR, 900);  // 0.9s boost in tunnel
	MOVLW      230
	MOVWF      FARG_line_follow_boost_ms_base_boost+0
	MOVLW      230
	MOVWF      FARG_line_follow_boost_ms_curve_boost+0
	MOVLW      4
	MOVWF      FARG_line_follow_boost_ms_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_boost_ms_trimR1+0
	MOVLW      132
	MOVWF      FARG_line_follow_boost_ms_duration_ms+0
	MOVLW      3
	MOVWF      FARG_line_follow_boost_ms_duration_ms+1
	CALL       _line_follow_boost_ms+0
;embeddedproj_15.c,632 :: 		tunnel_boost_done = 1;
	MOVLW      1
	MOVWF      main_tunnel_boost_done_L0+0
;embeddedproj_15.c,633 :: 		}
L_main103:
;embeddedproj_15.c,636 :: 		line_follow_step(base, curve_base, trimL, trimR);
	MOVLW      50
	MOVWF      FARG_line_follow_step_base1+0
	MOVLW      180
	MOVWF      FARG_line_follow_step_curve_base1+0
	MOVLW      4
	MOVWF      FARG_line_follow_step_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_step_trimR1+0
	CALL       _line_follow_step+0
;embeddedproj_15.c,639 :: 		if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       main_last_ldr_ms_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_last_ldr_ms_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_last_ldr_ms_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_last_ldr_ms_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_last_ldr_ms_L0+3, 0
	SUBWF      R1+3, 1
	MOVLW      0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main222
	MOVLW      0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main222
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main222
	MOVLW      20
	SUBWF      R1+0, 0
L__main222:
	BTFSS      STATUS+0, 0
	GOTO       L_main104
;embeddedproj_15.c,641 :: 		last_ldr_ms = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      main_last_ldr_ms_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      main_last_ldr_ms_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      main_last_ldr_ms_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      main_last_ldr_ms_L0+3
;embeddedproj_15.c,642 :: 		ldr = adc_read_an0();
	CALL       embeddedproj_15_adc_read_an0+0
;embeddedproj_15.c,645 :: 		if(ldr <= LDR_THRESHOLD) {
	MOVF       R0+1, 0
	SUBLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__main223
	MOVF       R0+0, 0
	SUBLW      144
L__main223:
	BTFSS      STATUS+0, 0
	GOTO       L_main105
;embeddedproj_15.c,646 :: 		if(bright_cnt < 20) bright_cnt++;
	MOVLW      20
	SUBWF      main_bright_cnt_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main106
	INCF       main_bright_cnt_L0+0, 1
L_main106:
;embeddedproj_15.c,647 :: 		dark_cnt = 0;
	CLRF       main_dark_cnt_L0+0
;embeddedproj_15.c,648 :: 		} else {
	GOTO       L_main107
L_main105:
;embeddedproj_15.c,649 :: 		bright_cnt = 0;
	CLRF       main_bright_cnt_L0+0
;embeddedproj_15.c,650 :: 		dark_cnt = 0;
	CLRF       main_dark_cnt_L0+0
;embeddedproj_15.c,651 :: 		}
L_main107:
;embeddedproj_15.c,653 :: 		if(bright_cnt >= 5) {        // ~100ms bright -> exited tunnel
	MOVLW      5
	SUBWF      main_bright_cnt_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main108
;embeddedproj_15.c,654 :: 		mode = 2;
	MOVLW      2
	MOVWF      main_mode_L0+0
;embeddedproj_15.c,655 :: 		bright_cnt = 0;
	CLRF       main_bright_cnt_L0+0
;embeddedproj_15.c,656 :: 		dark_cnt = 0;
	CLRF       main_dark_cnt_L0+0
;embeddedproj_15.c,657 :: 		buzzer_off();
	CALL       embeddedproj_15_buzzer_off+0
;embeddedproj_15.c,658 :: 		us_flag = 1;                // enable ultrasonic ONLY after tunnel
	MOVLW      1
	MOVWF      main_us_flag_L0+0
;embeddedproj_15.c,659 :: 		}
L_main108:
;embeddedproj_15.c,660 :: 		}
L_main104:
;embeddedproj_15.c,661 :: 		}
	GOTO       L_main101
L_main102:
;embeddedproj_15.c,664 :: 		while(mode == 2)
L_main109:
	MOVF       main_mode_L0+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main110
;embeddedproj_15.c,666 :: 		while(us_flag == 1 && turn_counter < 4)
L_main111:
	MOVF       main_us_flag_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main112
	MOVLW      4
	SUBWF      main_turn_counter_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main112
L__main162:
;embeddedproj_15.c,669 :: 		if(obstacle_seen == 0 && (turn_counter == 2 || turn_counter == 3)) break;
	MOVF       main_obstacle_seen_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main119
	MOVF       main_turn_counter_L0+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__main161
	MOVF       main_turn_counter_L0+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L__main161
	GOTO       L_main119
L__main161:
L__main160:
	GOTO       L_main112
L_main119:
;embeddedproj_15.c,672 :: 		step_start_ms = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      main_step_start_ms_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      main_step_start_ms_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      main_step_start_ms_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      main_step_start_ms_L0+3
;embeddedproj_15.c,673 :: 		hit_cnt = 0;
	CLRF       main_hit_cnt_L0+0
;embeddedproj_15.c,674 :: 		while(1)
L_main120:
;embeddedproj_15.c,676 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,677 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,678 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,681 :: 		dF = wait_front_le(stop_cm[turn_counter], 25);
	MOVF       main_turn_counter_L0+0, 0
	ADDLW      main_stop_cm_L0+0
	MOVWF      R0+0
	MOVLW      hi_addr(main_stop_cm_L0+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      FARG_embeddedproj_15_wait_front_le_cm+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_wait_front_le_cm+1
	MOVLW      25
	MOVWF      FARG_embeddedproj_15_wait_front_le_sample_ms+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_wait_front_le_sample_ms+1
	CALL       embeddedproj_15_wait_front_le+0
;embeddedproj_15.c,682 :: 		if(dF != 0) hit_cnt++;
	MOVLW      0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main224
	MOVLW      0
	XORWF      R0+0, 0
L__main224:
	BTFSC      STATUS+0, 2
	GOTO       L_main122
	INCF       main_hit_cnt_L0+0, 1
	GOTO       L_main123
L_main122:
;embeddedproj_15.c,683 :: 		else hit_cnt = 0;
	CLRF       main_hit_cnt_L0+0
L_main123:
;embeddedproj_15.c,685 :: 		if(hit_cnt < 2) continue;  // need 2 consecutive hits (~50ms)
	MOVLW      2
	SUBWF      main_hit_cnt_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main124
	GOTO       L_main120
L_main124:
;embeddedproj_15.c,686 :: 		hit_cnt = 0;
	CLRF       main_hit_cnt_L0+0
;embeddedproj_15.c,689 :: 		if(turn_counter == 1)
	MOVF       main_turn_counter_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main125
;embeddedproj_15.c,691 :: 		unsigned long dt = (unsigned long)(sys_ms - step_start_ms);
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       main_step_start_ms_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_step_start_ms_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_step_start_ms_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_step_start_ms_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_step_start_ms_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_step_start_ms_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_step_start_ms_L0+3, 0
	SUBWF      R1+3, 1
;embeddedproj_15.c,694 :: 		if(dt <= 4000u) obstacle_seen = 1;   // obstacle case
	MOVF       R1+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main225
	MOVF       R1+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main225
	MOVF       R1+1, 0
	SUBLW      15
	BTFSS      STATUS+0, 2
	GOTO       L__main225
	MOVF       R1+0, 0
	SUBLW      160
L__main225:
	BTFSS      STATUS+0, 0
	GOTO       L_main126
	MOVLW      1
	MOVWF      main_obstacle_seen_L0+0
	GOTO       L_main127
L_main126:
;embeddedproj_15.c,695 :: 		else obstacle_seen = 0;   // wall case
	CLRF       main_obstacle_seen_L0+0
L_main127:
;embeddedproj_15.c,696 :: 		}
L_main125:
;embeddedproj_15.c,699 :: 		turn_and_clear(turn_dir[turn_counter], base, trimL, trimR);
	MOVF       main_turn_counter_L0+0, 0
	ADDLW      main_turn_dir_L0+0
	MOVWF      R0+0
	MOVLW      hi_addr(main_turn_dir_L0+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      FARG_embeddedproj_15_turn_and_clear_dir+0
	MOVLW      50
	MOVWF      FARG_embeddedproj_15_turn_and_clear_base_pwm+0
	MOVLW      4
	MOVWF      FARG_embeddedproj_15_turn_and_clear_trimL1+0
	MOVLW      3
	MOVWF      FARG_embeddedproj_15_turn_and_clear_trimR1+0
	CALL       embeddedproj_15_turn_and_clear+0
;embeddedproj_15.c,700 :: 		turn_counter++;
	INCF       main_turn_counter_L0+0, 1
;embeddedproj_15.c,703 :: 		}
L_main121:
;embeddedproj_15.c,705 :: 		if(mode == 3) break;
	MOVF       main_mode_L0+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main128
	GOTO       L_main112
L_main128:
;embeddedproj_15.c,706 :: 		}
	GOTO       L_main111
L_main112:
;embeddedproj_15.c,708 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,709 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,710 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,711 :: 		wait_ms(50);
	MOVLW      50
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+0
	MOVLW      0
	MOVWF      FARG_embeddedproj_15_wait_ms_ms+1
	CALL       embeddedproj_15_wait_ms+0
;embeddedproj_15.c,713 :: 		mode = 3;
	MOVLW      3
	MOVWF      main_mode_L0+0
;embeddedproj_15.c,714 :: 		}
	GOTO       L_main109
L_main110:
;embeddedproj_15.c,715 :: 		while(mode == 3) // hallway and parking
	MOVF       main_mode_L0+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main130
;embeddedproj_15.c,718 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,719 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,720 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,721 :: 		t = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      main_t_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      main_t_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      main_t_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      main_t_L0+3
;embeddedproj_15.c,722 :: 		while(!parked && ((unsigned long)(sys_ms - t) <= 5000)){
L_main131:
	MOVF       main_parked_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main132
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       main_t_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_t_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_t_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_t_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+3, 0
	SUBWF      R1+3, 1
	MOVF       R1+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main226
	MOVF       R1+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main226
	MOVF       R1+1, 0
	SUBLW      19
	BTFSS      STATUS+0, 2
	GOTO       L__main226
	MOVF       R1+0, 0
	SUBLW      136
L__main226:
	BTFSS      STATUS+0, 0
	GOTO       L_main132
L__main159:
;embeddedproj_15.c,723 :: 		ir_sensors(base, curve_base, slow, trimL, trimR);
	MOVLW      50
	MOVWF      FARG_ir_sensors_base1+0
	MOVLW      180
	MOVWF      FARG_ir_sensors_curve_base1+0
	MOVLW      40
	MOVWF      FARG_ir_sensors_slow1+0
	MOVLW      4
	MOVWF      FARG_ir_sensors_trimL1+0
	MOVLW      3
	MOVWF      FARG_ir_sensors_trimR1+0
	CALL       _ir_sensors+0
;embeddedproj_15.c,724 :: 		line_follow_step_final(base, curve_base, trimL, trimR, slow);
	MOVLW      50
	MOVWF      FARG_line_follow_step_final_base1+0
	MOVLW      180
	MOVWF      FARG_line_follow_step_final_curve_base1+0
	MOVLW      4
	MOVWF      FARG_line_follow_step_final_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_step_final_trimR1+0
	MOVLW      40
	MOVWF      FARG_line_follow_step_final_slow1+0
	CALL       _line_follow_step_final+0
;embeddedproj_15.c,725 :: 		motor_forward();
	CALL       _motor_forward+0
;embeddedproj_15.c,726 :: 		pwm_left(base + trimL);
	MOVLW      54
	MOVWF      FARG_pwm_left_val+0
	CALL       _pwm_left+0
;embeddedproj_15.c,727 :: 		pwm_right(base + trimR);
	MOVLW      53
	MOVWF      FARG_pwm_right_val+0
	CALL       _pwm_right+0
;embeddedproj_15.c,728 :: 		}
	GOTO       L_main131
L_main132:
;embeddedproj_15.c,730 :: 		while(!parked)
L_main135:
	MOVF       main_parked_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main136
;embeddedproj_15.c,733 :: 		line_follow_step_final(base, curve_base, trimL, trimR, slow);
	MOVLW      50
	MOVWF      FARG_line_follow_step_final_base1+0
	MOVLW      180
	MOVWF      FARG_line_follow_step_final_curve_base1+0
	MOVLW      4
	MOVWF      FARG_line_follow_step_final_trimL1+0
	MOVLW      3
	MOVWF      FARG_line_follow_step_final_trimR1+0
	MOVLW      40
	MOVWF      FARG_line_follow_step_final_slow1+0
	CALL       _line_follow_step_final+0
;embeddedproj_15.c,736 :: 		if(!parking_seen && parking_marker_seen())
	MOVF       main_parking_seen_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main139
	CALL       embeddedproj_15_parking_marker_seen+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main139
L__main158:
;embeddedproj_15.c,738 :: 		parking_seen = 1;
	MOVLW      1
	MOVWF      main_parking_seen_L0+0
;embeddedproj_15.c,739 :: 		}
L_main139:
;embeddedproj_15.c,741 :: 		if(parking_seen)
	MOVF       main_parking_seen_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main140
;embeddedproj_15.c,744 :: 		t = sys_ms;
	MOVF       _sys_ms+0, 0
	MOVWF      main_t_L0+0
	MOVF       _sys_ms+1, 0
	MOVWF      main_t_L0+1
	MOVF       _sys_ms+2, 0
	MOVWF      main_t_L0+2
	MOVF       _sys_ms+3, 0
	MOVWF      main_t_L0+3
;embeddedproj_15.c,745 :: 		while((sys_ms - t) < 6000){
L_main141:
	MOVF       _sys_ms+0, 0
	MOVWF      R1+0
	MOVF       _sys_ms+1, 0
	MOVWF      R1+1
	MOVF       _sys_ms+2, 0
	MOVWF      R1+2
	MOVF       _sys_ms+3, 0
	MOVWF      R1+3
	MOVF       main_t_L0+0, 0
	SUBWF      R1+0, 1
	MOVF       main_t_L0+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+1, 0
	SUBWF      R1+1, 1
	MOVF       main_t_L0+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+2, 0
	SUBWF      R1+2, 1
	MOVF       main_t_L0+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     main_t_L0+3, 0
	SUBWF      R1+3, 1
	MOVLW      0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main227
	MOVLW      0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main227
	MOVLW      23
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main227
	MOVLW      112
	SUBWF      R1+0, 0
L__main227:
	BTFSC      STATUS+0, 0
	GOTO       L_main142
;embeddedproj_15.c,746 :: 		beeping(parking_seen);
	MOVF       main_parking_seen_L0+0, 0
	MOVWF      FARG_beeping_parked+0
	CALL       _beeping+0
;embeddedproj_15.c,747 :: 		}
	GOTO       L_main141
L_main142:
;embeddedproj_15.c,748 :: 		park_right();
	CALL       embeddedproj_15_park_right+0
;embeddedproj_15.c,749 :: 		raise_flag();
	CALL       _raise_flag+0
;embeddedproj_15.c,751 :: 		buzzer_off();
	CALL       embeddedproj_15_buzzer_off+0
;embeddedproj_15.c,752 :: 		motor_stop();
	CALL       _motor_stop+0
;embeddedproj_15.c,753 :: 		parked = 1;
	MOVLW      1
	MOVWF      main_parked_L0+0
;embeddedproj_15.c,754 :: 		}
L_main140:
;embeddedproj_15.c,755 :: 		}
	GOTO       L_main135
L_main136:
;embeddedproj_15.c,757 :: 		while(1) { }  // finished
L_main143:
	GOTO       L_main143
;embeddedproj_15.c,758 :: 		}
L_main130:
;embeddedproj_15.c,759 :: 		}
	GOTO       L_main92
;embeddedproj_15.c,760 :: 		}
L_main91:
;embeddedproj_15.c,761 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
