#define base 50
#define curve_base 180
#define trimL 4
#define trimR 3
#define add 20
#define slow 40
#define LDR_THRESHOLD 400u
#define TURN_PWM 180

// Motor direction bits on PORTC
#define L_IN1 0x10   // RC4
#define L_IN2 0x20   // RC5
#define R_IN3 0x40   // RC6
#define R_IN4 0x80   // RC7

#define START_BUTTON 0x40 // RB6

#define US_TRIG_F 0x04   // RD2
#define US_ECHO_F 0x08   // RD3

#define US_WAIT_RISE_TIMEOUT_US 30000u   // 30 ms
#define US_WAIT_FALL_TIMEOUT_US 35000u   // 35 ms
#define US_TRIGGER_PULSE_US 15u      // >=10 us

#define ADC_GO_MASK 0x04   // ADCON0 bit2 = GO/DONE
#define BUZZER_MASK 0x04   // RB2
#define SERVO_MASK 0x10   // example RD4

volatile unsigned long sys_ms = 0;
volatile unsigned int buzz_tick = 0;

// Timer0: 1ms system tick

void timer0_init_1ms(void)
{
	// Timer0 internal, prescaler assigned to Timer0, 1:8
	// OPTION_REG: PSA=0, PS=010 (1:8), T0CS=0 (internal)
	OPTION_REG = 0x02;

	// preload for 1ms overflow at 8MHz with 1:8 prescaler
	// Fosc/4 = 2MHz => 0.5us per tick
	// prescale 1:8 => 4us per increment
	// 1ms / 4us = 250 counts => preload = 256 - 250 = 6
	TMR0 = 0x06;

	INTCON &= (unsigned char)~0x04; // clear T0IF
	INTCON |= 0xA0; // GIE + T0IE
}

void interrupt(void)
{
	if(INTCON & 0x04) { // T0IF
		TMR0 = 0x06; // reload
		INTCON &= (unsigned char)~0x04; // clear flag
		sys_ms++;
		buzz_tick++;
		if(buzz_tick >= 2000) buzz_tick = 0;
	}
}

static void wait_ms(unsigned int ms)
{
	unsigned long t0 = sys_ms;
	while((unsigned long)(sys_ms - t0) < (unsigned long)ms) { }
}

// PWM: CCP1 (RC2) and CCP2 (RC1)
//  8 MHz, Timer2 prescaler 16, PR2=250
// 8/4 = 2Mhz, 1/2Mhz = 0.5us, 0.5 * 16 = 8us,
// 8us * 251 = almost 2ms
// 1/640 = 0.4980khz

void pwm_init(void)
{
	TRISC = 0x09; // RC0,RC3 inputs; RC1,RC2,RC4..RC7 outputs
	// Timer2 ON, prescaler 1:16
	T2CON = 0x07;
	// PWM period (tune for motors)
	PR2 = 250;
	// CCP1/CCP2 in PWM mode
	CCP1CON = 0x0C;
	CCP2CON = 0x0C;
	// duty starts at 0
	CCPR1L = 0;
	CCPR2L = 0;
	// Ensure DCxB bits are 0 (we use 8-bit duty only)
	CCP1CON &= 0xCF;
	CCP2CON &= 0xCF;
}

void pwm_left(unsigned char val) {
	if(val>255)val = 255;
	CCPR1L = (unsigned char)val;
	// Clear DC1B1:DC1B0 (bits 5:4)
	CCP1CON = CCP1CON & 0xCF;   // 1100 1111
}

void pwm_right(unsigned char val) {
	if(val>255)val = 255;
	CCPR2L = (unsigned char)val;
	// Clear DC1B1:DC1B0 (bits 5:4)
	CCP2CON = CCP2CON & 0xCF;   // 1100 1111
}

/* Motor direction
   Right motor:  IN1=RC4, IN2=RC5
   Left motor: IN3=RC6, IN4=RC7
*/

void pivot_right(void)
{
	PORTC &= (unsigned char)(~(L_IN1 | L_IN2));     // left wheel stopped (RC4,RC5 = 0)
	PORTC = (PORTC | R_IN3) & (unsigned char)(~R_IN4);  // right wheel forward (RC6=1, RC7=0)
}

void pivot_left(void)
{
	PORTC &= (unsigned char)(~(R_IN3 | R_IN4));     // right wheel stopped (RC6,RC7 = 0)
	PORTC = (PORTC | L_IN1) & (unsigned char)(~L_IN2);   // left wheel forward
}

void motor_stop(void)
{
	// Force upper nibble (RC4..RC7) to 0, keep remaining bits unchanged
	PORTC &= (unsigned char)(~(L_IN1 | L_IN2 | R_IN3 | R_IN4));
}

void motor_forward(void)
{
	PORTC = (PORTC | L_IN1) & (unsigned char)(~L_IN2);
	PORTC = (PORTC | R_IN3) & (unsigned char)(~R_IN4);
}

void left_90(void){
	unsigned long t;
	pivot_left();
	pwm_right(0);
	pwm_right(TURN_PWM);
	wait_ms(400); // prev 440
	motor_forward();
	pwm_right(base + trimR);
	pwm_left(base + trimL);
}

void right_90(void){
	unsigned long t;
	pivot_right();
	pwm_left(0);
	pwm_left(TURN_PWM);
	wait_ms(400);
	motor_forward();
	pwm_right(base + trimR);
	pwm_left(base + trimL);
}

/*Line sensors (RB1 left, RB0 right)
   black = 1, white = 0
*/

unsigned char line_left(void) {
	return (PORTB & 0x02) ? 1 : 0; // just returns RB1 ( left sensor )
}
unsigned char line_right(void){
	return (PORTB & 0x01) ? 1 : 0; // just returns RB0 ( right sensor )
}

/*IR sensors for ultrasonic arena to not hit walls(RD1 right, RD0 left)
   black = 1, white = 0
*/

unsigned char sensor_left(void) {
	return (PORTB & 0x20) ? 1 : 0; // just returns RB5 ( left sensor )
}
unsigned char sensor_right(void){
	return (PORTB & 0x10) ? 1 : 0; // just returns RB4 ( right sensor )
}

//  Timer1: 1us/tick (for Ultrasonic + ADC acquisition)

static void timer1_init_us(void)
{
	// T1CON = 0001 0001
	// TMR1ON=1 (on)
	// TMR1CS=0 (internal clock = Fosc/4)
	// T1CKPS=01 (prescaler 1:2)
	// 8MHz/4 = 2MHz => 0.5us per tick, with 1:2 prescaler => 1us per tick
	T1CON = 0x11;
	TMR1H = 0;
	TMR1L = 0;

	// Ensure Timer1 interrupt is OFF
	PIE1 &= (unsigned char)~0x01; // TMR1IE = 0
	PIR1 &= (unsigned char)~0x01; // clear TMR1IF
}

static unsigned int t1_now_us(void)
{
	// Timer1 is 1us/tick, so the raw count is "microseconds (mod 65536)"
	unsigned char h = TMR1H;
	unsigned char l = TMR1L;
	return ((unsigned int)h << 8) | (unsigned int)l;
}

static void t1_wait_us(unsigned int us)
{
	unsigned int t0 = t1_now_us();
	while((unsigned int)(t1_now_us() - t0) < us) { }
} // uses the current value of t1 and counts in micro seconds till we reach the exact parameter we gave it.

static void adc_init_an0(void)
{
	// RA0/AN0 must be input for ADC
	TRISA |= 0x01;
	// AN0 analog, others digital, Vref = Vdd/Vss, right-justified
	// ADFM=1 (bit7), ADCS2=0 (bit6), PCFG=1110 (AN0 enabled)
	ADCON1 = 0x8E;
	// ADCON0: ADCS1:0=10 (Fosc/32), CHS=000 (AN0), ADON=1
	ADCON0 = 0x81;
	// Give ADC a moment to settle (acquisition)
	t1_wait_us(50);
}

static unsigned int adc_read_an0(void)
{
	// Select channel 0 (AN0) and keep ADON=1
	ADCON0 &= 0xC7;           // clear CHS bits (5:3)

	// Acquisition time
	t1_wait_us(30);

	// Start conversion (set GO/DONE)
	ADCON0 |= ADC_GO_MASK;

	// Wait for conversion complete (hardware clears GO/DONE)
	while(ADCON0 & ADC_GO_MASK) { }

	return ((unsigned int)ADRESH << 8) | (unsigned int)ADRESL;
}

// Buzzer (RB2)
static void buzzer_init(void)
{
	TRISB &= (unsigned char)~BUZZER_MASK; // RB2 output
	PORTB &= (unsigned char)~BUZZER_MASK; // start OFF
}

static void buzzer_on(void)
{
	PORTB |= BUZZER_MASK;
}

static void buzzer_off(void)
{
	PORTB &= (unsigned char)~BUZZER_MASK;
}

static void ultrasonic_init(void)
{
	// RD0,RD2 outputs (TRIG); RD1,RD3 inputs (ECHO)
	TRISD = (TRISD | (US_ECHO_F)) & (unsigned char)~(US_TRIG_F);
	// Sets TRIG pin to output, and ECHO pin to input. Everything else remained unchanged
	PORTD = PORTD & (unsigned char)~(US_TRIG_F);
	// Making sure that RD2 is set to 0 initially.
}

static void ultrasonic_trigger(unsigned char trig_mask)
{
	PORTD = PORTD & (unsigned char)~trig_mask;	// force trigger low to make sure no weird leftover state
	t1_wait_us(2); // make sure you start from clean low level

	PORTD = PORTD | trig_mask;	// force trigger high
	t1_wait_us(US_TRIGGER_PULSE_US); // keeps trigger high for 15us

	PORTD = PORTD & (unsigned char)~trig_mask; // force trigger low again.
}

static unsigned int echo_width_us(unsigned char echo_mask)
{
	unsigned int t0; // used as time marker

	// Wait for echo to go HIGH (rise) with timeout
	t0 = t1_now_us();
	while((PORTD & echo_mask) == 0) {
		if((unsigned int)(t1_now_us() - t0) > US_WAIT_RISE_TIMEOUT_US) {
			return 0;
		}
	}

	// Measure HIGH time
	t0 = t1_now_us(); // reset t0 to current t1 time
	while((PORTD & echo_mask) != 0) {
		if((unsigned int)(t1_now_us() - t0) > US_WAIT_FALL_TIMEOUT_US) {
			return 0;
		}
	}

	return (unsigned int)(t1_now_us() - t0);
}

static unsigned int ultrasonic_read_cm(unsigned char trig_mask, unsigned char echo_mask)
{
	unsigned int us;

	ultrasonic_trigger(trig_mask);
	us = echo_width_us(echo_mask);

	if(us == 0) return 0;

	// distance_cm ˜ us / 58
	return (unsigned int)(us / 58);
}

void ir_sensors(unsigned char base1, unsigned char curve_base1, unsigned char slow1, unsigned char trimL1, unsigned char trimR1)
{
	// these sensors are active low basically, because the wall is white. so when u see the wall, it reads 0.
	unsigned char L = sensor_left();
	unsigned char R = sensor_right();
	if(L == 1 && R == 1){
		motor_forward();
		pwm_left(base1 + trimL1 + 20);
		pwm_right(base1 + trimR1 + 20);
	}
	else if(L == 0 && R == 0){ // both see wall - almost impossible so do motor_stop()
		motor_forward();
		pwm_left(base1 + trimL1 + 20);
		pwm_right(base1 + trimR1 + 20);
	}
	else if(L == 1 && R == 0){ // right sees wall, speed right up / slow left down.
		pivot_left();
		pwm_right(curve_base1);
		pwm_left(slow1);
	}
	else { // L == 0 && R == 1
		pivot_right();
		pwm_left(curve_base1);
		pwm_right(slow1);
	}
}

void line_follow_step_final(unsigned char base1, unsigned char curve_base1, unsigned char trimL1, unsigned char trimR1, unsigned char slow1)
{
	unsigned char L = line_left();
	unsigned char R = line_right();

	if(L == 1 && R == 1){
		motor_forward();
		pwm_left(slow1);
		pwm_right(slow1);
	}
	else if(L == 0 && R == 0){
		motor_forward();
		pwm_left(base1 + trimL1);
		pwm_right(base1 + trimR1);
	}
	else if(L == 1 && R == 0){
		pivot_left();
		pwm_right(base1 + trimR1 + 40);
		pwm_left(base1);
	}
	else { // L == 0 && R == 1
		pivot_right();
		pwm_left(base1 + trimL1 + 40);
		pwm_right(base1);
	}
}

void line_follow_step(unsigned char base1, unsigned char curve_base1, unsigned char trimL1, unsigned char trimR1)
{
	unsigned char L = line_left();
	unsigned char R = line_right();

	if(L == 1 && R == 1){
		left_90();
	}
	else if(L == 0 && R == 0){
		motor_forward();
		pwm_left(base1 + trimL1);
		pwm_right(base1 + trimR1);
	}
	else if(L == 1 && R == 0){
		pivot_left();
		pwm_right(curve_base1 + trimR1);
		pwm_left(0);
	}
	else { // L == 0 && R == 1
		pivot_right();
		pwm_left(curve_base1 + trimL1);
		pwm_right(0);
	}
}

void line_follow_boost_ms(unsigned char base_boost, unsigned char curve_boost, unsigned char trimL1, unsigned char trimR1, unsigned int duration_ms)
{
	unsigned long start = sys_ms;

	while((unsigned long)(sys_ms - start) < (unsigned long)duration_ms)
	{
		line_follow_step(base_boost, curve_boost, trimL1, trimR1);
	}
}

void servo_write_us(unsigned int us)
{
	PORTD |= SERVO_MASK;
	t1_wait_us(us);                 // 1000–2000 us
	PORTD &= (unsigned char)~SERVO_MASK;

	t1_wait_us(20000 - us);         // rest of 20ms frame
}

void raise_flag(void)
{
	unsigned int k;
	for(k=0; k<50; k++)           // ~1 second
		servo_write_us(2000);     // try 1800–2200 as needed
}

// PARKING DETECT
// "parking area" marker assumption: BOTH line sensors read black for a bit.
static unsigned char parking_marker_seen(void)
{
	static unsigned char seen = 0;
	static unsigned long last_ms = 0;

	// sample every 10ms
	if((unsigned long)(sys_ms - last_ms) < 10) return 0;
	last_ms = sys_ms;

	if(line_left() && line_right()) {
		if(seen < 20) seen++;
	} else {
		seen = 0;
	}

	return (seen >= 5);   // needs ~50ms stable now
}

void beeping (unsigned char parked){
	if(parked && (buzz_tick < 1000)){
		buzzer_on();
	}else {
		buzzer_off();
	}
}

// PARK RIGHT
// Timed “park on right” maneuver (you will tune ms values)
static void park_right(void)
{
	// stop first
	motor_stop();
	wait_ms(150);

	// creep forward a bit so you’re past the marker
	motor_forward();
	pwm_left(slow);
	pwm_right(slow);
	wait_ms(800);


	// turn into the right parking spot
	right_90();

	// drive into spot
	motor_forward();
	pwm_left(slow);
	pwm_right(slow);
	wait_ms(200);

	// final stop
	motor_stop();
	wait_ms(200);
}

static unsigned int wait_front_le(unsigned int cm, unsigned int sample_ms)
{
	unsigned int dF;

	wait_ms(sample_ms);
	dF = ultrasonic_read_cm(US_TRIG_F, US_ECHO_F);

	if(dF != 0 && dF <= cm) return dF;  // obstacle found
	else return 0;
}

static void wait_front_ge_stable(unsigned int cm, unsigned char stable_needed, unsigned int sample_ms)
{
	unsigned char stable = 0;
	unsigned int dF;

	while(stable < stable_needed)
	{
		wait_ms(sample_ms);

		dF = ultrasonic_read_cm(US_TRIG_F, US_ECHO_F);
		if(dF != 0 && dF >= cm) stable++;
		else stable = 0;
	}
}


typedef enum { TURN_RIGHT = 0, TURN_LEFT = 1 } TurnDir;
static void turn_and_clear(TurnDir dir, unsigned char base_pwm, unsigned char trimL1, unsigned char trimR1)
{
	// pivot for ~300ms (your tuned value)
	if(dir == TURN_RIGHT) {
		right_90();
	} else {
		left_90();
	}

	// go forward
	motor_forward();
	pwm_left(base_pwm + trimL1);
	pwm_right(base_pwm + trimR1);

	// wait until we’re “far” again (your far logic)
	wait_front_ge_stable(30, 3, 25);
}

// Main
void main(void)
{

	// LDR variables
	unsigned int ldr = 0;
	unsigned long last_ldr_ms = 0;
	unsigned char dark_cnt = 0;
	unsigned char bright_cnt = 0;
	unsigned char mode = 0;
	// 0 = before tunnel (bright), 1 = inside tunnel (dark), 2 = after tunnel (bright again -> ultrasonic allowed), 3 = trying to find line and line following

	// Ultrasonic sensor signals
	unsigned char us_flag = 0;
	unsigned char turn_counter = 0; // 0:R, 1:R, 2:L, 3:R
	unsigned char obstacle_seen = 0; // only relevant for optional steps
	unsigned int dF = 0;

	// Temps for delays
	unsigned long t = 0;
	unsigned char far;

	// us_flag to make sure not to speed again after tunnel.
	unsigned char tunnel_boost_done = 0;

	// arrays for US direction and distances for functions
	static const unsigned char stop_cm[4] = { 25, 30, 25, 25 };
	static const TurnDir turn_dir[4] = { TURN_RIGHT, TURN_RIGHT, TURN_LEFT, TURN_RIGHT };
	unsigned long step_start_ms = 0;
	unsigned char hit_cnt = 0;

	// parking variables
	unsigned char parked = 0;
	unsigned char parking_seen = 0;


	// I/O setup
	TRISB |= 0x03;                 // RB0,RB1 inputs (line sensors)
	TRISD |= 0x03;                 // RB0,RB1 inputs (ir sensors for ultrasonic)

	TRISD &= (unsigned char)~SERVO_MASK;   // RD4 output
	PORTD &= (unsigned char)~SERVO_MASK;   // start low

	TRISB |= (unsigned char) 0x70;  // RB4,RB5,RB6 input

	TRISB &= (unsigned char)~0x80; // RB7 output (LED)
	PORTB &= (unsigned char)~0x80; // LED off

	buzzer_init();                 // RB2 output, OFF

	TRISC = 0x09;                  // RC0,RC3 input; RC1,RC2,RC4..RC7 outputs
	PORTC = 0x00;

	timer0_init_1ms();
	pwm_init();

	timer1_init_us();              // needed for ADC acquisition + ultrasonic timing
	ultrasonic_init();
	adc_init_an0();

	// startup delay
	while(sys_ms < 3000) { }
	PORTB |= 0x80;                 // LED on

	// start moving
	motor_forward();
	pwm_left(base + trimL);
	pwm_right(base + trimR);

	// Start-up boost BUT still line-following (so it stays on track)
	line_follow_boost_ms(180, 180, trimL, trimR, 400);   // 0.4 sec boost (tune)
	line_follow_boost_ms(30, 30, trimL, trimR, 100);   // 0.4 sec boost (tune)

	while((PORTB & START_BUTTON) != 0){
		while(1)
		{
			while(mode == 0)
			{
				// Keep line following ALWAYS
				line_follow_step(base, curve_base, trimL, trimR);

				// Sample LDR every ~20ms (don’t spam ADC)
				if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
				{
					last_ldr_ms = sys_ms;
					ldr = adc_read_an0();

					// DARK in your real life = ldr > threshold
					if(ldr > LDR_THRESHOLD) {
						if(dark_cnt < 20) dark_cnt++;
						bright_cnt = 0;
					} else {
						dark_cnt = 0;
						bright_cnt = 0;
					}

					if(dark_cnt >= 5) {          // ~100ms dark -> entered tunnel
						mode = 1;
						dark_cnt = 0;
						bright_cnt = 0;
						buzzer_on();
					}
				}

			}

			// MODE 1: INSIDE TUNNEL
			while(mode == 1)
			{
				if(tunnel_boost_done == 0) {
					line_follow_boost_ms(230, 230, trimL, trimR, 900);  // 0.9s boost in tunnel
					tunnel_boost_done = 1;
				}

				// STILL line follow inside tunnel
				line_follow_step(base, curve_base, trimL, trimR);

				// Sample LDR every ~20ms
				if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
				{
					last_ldr_ms = sys_ms;
					ldr = adc_read_an0();

					// BRIGHT = ldr <= threshold
					if(ldr <= LDR_THRESHOLD) {
						if(bright_cnt < 20) bright_cnt++;
						dark_cnt = 0;
					} else {
						bright_cnt = 0;
						dark_cnt = 0;
					}

					if(bright_cnt >= 5) {        // ~100ms bright -> exited tunnel
						mode = 2;
						bright_cnt = 0;
						dark_cnt = 0;
						buzzer_off();
						us_flag = 1;                // enable ultrasonic ONLY after tunnel
					}
				}
			}

			//  MODE 2: AFTER TUNNEL (ULTRASONIC)
			while(mode == 2)
			{
				while(us_flag == 1 && turn_counter < 4)
				{
					// skip optional turns if no obstacle
					if(obstacle_seen == 0 && (turn_counter == 2 || turn_counter == 3)) break;

					// mark start time ONCE per step
					step_start_ms = sys_ms;
					hit_cnt = 0;
					while(1)
					{
						motor_forward();
						pwm_left(base + trimL);
						pwm_right(base + trimR);

						// sample front every 25ms and check threshold
						dF = wait_front_le(stop_cm[turn_counter], 25);
						if(dF != 0) hit_cnt++;
						else hit_cnt = 0;

						if(hit_cnt < 2) continue;  // need 2 consecutive hits (~50ms)
						hit_cnt = 0;

						// We got a hit (dF <= stop_cm[turn_counter])
						if(turn_counter == 1)
						{
							unsigned long dt = (unsigned long)(sys_ms - step_start_ms);

							// 4 seconds rule
							if(dt <= 4000u) obstacle_seen = 1;   // obstacle case
							else obstacle_seen = 0;   // wall case
						}

						// perform the turn for this step
						turn_and_clear(turn_dir[turn_counter], base, trimL, trimR);
						turn_counter++;

						break; // done with this step, move to next
					}

					if(mode == 3) break;
				}

				motor_forward();
				pwm_left(base + trimL);
				pwm_right(base + trimR);
				wait_ms(50);

				mode = 3;
			}
			while(mode == 3) // hallway and parking
			{
				// optional: settle onto line
				motor_forward();
				pwm_left(base + trimL);
				pwm_right(base + trimR);
				t = sys_ms;
				while(!parked && ((unsigned long)(sys_ms - t) <= 5000)){
					ir_sensors(base, curve_base, slow, trimL, trimR);
					line_follow_step_final(base, curve_base, trimL, trimR, slow);
					motor_forward();
					pwm_left(base + trimL);
					pwm_right(base + trimR);
				}
				// 2) Now disable IR correction and do end-line-following
				while(!parked)
				{
					// pure line following (no wall IR)
					line_follow_step_final(base, curve_base, trimL, trimR, slow);

					// 3) detect parking marker and beep immediately
					if(!parking_seen && parking_marker_seen())
					{
						parking_seen = 1;
					}
					// 4) park once parking seen
					if(parking_seen)
					{
						// stop line following and perform the park sequence
						t = sys_ms;
						while((sys_ms - t) < 6000){
							beeping(parking_seen);
						}
						park_right();
						raise_flag();

						buzzer_off();
						motor_stop();
						parked = 1;
					}
				}

				while(1) { }  // finished
			}
		}
	}
}