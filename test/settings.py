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

arch = sys.argv[1]
filename = sys.argv[2]
command = sys.argv[3]

if command not in ('get_address', 'set_address'):
    raise ValueError("command not in ('get_address', 'set_address')")

if command == 'set_address':
    index = int(sys.argv[4])
    if index > 85:
         raise ValueError("address > 85")

    led_address = index*3

TRY_CYCLES_MAX = 10000

if arch not in ('pdk13', 'pdk14'):
    raise ValueError("arch not in ('pdk13', 'pdk14')")

unset = { 'pdk13':0x1fff, 'pdk14':0x3fff }[arch]
set_hi = { 'pdk13':0x1700, 'pdk14':0x2f00 }[arch]

with open(filename) as f:
    program = pdk.parse_program(f.read(), arch=arch)

ctx = pdk.new_ctx()

addr = None
read_address = None

for i in range(TRY_CYCLES_MAX):
    op = pdk.get_opcode(ctx, program)
    pdk.step(program, ctx)
    if op == 'LDSPTL':
        addr = pdk.read_stack_top_word(ctx)
        read_address = pdk.read_a(ctx)
        break
else:
    raise Exception("no LDSPTL near the start of execution")

if command == 'get_address':
    if read_address % 3 != 0:
        raise Exception("address not a multiple of 3")
    print(read_address//3)
    sys.exit()

cur_opcode = program[addr][2]
next_opcode = program[addr+1][2]
replacement_opcode = ( set_hi | led_address )

def write_word(m, byteaddr, data):
    m[byteaddr+0] = data&0xff
    m[byteaddr+1] = (data>>8)&0xff

m = {}

if cur_opcode == replacement_opcode:
    if read_address != led_address:
        raise Exception("configured & used addresses should match, but they don't")

    print("Success: nothing to do", file=sys.stderr)
elif cur_opcode & replacement_opcode == replacement_opcode:
    write_word(m, addr*2, replacement_opcode)
else:
    if next_opcode != unset:
        raise ValueError("next opcode not unset {:04x}".format(next_opcode))
    write_word(m, addr*2, cur_opcode&0xff)
    write_word(m, (addr+1)*2, replacement_opcode)

print(intelhex.generate(m), end='')

sys.exit(0)
