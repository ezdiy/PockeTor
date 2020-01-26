#!/bin/sh
DIR=$(dirname "$0")/pocketor
if ! sudo /sbin/ifconfig lo 127.0.0.1 netmask 255.0.0.0 up; then
	if ! /mnt/secure/su /sbin/ifconfig lo 127.0.0.1 netmask 255.0.0.0 up; then
		dialog 3 "" "Your device doesn't support loopback interface. You'll need to root it." "OK"
		exit
	fi
fi

echo "PockeTor starting" > $DIR/notices.txt
$DIR/tor -f $DIR/torrc
export LD_PRELOAD=$DIR/proxy.so
export GET_PROXY=socks5://127.0.0.1:1080
export SET_APPNAME=PockeTor
function monitor() {
	while [ -e /proc/$1 ]; do
		sleep 1
	done
	killall tor
}
monitor $$ &
exec /ebrmain/bin/browser.app file://$DIR/start.html
