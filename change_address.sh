#!/bin/bash

run() {
	echo $'\033[0;32m'"$@"$'\033[0m' >&2
	"$@"
}

PROG="/dev/ttyACM0"

TMP_IN="_read.hex"
TMP_OUT="_write.hex"

ADDRESS="$1"

PART="$(run easypdkprog -p "$PROG" probe |grep 'IC is supported'|sed 's/IC is supported: \([^ ]*\).*/\1/')"


ARCH="unknown"

if [ "x$PART" = "xPMS150C" ]; then
     ARCH="pdk13"
fi

if [ "x$PART" = "xPFS154" ]; then
     ARCH="pdk14"
fi

run easypdkprog -p "$PROG" -n "$PART" read "$TMP_IN" && \
run python3 test/settings.py "$ARCH" "$TMP_IN" set_address "$ADDRESS" > "$TMP_OUT" && \
run easypdkprog -p "$PROG" -n "$PART" --nocalibrate --noblankchk --noerase write "$TMP_OUT" && \
run easypdkprog -p "$PROG" -n "$PART" read "$TMP_IN" && \
(
	ADDRESS_READ="$(run python3 test/settings.py "$ARCH" "$TMP_IN" get_address)"

	if [ "x$ADDRESS" = "x$ADDRESS_READ" ]; then
		echo "Success: $ADDRESS_READ"
	else
		echo "Failure"
	fi
)

