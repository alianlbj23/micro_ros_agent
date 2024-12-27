#!/bin/bash

docker run -it --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v $(pwd)/esp32_reset.py:/workspace/esp32_reset.py \
  -v /dev:/dev \
  registry.screamtrumpet.csie.ncku.edu.tw/alianlbj23/pros_car_docker_image:latest \
  bash -c "python3 /workspace/esp32_reset.py"

docker run -d --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v /dev:/dev \
  -e ROS_DOMAIN_ID=1 \
  microros/micro-ros-agent:humble \
  serial --dev /dev/usb_rear_wheel

docker run -d --rm \
  --privileged \
  --network compose_my_bridge_network \
  -v /dev:/dev \
  -e ROS_DOMAIN_ID=1 \
  microros/micro-ros-agent:humble \
  serial --dev /dev/usb_front_wheel

echo "Both micro-ROS Agent containers are running in the background."
echo "Press Ctrl+C to immediately kill all micro-ROS Agent containers."

# 捕捉 Ctrl+C (SIGINT) 信號並直接強制關閉容器
trap 'echo "Killing all micro-ROS Agent containers..."; \
      for container in $(docker ps --filter "ancestor=microros/micro-ros-agent:humble" --format "{{.ID}}"); do \
          echo "Killing container: $container"; \
          docker kill $container 2>/dev/null || echo "Failed to kill $container"; \
      done; \
      exit 0' SIGINT

# 保持腳本運行直到按下 Ctrl+C
while true; do sleep 1; done