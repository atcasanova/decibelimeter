#!/bin/bash

declare -f print_value
declare -f assign_spl

function assign_spl(){
	message="$1"
	echo "obase=10; ibase=16; scale=1; ${message:0:3}"|bc|sed 's/^../\0./g'
}

function print_value(){
	valor="$1"
	output="$(date "+%Y-%m-%d %H:%M:%S")"
	output+='	'
	output+="SPL: $(assign_spl "$valor")"
	echo "$output"
}

