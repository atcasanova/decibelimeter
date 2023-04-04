#!/bin/bash

vendor_id=0x64bd
product_id=0x74e3

STATE_REQUEST=$(printf '\xb3%.2x%.2x%.2x\00\00\00\00' $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))

hid_device_path="/dev/hidrawN" # Replace N with the appropriate number

# Reads 8 bytes of data from the HID device
read_cap_data() {
  local timeout=1000
  local start_time=$(date +%s%N | cut -b1-13)
  local elapsed_time=0

  while true; do
    if read -r -n 8 data < "$hid_device_path"; then
      echo "$data"
      break
    fi

    elapsed_time=$(($(date +%s%N | cut -b1-13) - start_time))
    if [[ elapsed_time -ge timeout ]]; then
      break
    fi
  done
}

# Sends the state request to the HID device
send_state_request() {
  printf '%s' "$STATE_REQUEST" > "$hid_device_path"
}

# Sets the settings on the device and reads the current state
set_settings() {
  local settings_data=$(printf '\x56%s\00\00\00\00\00\00' "$1")
  printf '%s' "$settings_data" > "$hid_device_path"
  read_cap_data
  sleep 0.1
}

# Reads the current state from the device, processes the data, and calls the provided callback function
read_current_state() {
  local callback="$1"
  local record

  while true; do
    send_state_request
    record=$(read_cap_data)

    if [[ ${#record} -eq 8 ]]; then
      settings=$(get_settings_from_record "$record")
      $callback "$record"
      break
    else
      sleep 0.1
    fi
  done
}

# Implement the get_settings_from_record and process_record functions according to your needs
get_settings_from_record() {
  # Extract settings from the record
}

process_record() {
  # Process the record data
}

# Main loop for reading data from the device
read_device_data() {
  local callback="$1"

  while true; do
    read_current_state "$callback"
    sleep 0.5 # Adjust the sleep duration based on the desired speed
  done
}

# Replace /dev/hidrawN with the correct hidraw device path
hid_device_path="/dev/hidrawN"

# Example usage: Read data from the device and process it
read_device_data process_record
