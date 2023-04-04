source settings.sh
source record.sh
source device.sh

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
