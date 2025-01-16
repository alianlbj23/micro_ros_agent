#!/bin/bash

# 定義設備名稱
DEVICE1="/dev/usb_rear_wheel"
DEVICE2="/dev/usb_front_wheel"

# 強制重啟 ESP32 (模擬 DTR 操作)
reset_esp32() {
    local device=$1
    echo "Resetting ESP32 on $device..."

    stty -F "$device" -hupcl 2>/dev/null || { echo "Error: Cannot configure $device"; return 1; }

    exec 3<>"$device" || { echo "Error: Cannot open $device"; return 1; }

    echo "Setting DTR LOW..."
    stty -F "$device" hupcl
    sleep 0.1

    echo "Setting DTR HIGH..."
    stty -F "$device" -hupcl
    sleep 1

    exec 3<&-
    echo "ESP32 on $device reset complete!"
}

# 先重啟 ESP32 設備
reset_esp32 "$DEVICE1"
reset_esp32 "$DEVICE2"

docker run -d --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v /dev:/dev \
  -e ROS_DOMAIN_ID=1 \
  microros/micro-ros-agent:humble \
  serial --dev "$DEVICE1"

docker run -d --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v /dev:/dev \
  -e ROS_DOMAIN_ID=1 \
  microros/micro-ros-agent:humble \
  serial --dev "$DEVICE2"

echo "Both micro-ROS Agent containers are running in the background."
echo "Press Ctrl+C to immediately kill all micro-ROS Agent containers."

# 捕捉 Ctrl+C (SIGINT) 信號並直接強制關閉 micro-ROS 容器
trap 'echo "Killing all micro-ROS Agent containers..."; \
      for container in $(docker ps --filter "ancestor=microros/micro-ros-agent:humble" --format "{{.ID}}"); do \
          echo "Killing container: $container"; \
          docker kill $container 2>/dev/null || echo "Failed to kill $container"; \
      done; \
      exit 0' SIGINT

# 保持腳本運行直到按下 Ctrl+C
while true; do sleep 1; done
