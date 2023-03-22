#!/bin/bash

source "$(dirname "$0")/functions.sh"

while getopts "f:s:m:r:h" opt; do
  case $opt in
    f)
      filter="$OPTARG"
      ;;
    s)
      speed="$OPTARG"
      ;;
    m)
      max_mode="$OPTARG"
      ;;
    r)
      range="$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      print_usage
      exit 1
      ;;
  esac
done

main