#!/bin/bash

DIS="../fppa-pdk-tools/dispdk"

for i in *-pdk13.ihx; do

	diff -ru  <("$DIS" 0x2A16 "$i"|sed 's:.*   ::') <("$DIS" 0x2AA1 "${i%-pdk13.ihx}-pdk14.ihx"|sed 's:.*   ::')

done
