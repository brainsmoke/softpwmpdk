
.module softpwmpdk

.include "pdk.asm"
.include "settings.asm"
.include "uart.asm"
.include "softpwm8.asm"

.area DATA (ABS)
.org 0x00

bufstart:
buf1:           .ds 1
buf2:           .ds 1
buf3:           .ds 1
buf_:           .ds (BUFSIZE - 3)
bufend:
val1:           .ds 1
val2:           .ds 1
val3:           .ds 1
off1:           .ds 1
off2:           .ds 1
off3:           .ds 1
cycle1:         .ds 1
cycle2:         .ds 1
cycle3:         .ds 1
out:            .ds 1
data:           .ds 1
reset_count:    .ds 1

wait_count:     .ds 1
bit_count:      .ds 1
buf_index:      .ds 1
buf_index_high: .ds 1 ; needs to be zero
stream_index:   .ds 1

index_const:    .ds 1

; word aligned
p_lo:           .ds 1
p_hi:           .ds 1

.area CODE (ABS)
.org 0x00

.ifeq DEVICE-PMS150C
set_fuse FUSE_SET_LVR_2V2
.endif
; pull mosfets low first

	clock_4mhz
brownout_erratum_workaround_init

;
;   ________                                                                        ________
;           ________0000000011111111222222223333333344444444555555556666666677777777
;           /\                                                                         /\
;          1/8 baud                                                                   9 1/2 baud
;    sample start bit (avg)                                                      sample stop bit (avg)
;
;baud = 19200
;start_wait = 6
;bit_wait = 4
;check_interval = 3*17
;cycles = (.5+start_wait+8*bit_wait)*check_interval
;t = 9.5/baud
;freq = cycles/t
;print(freq)
;
FREQ=3968337

	easypdk_calibrate FREQ, 3300

	mov a, #( (1<<CHANNEL1) | (1<<CHANNEL2) | (1<<CHANNEL3) )
	mov pac, a
	mov a, #0
	mov pa, a
	
	find_settings settings p_lo
	read_settings index_const

	softpwm_init
	uart_init

	u_idle:
	softpwm
	uart_idle u_idle, u_countdown, u_reset

	u_reset:
	softpwm
	uart_reset u_idle

	u_countdown:
	softpwm
	uart_countdown u_countdown, u_sample, u_stop_bit

	u_sample:
	softpwm
	uart_sample u_countdown

	u_stop_bit:
	softpwm
	uart_stop_bit u_store, u_stop_bit

	u_store:
	softpwm
	uart_store u_idle

settings:
;.rept 256
;nop
;.endm
mov a, #INDEX
; update index by nopping (0x0000) out this instruction and appending a new mov, #NEW_INDEX
;

