#!/bin/bash

# Function to assign settings based on the message received
assign_settings() {
  local message="$1"
  binary_settings=$(printf "%04d" $(echo "ibase=16; obase=2; ${message:4:1}" | bc))
  filter=$((${binary_settings:3:1} == 1 ? "c" : "a"))
  max_mode=${binary_settings:2:1}
  speed=$((${binary_settings:1:1} == 1 ? "fast" : "slow"))
  range=$(echo "ibase=16; ${message:5:1}" | bc)
}

# Function to pack the settings into a single message
pack_settings() {
  filter_bit=$(($filter == "c" ? 1 : 0))
  max_mode_bit=$max_mode
  speed_bit=$(($speed == "fast" ? 1 : 0))

  boolean_options=$(echo "obase=16; ibase=2; 0${speed_bit}${max_mode_bit}${filter_bit}" | bc)
  echo "${boolean_options}${range}"
}
