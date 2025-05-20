#!/usr/bin/env python3
import yaml
import subprocess
import os
import signal
import sys
import termios
import tty

CONFIG_FILE = 'devices.yaml'
DOCKER_IMAGE = 'microros/micro-ros-agent:humble'
running_containers = []

def load_devices(path):
    with open(path, 'r') as f:
        cfg = yaml.safe_load(f)
    return cfg.get('devices', [])

def start_agent_container(device):
    name = os.path.basename(device['name'])  # e.g., usb_rear_wheel
    container_name = f"microros_agent_{name}"
    domain_id = device.get('domain_id', 0)
    baud_rate = device.get('baud_rate', 115200)
    dev_path = device['name']

    cmd = [
        "docker", "run", "-d", "--rm",
        "--name", container_name,
        "--network", "host",
        "--device", dev_path,
        "--env", f"ROS_DOMAIN_ID={domain_id}",
        DOCKER_IMAGE,
        "serial", "--dev", dev_path, "-b", str(baud_rate)
    ]

    print(f"Launching container: {container_name}  (Domain: {domain_id})")
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    container_id = result.stdout.decode().strip()
    running_containers.append(container_name)

def stop_all_agents():
    print("\nStopping all micro-ROS agent containers...")
    for name in running_containers:
        subprocess.run(["docker", "stop", name])
    print("All agents stopped.")

def wait_for_quit():
    print("\nPress 'q' to quit.")
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)

    try:
        tty.setraw(fd)
        while True:
            ch = sys.stdin.read(1)
            if ch.lower() == 'q':
                break
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

def signal_handler(sig, frame):
    stop_all_agents()
    sys.exit(0)

def main():
    signal.signal(signal.SIGINT, signal_handler)  # Ctrl+C
    signal.signal(signal.SIGTERM, signal_handler) # kill

    devices = load_devices(CONFIG_FILE)
    for dev in devices:
        start_agent_container(dev)

    wait_for_quit()
    stop_all_agents()

if __name__ == "__main__":
    main()
