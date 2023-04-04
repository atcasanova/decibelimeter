declare -A settings
settings=( ["filter"]="a" ["max_mode"]="off" ["speed"]="slow" ["range"]="30-130" )

assign_settings() {
  local message="$1"
  local packed_settings=$(echo "$message" | cut -c 9-10)
  local binary_settings=$(binary "$packed_settings")
  
  if [ "${binary_settings:3:1}" -eq 1 ]; then
    settings["filter"]="c"
  else
    settings["filter"]="a"
  fi

  if [ "${binary_settings:2:1}" -eq 1 ]; then
    settings["max_mode"]="on"
  else
    settings["max_mode"]="off"
  fi

  if [ "${binary_settings:1:1}" -eq 1 ]; then
    settings["speed"]="fast"
  else
    settings["speed"]="slow"
  fi

  local range_index=$(echo "$message" | cut -c 11-12)
  settings["range"]=${AVAILABLE_RANGES["$range_index"]}
}

binary() {
  local hex_value="$1"
  echo "ibase=16; obase=2; $hex_value" | bc | awk '{printf "%04d\n", $0}'
}

format() {
  echo "db${settings[filter]}"
}

AVAILABLE_RANGES=("30-130" "30-60" "50-100" "60-110" "80-130")

pack_settings() {
  local filter_bit
  if [ "${settings[filter]}" == "c" ]; then
    filter_bit=1
  else
    filter_bit=0
  fi

  local max_mode_bit
  if [ "${settings[max_mode]}" == "on" ]; then
    max_mode_bit=1
  else
    max_mode_bit=0
  fi

  local speed_bit
  if [ "${settings[speed]}" == "fast" ]; then
    speed_bit=1
  else
    speed_bit=0
  fi

  local boolean_options=$(( 0 << 3 | speed_bit << 2 | max_mode_bit << 1 | filter_bit ))
  local range_index=$(printf "%s\n" "${!AVAILABLE_RANGES[@]}" | grep -w -n "${settings[range]}" | cut -d: -f1)

  printf "%02x%02x" "$boolean_options" "$range_index"
}
