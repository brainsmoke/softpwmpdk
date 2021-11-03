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
program = []
ix = 0

offset = 4
uart_data = [255]*4 + [ int(s) for s in sys.argv[2:] ] + [ 0, 85, 255, 1,2,3,4,5 ]

def uart_next(ctx):
    global ix
    byte = (ix // (9+STOP_BITS))
    if byte >= len(uart_data):
        pdk.set_pin(ctx, BIT_UART)
        return
    bit = ix % (9+STOP_BITS)
    val = None
    if bit == 0:
        val = 0
    elif bit > 8:
        val = BIT_UART
    else:
        val = BIT_UART*bool( uart_data[byte] & (1<<(bit-1)) )

    pdk.set_pin(ctx, val)

    ix += 1

with open(sys.argv[1]) as f:
    program = pdk.parse_program(f.read(), arch='pdk14')

ctx = pdk.new_ctx()

while True:
    pa   = pdk.read_io_raw(ctx, 0x10)
    pc = pdk.get_pc(ctx)
    print ( ' '.join(" #"[bool( pa & (1<<CHANNELS[i]))] for i in range(3) ) + ''.join( " {:02x}".format(pdk.read_mem(ctx, i)) for i in range(17) ) + ' [A:{:02x}] [{:03x}] {}'.format(pdk.read_a(ctx), pc,pdk.get_opcode( ctx, program )))

    if pdk.get_opcode(program, ctx) in ('T0SN IO[0x010].0', 'T1SN IO[0x010].0'):
        uart_next(ctx)
    pdk.step(program, ctx)

