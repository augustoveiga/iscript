#!/bin/bash
#Version 1.0 - November 2015
#Written by Augusto Veiga

bold=$(tput bold)

function help() {
	echo ""
	echo "  @@@@@@   @@@@@@     @@@@@@   @@@@@@@   @@@@@@  @@@@@@@   @@@@@@@@"
        echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@    @@     @@"
        echo "    @@    @@         @@        @@    @@    @@    @@    @@     @@"
        echo "    @@     @@@@@@    @@        @@@@@@@     @@    @@@@@@@      @@"
        echo "    @@          @@   @@        @@    @@    @@    @@           @@"
        echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@           @@"
        echo "  @@@@@@   @@@@@@     @@@@@@   @@    @@  @@@@@@  @@           @@"
	echo ""
	echo "iscript - Simple script to run NMAP + NIKTO + SSLSCAN TEST."
	echo ""
	echo "-i to input a IP or many IPs as a target - eg: 192.168.1.1 or 192.168.1.1/24 or 192.168.1.1-100"
	echo "-l to input a file with target(s)"
	echo "--help to show help menu"
	echo ""
}

if [ $1 ]
then
	case "$1" in
	-i)
	echo ""
	echo "  @@@@@@   @@@@@@     @@@@@@   @@@@@@@   @@@@@@  @@@@@@@   @@@@@@@@"
	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@    @@     @@"
	echo "    @@    @@         @@        @@    @@    @@    @@    @@     @@"
	echo "    @@     @@@@@@    @@        @@@@@@@     @@    @@@@@@@      @@"
	echo "    @@          @@   @@        @@    @@    @@    @@           @@"
	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@           @@"
	echo "  @@@@@@   @@@@@@     @@@@@@   @@    @@  @@@@@@  @@           @@"
	mkdir /root/Desktop/iscriptResult
	mkdir /root/Desktop/iscriptResult/NMAP
	mkdir /root/Desktop/iscriptResult/SSLSCAN
	mkdir /root/Desktop/iscriptResult/NIKTO
	echo ""
	echo -e "\e[1;31m${bold}UPLIST - NMAP\e[0m"
	nmap -sP -T4 $2 -oG /root/Desktop/iscriptResult/NMAP/pingscan
	grep Up /root/Desktop/iscriptResult/NMAP/pingscan | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/uplist
	echo ""
	echo -e "\e[1;31m${bold}NMAP SCAN - PORT SCANNER + BANNER\e[0m"
	nmap -Pn -A -vv $2 -oG /root/Desktop/iscriptResult/NMAP/nmap_result
	grep 80/open /root/Desktop/iscriptResult/NMAP/nmap_result | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port80
	grep 443/open /root/Desktop/iscriptResult/NMAP/nmap_result | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port443
	echo ""
	echo -e "\e[1;31m${bold}SSLSCAN\e[0m"
	echo ""
	sslscan --no-failed --show-certificate --xml=/root/Desktop/iscriptResult/SSLSCAN/$2 --targets=/root/Desktop/iscriptResult/NMAP/port443
	echo ""
	echo -e "\e[1;31m${bold}NIKTO SCAN\e[0m"
	echo ""
	nikto -host /root/Desktop/iscriptResult/NMAP/port80 -port 80 -o /root/Desktop/iscriptResult/NIKTO/$2.htm
	echo""
	nikto -host /root/Desktop/iscriptResult/NMAP/port443 -port 443 -o /root/Desktop/iscriptResult/NIKTO/$2.htm
	rm /root/Desktop/iscriptResult/NMAP/uplist
	rm /root/Desktop/iscriptResult/NMAP/pingscan
	rm /root/Desktop/iscriptResult/NMAP/port80
	rm /root/Desktop/iscriptResult/NMAP/port443
	;;
	-l)
	list=$(< $2)
	echo "$list"
	;;
	--help)
		help;
	;;
	esac
else
	help;
fi
