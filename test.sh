docker run -it --rm \
  --privileged \
  -v /dev:/dev \
  --network compose_my_bridge_network \
  -e ROS_DOMAIN_ID=1 \
  microros/micro-ros-agent:humble \
  serial --dev /dev/usb_robot_arm