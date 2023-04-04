#!/bin/bash

source settings.sh
source record.sh
source device.sh

vendor_id="64BD"
product_id="74E3"


device_path=$(initialize_device "$vendor_id" "$product_id")

read_current_state() {
  send_state_request "$device_path"
  read_data_from_device "$device_path"
}

send_state_request() {
  local device_path="$1"
  STATE_REQUEST="b3$(head /dev/urandom | tr -dc 'a-f0-9' | head -c 6)00000000"
  echo -n "$STATE_REQUEST" | xxd -r -p > "$device_path"
}

set_device_settings() {
  local packed_settings=$(pack_settings)
  data="56${packed_settings}000000000000"
  echo -n "$data" | xxd -r -p > "$device_path"
  read_current_state
}

# Set device settings
set_device_settings

# Read data from the device continuously
while true; do
  data=$(read_current_state)
  assign_spl "$data"
  echo -e "$(date +'%H:%M:%S')\t SPL: ${spl}$(format)"
  if [ "${settings[speed]}" == "fast" ]; then
    sleep_interval=0.5
  else
    sleep_interval=1
  fi
  sleep $sleep_interval
done

close_device "$device_path"
