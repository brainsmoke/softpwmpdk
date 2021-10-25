
# 3-channel software PWM LED driver

* 912Hz, 8-bit PWM
* 3-channels, evenly spaced phase offsets
* inverse polarity compared to WS2811 (pin high = LED on)
* UART based signalling (19200 baud,)
* end-of-frame is determined using a reset delay (between 1-2msec)
* no output line, led index is hard-coded in the firmware
* tested on PFS154, should work on PMS150C

