
# 3-channel 16 bit software PWM LED driver

<img src="img/hdr.jpg">

* 1800Hz, 16-bit PWM (12-bit + 4 bits dithering)
* 3-channels, almost evenly spaced phase offsets
* inverse polarity compared to WS2811 (pin high = LED on)
* UART based signalling, 38400 baud, 16 bit values, (2x 8bit uart frame, little endian/channel)
* end-of-frame is determined using a reset delay (between 1-2msec)
* no output line, led index is hard-coded in the firmware
* tested on PFS154 & PMS150C


# 3-channel 8 bit software PWM LED driver

* 912Hz, 8-bit PWM
* 3-channels, evenly spaced phase offsets
* inverse polarity compared to WS2811 (pin high = LED on)
* UART based signalling (19200 baud,)
* end-of-frame is determined using a reset delay (between 1-2msec)
* no output line, led index is hard-coded in the firmware
* tested on PFS154 & PMS150C


# Change address:

Even on one-time programmable chips, a limited number of address changes
if possible:

```
$ ./change_address.sh 4   # this is the fourth chip in the LED strip
```

