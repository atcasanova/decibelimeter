#!/bin/bash

# Function to assign SPL based on the message received
assign_spl() {
  local message="$1"
  integer_part="${message:0:3}"
  decimal_part="${message:3:1}"
  spl="${integer_part}.${decimal_part}"
}

# Function to format the record
print_record() {
  local output
  output=$(date +"%H:%M:%S")
  output+="\t SPL: ${spl}dB${filter^^}"
  output+=$([[ $max_mode == 1 ]] && echo -e "\t MAX mode")
  echo "$output"
}

# Function to initialize a record based on the message received
initialize_record() {
  local message="$1"
  assign_spl "$message"
  assign_settings "$message"
}
