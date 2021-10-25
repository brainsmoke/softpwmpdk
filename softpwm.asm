
CHANNEL1  = 4
CHANNEL2  = 3
CHANNEL3  = 6
PINMASK   = ( (1<<CHANNEL1) | (1<<CHANNEL2) | (1<<CHANNEL3) )
PINMASK12 = ( (1<<CHANNEL1) | (1<<CHANNEL2) )

;
; STATE MACHINE:
;
;

.macro softpwm_init

;	mov a, #0
;	mov pa, a
;	mov a, #( (1<<CHANNEL1) | (1<<CHANNEL2) | (1<<CHANNEL3) )
;	mov pac, a

	clear out
	clear off1
	clear off2
	clear off3
	mov a, #1
	mov val1, a
	mov val2, a
	mov val3, a
	mov buf1, a
	mov buf2, a
	mov buf3, a
	mov cycle1, a
	clear cycle2
	clear cycle3
.endm

; more logic constraint puzzle than code :-E
;
.macro softpwm ?no_reset1, ?merge1, ?no_reset2, ?merge2, ?no_reset3, ?merge3, ?merge3low, ?merge3high

                           ;                     no edge  edge1   edge2   edge3

	mov a, out             ;  0 + 1                 0       0       0       0
	xor pa, a              ;  1 + 1      <---       1       1       1       1

	mov a, #PINMASK12      ;  2 + 1                 2       2       2       2
	mov out, a             ;  3 + 1                 3       3       3       3
	nop                    ;  4 + 1                 4       4       4       4

dzsn cycle1                ;  5 + 1 --.             5       5       5       5 
goto no_reset1             ;  6 + 2   |             6 7    (6)      6 7     6 7
	mov a, val1            ;  7 + 1 <-'                     7 
	mov off1, a            ;  8 + 1                         8
	mov a, #PINMASK        ;  9 + 1                         9
	t1sn pa, #CHANNEL1     ; 10 + 1                        10
	xor a, #(1<<CHANNEL1)  ; 11 + 1                        11
	dzsn off1              ; 12 + 1                        12
	xor a, #(1<<CHANNEL1)  ; 13 + 1                        13
	dzsn off2              ; 14 + 1                        14
	xor a, #(1<<CHANNEL2)  ; 15 + 1                        15
	dzsn off3              ; 16 + 1                        16
	xor a, #(1<<CHANNEL3)  ; 17 + 1                        17
	xor pa, a              ; 18 + 1      <---              18

	mov a, #28             ; 19 + 1                        19
	mov cycle2, a          ; 20 + 1                        20
	mov a, #55             ; 21 + 1                        21
	mov cycle3, a          ; 22 + 1                        22
no_reset3:
	mov a, #PINMASK        ; 23 + 1                23      23
	goto merge2            ; 24 + 2                24 25   24 25

no_reset1:
	mov a, #PINMASK        ;  8 + 1                 8               8       8
	dzsn off1              ;  9 + 1                 9               9       9
	xor a, #(1<<CHANNEL1)  ; 10 + 1                10              10      10
	dzsn off2              ; 11 + 1                11              11      11
	xor a, #(1<<CHANNEL2)  ; 12 + 1                12              12      12
	dzsn off3              ; 13 + 1                13              13      13
	xor a, #(1<<CHANNEL3)  ; 14 + 1                14              14      14
dzsn cycle2                ; 15 + 1 --.            15              15      15
goto no_reset2             ; 16 + 2   |            16 17          (16)     16 17
	nop                    ; 17 + 1 <-'                            17
	xor pa, a              ; 18 + 1      <---                      18
	mov a, #57             ; 19 + 1                                19
	mov cycle1, a          ; 20 + 1                                20
	mov a, val2            ; 21 + 1                                21
	mov off2, a            ; 22 + 1                                22
	mov a, #PINMASK        ; 23 + 1                                23
	t1sn pa, #CHANNEL2     ; 24 + 1                                24
	xor a, #(1<<CHANNEL2)  ; 25 + 1                                25
merge2:
	set1 out, #CHANNEL3    ; 26 + 1                26      26      26
	dzsn off1              ; 27 + 1                27      27      27
	xor a, #(1<<CHANNEL1)  ; 28 + 1                28      28      28
	dzsn off2              ; 29 + 1                29      29      29
	xor a, #(1<<CHANNEL2)  ; 30 + 1                30      30      30
	dzsn off3              ; 31 + 1                31      31      31
	xor a, #(1<<CHANNEL3)  ; 32 + 1                32      32      32
	dzsn off1              ; 33 + 1                33      38      38
	set0 out, #CHANNEL1    ; 34 + 1                34      39      39
	xor pa, a              ; 35 + 1      <---      35      35      35
	dzsn off2              ; 36 + 1                36      40      40
	set0 out, #CHANNEL2    ; 37 + 1                37      37      37
	goto merge3            ; 38 + 2                38 39   38 39   38 39

no_reset2:
	xor pa, a              ; 18 + 1      <---      18                      18
	mov a, #PINMASK        ; 19 + 1                19                      19
dzsn cycle3                ; 20 + 1 --.            20                      20
goto no_reset3             ; 21 + 2   |            21 22                  (21)
	dzsn off1              ; 22 + 1 <-'                                    22
	xor a, #(1<<CHANNEL1)  ; 23 + 1                                        23
	dzsn off2              ; 24 + 1                                        24
	xor a, #(1<<CHANNEL2)  ; 25 + 1                                        25
	dzsn off3              ; 26 + 1                                        26
	xor a, #(1<<CHANNEL3)  ; 27 + 1                                        27
	mov off3, a            ; 28 + 1                                        28
	mov a, val3            ; 29 + 1                                        29
	xch a, off3            ; 30 + 1                                        30
	dzsn off1              ; 31 + 1                                        31
	set0 out, #CHANNEL1    ; 32 + 1                                        32
	dzsn off2              ; 33 + 1                                        33
	set0 out, #CHANNEL2    ; 34 + 1                                        34
	xor pa, a              ; 35 + 1      <---                              35
	t0sn pa, #CHANNEL3     ; 36 + 1                                        36       edge3 low
	goto merge3high        ; 37 + 2                                        37 38        (37)
	dzsn off3              ; 38 + 1                                                      38
	set1 out, #CHANNEL3    ; 39 + 1                                                      39
	goto merge3low         ; 40 + 2                                                      40 41

merge3high:
	set1 out, #CHANNEL3    ; 39 + 1                                        39
merge3:
	dzsn off3              ; 40 + 1                40      40      40      40
	set0 out, #CHANNEL3    ; 41 + 1                41      41      41      41
merge3low: 

.endm

