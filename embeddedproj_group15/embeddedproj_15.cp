#line 1 "C:/Users/THINKPAD/Desktop/embeddedproj_group15/embeddedproj_15.c"
#line 29 "C:/Users/THINKPAD/Desktop/embeddedproj_group15/embeddedproj_15.c"
volatile unsigned long sys_ms = 0;
volatile unsigned int buzz_tick = 0;



void timer0_init_1ms(void)
{


 OPTION_REG = 0x02;





 TMR0 = 0x06;

 INTCON &= (unsigned char)~0x04;
 INTCON |= 0xA0;
}

void interrupt(void)
{
 if(INTCON & 0x04) {
 TMR0 = 0x06;
 INTCON &= (unsigned char)~0x04;
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







void pwm_init(void)
{
 TRISC = 0x09;

 T2CON = 0x07;

 PR2 = 250;

 CCP1CON = 0x0C;
 CCP2CON = 0x0C;

 CCPR1L = 0;
 CCPR2L = 0;

 CCP1CON &= 0xCF;
 CCP2CON &= 0xCF;
}

void pwm_left(unsigned char val) {
 if(val>255)val = 255;
 CCPR1L = (unsigned char)val;

 CCP1CON = CCP1CON & 0xCF;
}

void pwm_right(unsigned char val) {
 if(val>255)val = 255;
 CCPR2L = (unsigned char)val;

 CCP2CON = CCP2CON & 0xCF;
}
#line 110 "C:/Users/THINKPAD/Desktop/embeddedproj_group15/embeddedproj_15.c"
void pivot_right(void)
{
 PORTC &= (unsigned char)(~( 0x10  |  0x20 ));
 PORTC = (PORTC |  0x40 ) & (unsigned char)(~ 0x80 );
}

void pivot_left(void)
{
 PORTC &= (unsigned char)(~( 0x40  |  0x80 ));
 PORTC = (PORTC |  0x10 ) & (unsigned char)(~ 0x20 );
}

void motor_stop(void)
{

 PORTC &= (unsigned char)(~( 0x10  |  0x20  |  0x40  |  0x80 ));
}

void motor_forward(void)
{
 PORTC = (PORTC |  0x10 ) & (unsigned char)(~ 0x20 );
 PORTC = (PORTC |  0x40 ) & (unsigned char)(~ 0x80 );
}

void left_90(void){
 unsigned long t;
 pivot_left();
 pwm_right(0);
 pwm_right( 180 );
 wait_ms(400);
 motor_forward();
 pwm_right( 50  +  3 );
 pwm_left( 50  +  4 );
}

void right_90(void){
 unsigned long t;
 pivot_right();
 pwm_left(0);
 pwm_left( 180 );
 wait_ms(400);
 motor_forward();
 pwm_right( 50  +  3 );
 pwm_left( 50  +  4 );
}
#line 160 "C:/Users/THINKPAD/Desktop/embeddedproj_group15/embeddedproj_15.c"
unsigned char line_left(void) {
 return (PORTB & 0x02) ? 1 : 0;
}
unsigned char line_right(void){
 return (PORTB & 0x01) ? 1 : 0;
}
#line 171 "C:/Users/THINKPAD/Desktop/embeddedproj_group15/embeddedproj_15.c"
unsigned char sensor_left(void) {
 return (PORTB & 0x20) ? 1 : 0;
}
unsigned char sensor_right(void){
 return (PORTB & 0x10) ? 1 : 0;
}



static void timer1_init_us(void)
{





 T1CON = 0x11;
 TMR1H = 0;
 TMR1L = 0;


 PIE1 &= (unsigned char)~0x01;
 PIR1 &= (unsigned char)~0x01;
}

static unsigned int t1_now_us(void)
{

 unsigned char h = TMR1H;
 unsigned char l = TMR1L;
 return ((unsigned int)h << 8) | (unsigned int)l;
}

static void t1_wait_us(unsigned int us)
{
 unsigned int t0 = t1_now_us();
 while((unsigned int)(t1_now_us() - t0) < us) { }
}

static void adc_init_an0(void)
{

 TRISA |= 0x01;


 ADCON1 = 0x8E;

 ADCON0 = 0x81;

 t1_wait_us(50);
}

static unsigned int adc_read_an0(void)
{

 ADCON0 &= 0xC7;


 t1_wait_us(30);


 ADCON0 |=  0x04 ;


 while(ADCON0 &  0x04 ) { }

 return ((unsigned int)ADRESH << 8) | (unsigned int)ADRESL;
}


static void buzzer_init(void)
{
 TRISB &= (unsigned char)~ 0x04 ;
 PORTB &= (unsigned char)~ 0x04 ;
}

static void buzzer_on(void)
{
 PORTB |=  0x04 ;
}

static void buzzer_off(void)
{
 PORTB &= (unsigned char)~ 0x04 ;
}

static void ultrasonic_init(void)
{

 TRISD = (TRISD | ( 0x08 )) & (unsigned char)~( 0x04 );

 PORTD = PORTD & (unsigned char)~( 0x04 );

}

static void ultrasonic_trigger(unsigned char trig_mask)
{
 PORTD = PORTD & (unsigned char)~trig_mask;
 t1_wait_us(2);

 PORTD = PORTD | trig_mask;
 t1_wait_us( 15u );

 PORTD = PORTD & (unsigned char)~trig_mask;
}

static unsigned int echo_width_us(unsigned char echo_mask)
{
 unsigned int t0;


 t0 = t1_now_us();
 while((PORTD & echo_mask) == 0) {
 if((unsigned int)(t1_now_us() - t0) >  30000u ) {
 return 0;
 }
 }


 t0 = t1_now_us();
 while((PORTD & echo_mask) != 0) {
 if((unsigned int)(t1_now_us() - t0) >  35000u ) {
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


 return (unsigned int)(us / 58);
}

void ir_sensors(unsigned char base1, unsigned char curve_base1, unsigned char slow1, unsigned char trimL1, unsigned char trimR1)
{

 unsigned char L = sensor_left();
 unsigned char R = sensor_right();
 if(L == 1 && R == 1){
 motor_forward();
 pwm_left(base1 + trimL1 + 20);
 pwm_right(base1 + trimR1 + 20);
 }
 else if(L == 0 && R == 0){
 motor_forward();
 pwm_left(base1 + trimL1 + 20);
 pwm_right(base1 + trimR1 + 20);
 }
 else if(L == 1 && R == 0){
 pivot_left();
 pwm_right(curve_base1);
 pwm_left(slow1);
 }
 else {
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
 else {
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
 else {
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
 PORTD |=  0x10 ;
 t1_wait_us(us);
 PORTD &= (unsigned char)~ 0x10 ;

 t1_wait_us(20000 - us);
}

void raise_flag(void)
{
 unsigned int k;
 for(k=0; k<50; k++)
 servo_write_us(2000);
}



static unsigned char parking_marker_seen(void)
{
 static unsigned char seen = 0;
 static unsigned long last_ms = 0;


 if((unsigned long)(sys_ms - last_ms) < 10) return 0;
 last_ms = sys_ms;

 if(line_left() && line_right()) {
 if(seen < 20) seen++;
 } else {
 seen = 0;
 }

 return (seen >= 5);
}

void beeping (unsigned char parked){
 if(parked && (buzz_tick < 1000)){
 buzzer_on();
 }else {
 buzzer_off();
 }
}



static void park_right(void)
{

 motor_stop();
 wait_ms(150);


 motor_forward();
 pwm_left( 40 );
 pwm_right( 40 );
 wait_ms(800);



 right_90();


 motor_forward();
 pwm_left( 40 );
 pwm_right( 40 );
 wait_ms(200);


 motor_stop();
 wait_ms(200);
}

static unsigned int wait_front_le(unsigned int cm, unsigned int sample_ms)
{
 unsigned int dF;

 wait_ms(sample_ms);
 dF = ultrasonic_read_cm( 0x04 ,  0x08 );

 if(dF != 0 && dF <= cm) return dF;
 else return 0;
}

static void wait_front_ge_stable(unsigned int cm, unsigned char stable_needed, unsigned int sample_ms)
{
 unsigned char stable = 0;
 unsigned int dF;

 while(stable < stable_needed)
 {
 wait_ms(sample_ms);

 dF = ultrasonic_read_cm( 0x04 ,  0x08 );
 if(dF != 0 && dF >= cm) stable++;
 else stable = 0;
 }
}


typedef enum { TURN_RIGHT = 0, TURN_LEFT = 1 } TurnDir;
static void turn_and_clear(TurnDir dir, unsigned char base_pwm, unsigned char trimL1, unsigned char trimR1)
{

 if(dir == TURN_RIGHT) {
 right_90();
 } else {
 left_90();
 }


 motor_forward();
 pwm_left(base_pwm + trimL1);
 pwm_right(base_pwm + trimR1);


 wait_front_ge_stable(30, 3, 25);
}


void main(void)
{


 unsigned int ldr = 0;
 unsigned long last_ldr_ms = 0;
 unsigned char dark_cnt = 0;
 unsigned char bright_cnt = 0;
 unsigned char mode = 0;



 unsigned char us_flag = 0;
 unsigned char turn_counter = 0;
 unsigned char obstacle_seen = 0;
 unsigned int dF = 0;


 unsigned long t = 0;
 unsigned char far;


 unsigned char tunnel_boost_done = 0;


 static const unsigned char stop_cm[4] = { 25, 30, 25, 25 };
 static const TurnDir turn_dir[4] = { TURN_RIGHT, TURN_RIGHT, TURN_LEFT, TURN_RIGHT };
 unsigned long step_start_ms = 0;
 unsigned char hit_cnt = 0;


 unsigned char parked = 0;
 unsigned char parking_seen = 0;



 TRISB |= 0x03;
 TRISD |= 0x03;

 TRISD &= (unsigned char)~ 0x10 ;
 PORTD &= (unsigned char)~ 0x10 ;

 TRISB |= (unsigned char) 0x70;

 TRISB &= (unsigned char)~0x80;
 PORTB &= (unsigned char)~0x80;

 buzzer_init();

 TRISC = 0x09;
 PORTC = 0x00;

 timer0_init_1ms();
 pwm_init();

 timer1_init_us();
 ultrasonic_init();
 adc_init_an0();


 while(sys_ms < 3000) { }
 PORTB |= 0x80;


 motor_forward();
 pwm_left( 50  +  4 );
 pwm_right( 50  +  3 );


 line_follow_boost_ms(180, 180,  4 ,  3 , 400);
 line_follow_boost_ms(30, 30,  4 ,  3 , 100);

 while((PORTB &  0x40 ) != 0){
 while(1)
 {
 while(mode == 0)
 {

 line_follow_step( 50 ,  180 ,  4 ,  3 );


 if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
 {
 last_ldr_ms = sys_ms;
 ldr = adc_read_an0();


 if(ldr >  400u ) {
 if(dark_cnt < 20) dark_cnt++;
 bright_cnt = 0;
 } else {
 dark_cnt = 0;
 bright_cnt = 0;
 }

 if(dark_cnt >= 5) {
 mode = 1;
 dark_cnt = 0;
 bright_cnt = 0;
 buzzer_on();
 }
 }

 }


 while(mode == 1)
 {
 if(tunnel_boost_done == 0) {
 line_follow_boost_ms(230, 230,  4 ,  3 , 900);
 tunnel_boost_done = 1;
 }


 line_follow_step( 50 ,  180 ,  4 ,  3 );


 if((unsigned long)(sys_ms - last_ldr_ms) >= 20)
 {
 last_ldr_ms = sys_ms;
 ldr = adc_read_an0();


 if(ldr <=  400u ) {
 if(bright_cnt < 20) bright_cnt++;
 dark_cnt = 0;
 } else {
 bright_cnt = 0;
 dark_cnt = 0;
 }

 if(bright_cnt >= 5) {
 mode = 2;
 bright_cnt = 0;
 dark_cnt = 0;
 buzzer_off();
 us_flag = 1;
 }
 }
 }


 while(mode == 2)
 {
 while(us_flag == 1 && turn_counter < 4)
 {

 if(obstacle_seen == 0 && (turn_counter == 2 || turn_counter == 3)) break;


 step_start_ms = sys_ms;
 hit_cnt = 0;
 while(1)
 {
 motor_forward();
 pwm_left( 50  +  4 );
 pwm_right( 50  +  3 );


 dF = wait_front_le(stop_cm[turn_counter], 25);
 if(dF != 0) hit_cnt++;
 else hit_cnt = 0;

 if(hit_cnt < 2) continue;
 hit_cnt = 0;


 if(turn_counter == 1)
 {
 unsigned long dt = (unsigned long)(sys_ms - step_start_ms);


 if(dt <= 4000u) obstacle_seen = 1;
 else obstacle_seen = 0;
 }


 turn_and_clear(turn_dir[turn_counter],  50 ,  4 ,  3 );
 turn_counter++;

 break;
 }

 if(mode == 3) break;
 }

 motor_forward();
 pwm_left( 50  +  4 );
 pwm_right( 50  +  3 );
 wait_ms(50);

 mode = 3;
 }
 while(mode == 3)
 {

 motor_forward();
 pwm_left( 50  +  4 );
 pwm_right( 50  +  3 );
 t = sys_ms;
 while(!parked && ((unsigned long)(sys_ms - t) <= 5000)){
 ir_sensors( 50 ,  180 ,  40 ,  4 ,  3 );
 line_follow_step_final( 50 ,  180 ,  4 ,  3 ,  40 );
 motor_forward();
 pwm_left( 50  +  4 );
 pwm_right( 50  +  3 );
 }

 while(!parked)
 {

 line_follow_step_final( 50 ,  180 ,  4 ,  3 ,  40 );


 if(!parking_seen && parking_marker_seen())
 {
 parking_seen = 1;
 }

 if(parking_seen)
 {

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

 while(1) { }
 }
 }
 }
}
