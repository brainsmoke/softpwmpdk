#!/bin/bash

. "$( dirname "$0" )"/config.sh

run python3 test/settings.py "$ARCH" "$FIRMWARE" set_address "$ADDRESS" > "$TMP_OUT" && \
run easypdkprog -p "$PROG" -n "$PART" write "$TMP_OUT"

