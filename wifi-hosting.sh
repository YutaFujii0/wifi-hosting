#! /bin/bash

NIC=$(airmon-ng|grep 8188eu|awk '{print $2}')
out=$(airmon-ng|grep brcmfmac|awk '{print $2}')

systemctl stop dnsmasq
killall hostapd

if [ "$NIC" != "" ]; then
sed -i "s/wlan[0-9]\{1\}/$NIC/g" /etc/hostapd/hostapd.conf
sed -i "s/wlan[0-9]\{1\}/$NIC/g" /etc/dnsmasq.d/dnsmasq.conf

hostapd /etc/hostapd/hostapd.conf -B

ifconfig $NIC up 192.168.1.1 netmask 255.255.255.0
# route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1

systemctl start dnsmasq

if [ "$out" != "" ]; then
iptables --table nat --append POSTROUTING --out-interface $out -j MASQUERADE
# iptables --append FORWARD --in-interface $NIC -j ACCEPT
fi

echo 1 > /proc/sys/net/ipv4/ip_forward
fi
