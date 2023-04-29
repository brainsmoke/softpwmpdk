#!/bin/bash

. "$( dirname "$0" )"/config.sh

run easypdkprog -p "$PROG" -n "$PART" read "$TMP_IN" && \
(
	ADDRESS="$(run python3 test/settings.py "$ARCH" "$TMP_IN" get_address)"
	if [ x"$ADDRESS" != "x" ]; then
		echo "Address: $ADDRESS"
	else
		echo "Failure"
	fi
)

