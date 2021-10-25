
.globl INDEX

PIN_UART   = 0
MASK_UART  = 1<<(PIN_UART)
BUFSIZE = 4 ; needs to be a power of two
START_DELAY = 6
DATA_DELAY = 4

.macro uart_init
	mov a, #MASK_UART
	mov paph, a
	clear wait_count
	clear bit_count
	clear reset_count
	clear data
	clear stream_index
	clear buf_index
	clear buf_index_high

.endm

;
; UART STATE MACHINE
;
; .__________________. <-----------------------------------.
; |                  | <-.                                 |
; |    uart idle     |   | no start bit                    |
; |_________.________|---'                                 |
;           |                                              |
;           | wait_count = 33                              |
; ._________V________. <-------------------------------.   |
; |                  | <-.                             |   |
; |  uart countdown  |   | 1.) while ( --wait_count )  |   |
; |___.______________|---'                             |   |
;     |             `-----------------------.          |   |
;  2. | while (--bit_count)        3.) else |          |   |
; .___V______________.                      |          |   |
; |                  |                      |          |   |
; |   uart sample    | wait_count = 22      |          |   |
; |__________________|----------------------|----------'   |
;                                  .________V_________.    |
;                               .->|                  |    |
;                      bad bit  |  |  uart stop bit   |    |
;                               '--|__________________|    |
;                                           |              |
;                                  .________V_________.    |
;                                  |                  |    |
;                                  |    uart read     |----'
;                                  |__________________|    
;
; prereq: wait_count = 0 ; bit_count = 0
;

.macro uart_idle out_idle, out_countdown, out_reset, ?l1, ?l2
	nop                     ; XXXXXXXXX
	t0sn pa, #PIN_UART      ; 0 + 1
	goto l1                 ; 1 + 1 | 2 --.
	mov a, #(START_DELAY-1) ; 2 + 1       |
	mov wait_count, a       ; 3 + 1       |
	mov a, #9               ; 4 + 1       |
	mov bit_count, a        ; 5 + 1       |
	goto out_countdown      ; 6 + 2 = 8   |
l1:	dzsn reset_count        ; 3 + 1     <-'
	goto l2                 ; 4 + 2
	clear stream_index      ; 5 + 1
	goto out_reset          ; 6 + 2 = 8
l2:	goto out_idle           ; 6 + 2 = 8
.endm

.macro uart_reset out_idle
	nop                     ; XXXXXXXXXX
	mov a, buf1             ; 0 + 1
	mov val1, a             ; 1 + 1
	mov a, buf2             ; 2 + 1
	mov val2, a             ; 3 + 1
	mov a, buf3             ; 4 + 1
	mov val3, a             ; 5 + 1
	goto out_idle           ; 6 + 2
.endm

.macro uart_countdown out_countdown, out_sample, out_stop_bit, ?l1, ?l2, ?l3, ?l4
	nop                     ; XXXXXXXXX
	dzsn wait_count         ; 0 + 1
	goto l1                 ; 1 + 1 | 2   --.
	dzsn bit_count          ; 2 + 1         |
	goto l2                 ; 3 + 1 | 2     |
	clear reset_count       ; 4 + 1         |
	inc data                ; 5 + 1         | [ compensate in-mem data for pre-decrement: [0..255] -> [1..255,0]
	goto out_stop_bit       ; 6 + 2 = 8     |
l2:	sr data                 ; 5 + 1         | [ save cycle in uart_sample :-) ]
	goto out_sample         ; 6 + 2 = 8     |
l1:	inc stream_index        ; 3 + 1       <-'
	subc stream_index       ; 4 + 1
	dec stream_index        ; 5 + 1
	goto out_countdown      ; 6 + 2 = 8
.endm

.macro uart_sample out_countdown, ?l1
	nop                     ; XXXXXXXXX
;	[ sr data ] in uart_countdown
	t0sn pa, #PIN_UART      ; 0 + 1
	set1 data, #7           ; 1 + 1
	mov a, #(DATA_DELAY-1)  ; 2 + 1
	mov wait_count, a       ; 3 + 1      [ wait_count = 4 ]
	goto l1                 ; 4 + 2
l1:	goto out_countdown      ; 6 + 2 = 8
.endm

.macro uart_stop_bit out_store, out_bad, ?l0, ?l1
	set1 reset_count, #7    ; XXXXXXXXX
	t1sn pa, #PIN_UART         ; 0 + 1
	goto l0                    ; 1 + 1 | 2 --. [ stop bit needs to be high ]
	mov a, stream_index        ; 2 + 1       |
	sub a, #INDEX              ; 3 + 1       |
	mov buf_index, a           ; 4 + 1       |
	inc stream_index           ; 5 + 1       |
	goto out_store             ; 6 + 2 = 8   |
l0: mov a, #254                ; 3 + 1  <----'
	mov stream_index, a        ; 4 + 1
	nop                        ; 5 + 1
	goto out_bad               ; 6 + 2 = 8
.endm

.macro uart_store out_idle, ?l1, ?l2
	mov a, buf_index           ; 0 + 1
	and a, #(BUFSIZE-1)        ; 1 + 1
	ceqsn a, buf_index         ; 2 + 1 \
	goto l1                    ; 3 + 2 | + 1
	mov a, data                ; 4 + 1 /
	idxm buf_index, a          ; 5 + 2
l2:	goto out_idle              ; 7 + 2
l1:	goto l2                    ; 5 + 2
.endm


.macro uart_no_store out_idle
	nop                     ; XXXXXXXXX
	nop                     ; 0 + 1
	nop                     ; 1 + 1
	nop                     ; 2 + 1
	nop                     ; 3 + 1
	nop                     ; 4 + 1
	clear data              ; 5 + 1
	goto out_idle           ; 6 + 2
.endm


