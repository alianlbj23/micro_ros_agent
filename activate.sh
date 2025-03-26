#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TXT_FILE="${SCRIPT_DIR}/devices.txt"

# ESP32 reset using the Python script that reads from text file
docker run -it --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v "${SCRIPT_DIR}/esp32_reset.py:/workspace/esp32_reset.py" \
  -v "${SCRIPT_DIR}/devices.txt:/workspace/devices.txt" \
  -v /dev:/dev \
  registry.screamtrumpet.csie.ncku.edu.tw/alianlbj23/pros_car_docker_image:latest \
  bash -c "python3 /workspace/esp32_reset.py"

# Read device paths from the text file (skip comment lines)
DEVICES=()
CONTAINER_NAMES=()
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
    DEVICES+=("$line")
    # Generate container name by removing /dev/ prefix and replacing any remaining / with _
    CONTAINER_NAME="microros_$(echo "$line" | sed 's|/dev/||g' | sed 's|/|_|g')"
    CONTAINER_NAMES+=("$CONTAINER_NAME")
  fi
done < "$TXT_FILE"

# Start micro-ROS agent for each device
VALID_CONTAINER_NAMES=()
for i in "${!DEVICES[@]}"; do
  DEVICE="${DEVICES[$i]}"
  CONTAINER_NAME="${CONTAINER_NAMES[$i]}"

  # Check if device exists before starting container
  if [ -e "$DEVICE" ]; then
    echo "Starting micro-ROS agent for ${DEVICE} with name: ${CONTAINER_NAME}"
    docker run -d --rm \
      --privileged \
      --name "${CONTAINER_NAME}" \
      --network compose_my_bridge_network \
      -v /dev:/dev \
      -e ROS_DOMAIN_ID=1 \
      microros/micro-ros-agent:humble \
      serial --dev "${DEVICE}"

    # Store valid container names for cleanup
    VALID_CONTAINER_NAMES+=("$CONTAINER_NAME")
  else
    echo "Warning: Device ${DEVICE} not found, skipping container creation"
  fi
done

if [ ${#VALID_CONTAINER_NAMES[@]} -eq 0 ]; then
  echo "No valid devices found. No containers were created."
  exit 1
fi

echo "All micro-ROS Agent containers are running in the background."
echo "Press Ctrl+C to immediately kill all micro-ROS Agent containers."

# Print running containers for reference
echo "Running containers:"
docker ps --filter "ancestor=microros/micro-ros-agent:humble" --format "{{.ID}} => {{.Names}}"

# 捕捉 Ctrl+C (SIGINT) 信號並直接強制關閉容器
trap 'echo "Killing all micro-ROS Agent containers..."; \
      for container_name in "${VALID_CONTAINER_NAMES[@]}"; do \
          echo "Killing container: $container_name"; \
          docker kill "$container_name" 2>/dev/null || echo "Failed to kill $container_name"; \
      done; \
      exit 0' SIGINT

# 保持腳本運行直到按下 Ctrl+C
while true; do sleep 1; done