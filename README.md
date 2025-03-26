# micro_ros_agent
A system for automating ESP32 device reset and launching micro-ROS agent containers in a Docker environment.
## Overview
This project automates two key processes for robotics development with ESP32 devices:
1. Reset ESP32 devices via their serial connections (DTR reset)
2. Launch containerized micro-ROS agents for each device

The system uses a simple text file to manage device paths, making it easy to add or remove devices without modifying code.

## Files
- `activate.sh`: Main shell script that orchestrates the reset and container creation
- `esp32_reset.py`: Python script that performs ESP32 hardware reset via serial port
- `devices.txt`: onfiguration file containing device paths (one per line)

## Prerequisites
- Docker installed and configured
- Python 3 with pyserial packag (`pip install pyserial`)
- Access to the micro-ROS agent Docker image (`microros/micro-ros-agent:humble`)
- ESP32 devices connected via USB

## Setup
1. Clone this repository:
    ```shell
    git clone <repository-url>
    cd micro_ros_agent
    ```
2. Create or modify `devices.txt` with your ESP32 device paths:
    ```shell
    # Example: List one device path per line
    /dev/usb_robot_arm
    ```
3. Make the scripts executable:
    ```shell
    chmod +x activate.sh esp32_reset.py
    ```

## Usage
1. Ensure your ESP32 devices are connected and appear at the specified paths in `devices.txt`.
2. Run the activation script:
    ```shell
    ./activate.sh
    ```