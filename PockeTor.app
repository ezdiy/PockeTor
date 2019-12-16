#!/bin/sh
DIR=$(dirname "$0")/pocketor
ip=""
for i in `seq 1 3`; do
	ip=$(/sbin/ifconfig eth0 |grep 'inet addr' | sed -e 's/.*addr:\([^ ]*\).*/\1/g' | head -1)
	if [ "$ip" == "" ]; then
		netagent net on
		netagent connect
	else
		break
	fi
done

echo "PockeTor starting, local ip=$ip" > $DIR/notices.txt
$DIR/tor -f $DIR/torrc
export LD_PRELOAD=$DIR/proxy.so
export GET_PROXY=socks5://$ip:1080
export SET_APPNAME=PockeTor
function monitor() {
	while [ -e /proc/$1 ]; do
		sleep 1
	done
	killall tor
}
monitor $$ &
exec /ebrmain/bin/browser.app file://$DIR/start.html
