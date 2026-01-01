#!/bin/bash
# Install necessary tools using pacman (available in official Arch repos)
pacman -Syu --noconfirm
pacman -S --noconfirm dsniff nmap net-tools arp-scan xterm
