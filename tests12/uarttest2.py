#!/usr/bin/env python3
#
# Copyright (c) 2020 Erik Bosman <erik@minemu.org>
#
# Permission  is  hereby  granted,  free  of  charge,  to  any  person
# obtaining  a copy  of  this  software  and  associated documentation
# files (the "Software"),  to deal in the Software without restriction,
# including  without  limitation  the  rights  to  use,  copy,  modify,
# merge, publish, distribute, sublicense, and/or sell copies of the
# Software,  and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The  above  copyright  notice  and this  permission  notice  shall be
# included  in  all  copies  or  substantial portions  of the Software.
#
# THE SOFTWARE  IS  PROVIDED  "AS IS", WITHOUT WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY,  FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM, OUT OF OR IN
# CONNECTION  WITH THE SOFTWARE  OR THE USE  OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# (http://opensource.org/licenses/mit-license.html)
#

BIT_UART = (1<<0)
LED_BRIGHTNESS_OFFSET = 18
LOW_OFFSET=13
HIGH_OFFSET=14

STOP_BITS=5

import sys

import intelhex, pdk

program = []
t, tlast = 0, 0
ix = 0

uart_data = bytes.fromhex(''.join(c for c in sys.argv[2] if c in '0123456789ABCDEFabcdef'))

def get_fb_led(ctx, i):
    assert 0 <= i < 8
    return pdk.read_mem(ctx, LED_BRIGHTNESS_OFFSET+i)

def uart_next(ctx):
    global ix
    byte = (ix // (9+STOP_BITS))%256
    if byte >= len(uart_data):
        pdk.set_pin(ctx, BIT_UART)
        return
    byte = uart_data[byte]
    bit = ix % (9+STOP_BITS)
    if bit == 0:
        pdk.set_pin(ctx, 0)
        print ('s', end=' ')
    elif bit > 8:
        pdk.set_pin(ctx, BIT_UART)
        print ('e', end=' ')
    else:
        pdk.set_pin(ctx, BIT_UART*bool( byte & (1<<(bit-1)) ) )
        print (BIT_UART*bool( byte & (1<<(bit-1)) ), end=' ')

    ix += 1

with open(sys.argv[1]) as f:
    program = pdk.parse_program(f.read(), arch='pdk14')

last_fb = None
def cb(program, ctx):
    global t, tlast, last_fb
    fb = tuple( get_fb_led(ctx, i) for i in range(6) )
    if fb != last_fb:
        print( ' '.join(hex(x) for x in fb) )
        last_fb = fb
    t += 1
    if pdk.get_opcode(ctx, program) in ('T0SN IO[0x010].0', 'T1SN IO[0x010].0'):
        uart_next(ctx)
        print (t-tlast, hex(pdk.read_mem(ctx, LOW_OFFSET)), hex(pdk.read_mem(ctx, HIGH_OFFSET)))
        tlast = t
        
ctx = pdk.new_ctx()

pdk.run( program, ctx, callback=cb)
