#!/bin/bash
device=/dev/bus/usb/$(lsusb -d 64bd:74e3 | grep -Eo "[0-9]{3}" | head -2| tr '\n' '/' | sed 's/\/$//g')
STATE_REQUEST="\xb3$(printf '\\x%x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))\x00\x00\x00"
declare -f initialize
declare -f read_current_state
declare -f read_cap_data
declare -f send_state_request

exec 6<> $device

function initialize(){
	read_current_state
}

function read_current_state(){
	echo entrou na funcao read_current_state
	data=
	while (( ${#data} != 8 )); do
		echo tentando ${#data}: $data >&2
		send_state_request
		data=$(read_cap_data)
		echo $data | xxd -p
		sleep 0.1
	done
	record=$(echo -n "$data" | xxd -p)
}

function send_state_request(){
	echo Initializing with $STATE_REQUEST >&2
	echo -ne "$STATE_REQUEST" >&6 
}

function read_cap_data(){
	echo chamei read_cap_data >&2
	cap_data=
	until [ $cap_data ]; do 
		echo tentando ler novamente: $cap_data >&2
		read -t1 cap_data; 
	done <&6
	echo $cap_data
}


