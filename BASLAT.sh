#!/usr/bin/env bash
# ---------------------------------------------------------------
#  Harby operatiw demir ýol daşamalaryny guramak — okuw diski
#  Bu faýl ýerli web-serweri işledýär we brauzeri açýar.
#  Diňe şeýle açylanda 2D/3D Flash modelleri hem işleýär.
# ---------------------------------------------------------------
cd "$(dirname "$0")" || exit 1

PORT=8777
while ss -ltn 2>/dev/null | grep -q ":$PORT " ; do PORT=$((PORT+1)); done

echo "Okuw diski işledilýär ... http://localhost:$PORT/index.htm"
echo "Ýapmak üçin şu penjirede Ctrl+C basyň."

python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null' EXIT INT TERM
sleep 1

if   command -v xdg-open >/dev/null 2>&1; then xdg-open "http://localhost:$PORT/index.htm"
elif command -v gio      >/dev/null 2>&1; then gio open "http://localhost:$PORT/index.htm"
else echo "Brauzerde açyň: http://localhost:$PORT/index.htm"
fi

wait $SRV
