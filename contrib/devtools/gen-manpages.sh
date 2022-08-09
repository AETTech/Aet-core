#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

AETD=${AETD:-$SRCDIR/aetd}
AETCLI=${AETCLI:-$SRCDIR/aet-cli}
AETTX=${AETTX:-$SRCDIR/aet-tx}
AETQT=${AETQT:-$SRCDIR/qt/aet-qt}

[ ! -x $AETD ] && echo "$AETD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
LTCVER=($($AETCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$AETD --version | sed -n '1!p' >> footer.h2m

for cmd in $AETD $AETCLI $AETTX $AETQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${LTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${LTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m