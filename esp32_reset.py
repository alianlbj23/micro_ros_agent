#!/usr/bin/env python3
import serial
import time

# 串口設備名稱
device = "/dev/usb_rear_wheel"
device2 = "/dev/usb_front_wheel"

try:
    ser = serial.Serial(device)
    print(f"Opened {device}")

    ser.dtr = False
    time.sleep(0.1)

    ser.dtr = True
    time.sleep(1)

    print("ESP32 reset complete!")
    ser.close()

    ser = serial.Serial(device2)
    print(f"Opened {device2}")

    ser.dtr = False
    time.sleep(0.1)

    ser.dtr = True
    time.sleep(1)

    print("ESP32_2 reset complete!")
    ser.close()

except Exception as e:
    print(f"Error: {e}")
