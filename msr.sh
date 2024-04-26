#!/bin/sh

#!/bin/bash

# Default help message
show_help() {
  echo "Usage: $0 [-h] --prefetch [enable|disable]"
  echo "  -h, --help      Display this help message and exit."
  echo "  --prefetch      Set prefetch to 'enable' or 'disable'."
}

# Sets the bits in the mask in the specified MSR. Takes "MSR" and "mask" as arguments.
set_msr_mask() {
  local MSR=$1
  local mask=$2
  current_value=$(sudo rdmsr -d $MSR)
  set_value=$(($current_value | $mask))
  sudo wrmsr -a $MSR ${set_value}
}

# Clears the bits in the mask in the specified MSR. Takes "MSR" and "mask" as arguments.
clear_msr_mask() {
  local MSR=$1
  local mask=$2
  current_value=$(sudo rdmsr -d $MSR)
  cleared_value=$(($current_value & ~$mask))
  sudo wrmsr -a $MSR ${cleared_value}
}


# Writes a 0 to bits 0, 1, 2, 3, 5 of MSR 0x108, which is PREFETCH_CONTROL on AMD ZEN4
enable_prefetch() {
  echo "Enabling hardware prefetch"
  MSR="0xC0000108"
  clear_msr_mask $MSR "47"
}

# Writes a 1 to bits 0, 1, 2, 3, 5 of MSR 0x108, which is PREFETCH_CONTROL on AMD ZEN4
disable_prefetch() {
  echo "Disabling hardware prefetch"
  MSR="0xC0000108"
  set_msr_mask $MSR "47"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --prefetch)
      if [ -n "$2" ] && [[ "$2" == "enable" || "$2" == "disable" ]]; then
        PREFETCH=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing or invalid. Use 'enable' or 'disable'."
        show_help
        exit 1
      fi
      ;;
    *)
      echo "Error: Unsupported flag $1"
      show_help
      exit 1
      ;;
  esac
done

# Check if the prefetch argument has been provided
if [ -z "$PREFETCH" ]; then
  echo "Error: --prefetch flag is required with 'enable' or 'disable' as argument."
  show_help
  exit 1
fi

# Implement the prefetch logic
if [ "$PREFETCH" == "enable" ]; then
  enable_prefetch
elif [ "$PREFETCH" == "disable" ]; then
  disable_prefetch
fi
