#!/bin/bash

initialize_device() {
  local vendor_id="$1"
  local product_id="$2"
  
  # Find the bus and device number using lsusb
  usb_device_info=$(lsusb | grep -i "${vendor_id}:${product_id}")
  bus=$(echo "$usb_device_info" | awk '{print $2}')
  device=$(echo "$usb_device_info" | awk '{print $4}' | tr -d ':')

  # Find the corresponding hidraw device
  hid_device_base_path="/sys/bus/usb/devices/${bus}-${device}/hidraw"
  hidraw_path=$(find "$hid_device_base_path" -name "hidraw*" -type d | head -n 1)

  if [[ -z "$hidraw_path" ]]; then
    echo "Device not found. Please ensure it's connected."
    exit 1
  fi

  device_path="/dev/$(basename "$hidraw_path")"
  echo "$device_path"
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
