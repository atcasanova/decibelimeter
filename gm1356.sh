#!/bin/bash

source settings.sh
source record.sh

initialize_device() {
  local vendor_id="$1"
  local product_id="$2"
  hid_device_path=$(find /sys/bus/hid/devices -maxdepth 1 -name "*:${vendor_id}:${product_id}.*" -type d | head -n 1)
  hidraw_path=$(find "$hid_device_path" -name "hidraw*" -type d | head -n 1)
  device_path="/dev/$(basename "$hidraw_path")"
  echo "Device path: $device_path"
}

read_data_from_device() {
  local device_path="$1"
  local message_length=16
  local message=$(dd if="$device_path" bs=1 count=$message_length 2>/dev/null | xxd -p -c $message_length)
  echo "$message"
}

close_device() {
  # As the device is not being held open by the script, there is no need to close it explicitly.
  # The device will be automatically closed when the script exits.
  true
}

vendor_id="64BD"
product_id="74E3"

device_path=$(initialize_device "$vendor_id" "$product_id")

while true; do
  message=$(read_data_from_device "$device_path")
  initialize_record "$message"
  print_record
  sleep $(($speed == "fast" ? 0.5 : 1))
done

close_device "$device_path"
