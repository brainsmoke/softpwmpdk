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

import sys

import intelhex, pdk

BIT_UART = (1<<0)
CHANNELS = [ 4, 3, 6 ]

STOP_BITS=5
SAMPLES_PER_BYTE = (9+STOP_BITS)
program = []
ix = 0
cur = 0

offset = 3
uart_data = [
	[85]*offset + [ 85, 85, 85 ],
	[85]*offset + [ 255, 85, 0 ],
	[85]*offset + [ 85, 0, 255 ],
	[85]*offset + [ 255, 255, 0 ],
	[85]*offset + [ 0,  0, 255 ],
	[85]*offset + [ 255, 85, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 255, 255, 255 ],
	[85]*offset + [ 255, 255, 255 ],
	[85]*offset + [ 255, 255, 255 ],
	[85]*offset + [ 255, 255, 255 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
	[85]*offset + [ 0, 0, 0 ],
]


def uart_next(ctx):
    global ix, cur

    if ix > len(uart_data[cur])*SAMPLES_PER_BYTE + 300:
        cur = (cur+1)%len(uart_data)
        ix = 0

    byte = (ix // SAMPLES_PER_BYTE)
    if byte >= len(uart_data[cur]):
        val = BIT_UART
    else:
        bit = ix % SAMPLES_PER_BYTE
        val = None
        if bit == 0:
            val = 0
        elif bit > 8:
            val = BIT_UART
        else:
            val = BIT_UART*bool( uart_data[cur][byte] & (1<<(bit-1)) )

    pdk.set_pin(ctx, val)

    ix += 1

with open(sys.argv[1]) as f:
    program = pdk.parse_program(f.read(), arch='pdk14')

ctx = pdk.new_ctx()

s=[]
skip=True
t=0
while True:
    pa = pdk.read_io_raw(ctx, 0x10)
    pc = pdk.get_pc(ctx)

    leds = tuple( int(bool( pa & (1<<c)) ) for c in CHANNELS )
    if leds != (0,0,0):
        skip = False

    if not skip:

        if t % 17 == 0:
            if len(s) == 85:
                s=[]
            s += [leds]
            if len(s) == 85:
                print ( ''.join( " A"[t[0]] for t in s ) )
                print ( ''.join( " B"[t[1]] for t in s ) )
                print ( ''.join( " C"[t[2]] for t in s ) )
                print ()
        else:
            assert leds == s[-1]

    if pdk.get_opcode(program, ctx) in ('T0SN IO[0x010].0', 'T1SN IO[0x010].0'):
        uart_next(ctx)
    pdk.step(program, ctx)

    if not skip:
        t += 1

