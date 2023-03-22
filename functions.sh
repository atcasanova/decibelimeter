#!/bin/bash

# Configuration
vendor_id="0x64bd"
product_id="0x74e3"
state_request=$(printf "\xb3\x%02x\x%02x\x%02x\x00\x00\x00\x00" $(($RANDOM % 256)) $(($RANDOM % 256)) $(($RANDOM % 256)))

# Functions
function print_usage {
  # ...
}

function set_filter {
  # ...
}

function set_speed {
  # ...
}

function set_max_mode {
  # ...
}

function set_range {
  # ...
}

function get_device {
  local device_path="/dev/bus/usb/$(lsusb -d ${vendor_id}:${product_id} | grep -Eo '[0-9]{3}' | head -2 | tr '\n' '/' | sed 's/\/$//g')"
  echo "$device_path"
}

function read_data {
  local device_path=$(get_device)

  # Send state_request using dd and read data
  echo -e "$state_request" | dd oflag=direct of="$device_path" bs=1 count=8 2>/dev/null
  sleep 0.1

  # Read data from the device
  local data=$(dd iflag=direct if="$device_path" bs=1 count=8 2>/dev/null | xxd -p | tr -d '\n')
  echo "$data"
}

function process_data {
  local data=$1

  # Extract SPL value
  local message=$(echo "$data" | head -n 2 | tail -n 1 | awk '{print $3$4}')
  local spl=$(echo "$message" | awk -F '' '{printf "%d.%02d", "0x" $1$2, "0x" $3$4}')

  # Extract settings
  local settings_message=$(echo "$data" | head -n 3 | tail -n 1 | awk '{print $3}')
  local filter_bit=$(echo "$settings_message" | awk -F '' '{print $2}')
  local max_mode_bit=$(echo "$settings_message" | awk -F '' '{print $3}')
  local speed_bit=$(echo "$settings_message" | awk -F '' '{print $4}')

  # Set filter, max_mode, and speed based on the extracted settings
  filter=$( [ $filter_bit == "1" ] && echo "C" || echo "A" )
  max_mode=$( [ $max_mode_bit == "1" ] && echo "enabled" || echo "disabled" )
  speed=$( [ $speed_bit == "1" ] && echo "fast" || echo "slow" )

  echo "SPL: $spl dB$filter, MAX mode: $max_mode, Speed: $speed"
}

function main {
  while true; do
    data=$(read_data)
    processed_data=$(process_data "$data")
    echo "$processed_data"
    sleep 1
  done
}