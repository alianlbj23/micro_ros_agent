#!/usr/bin/env python3
import serial
import time
import logging

# 設置日誌格式
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)

# 串口設備名稱
DEVICES = ["/dev/usb_rear_wheel", "/dev/usb_front_wheel"]


def reset_esp32(device):
    """嘗試對 ESP32 進行 DTR 重置"""
    try:
        with serial.Serial(device) as ser:
            logging.info(f"Opened {device}")

            ser.dtr = False
            time.sleep(0.1)

            ser.dtr = True
            time.sleep(1)

            logging.info(f"ESP32 reset complete on {device}!")

    except serial.SerialException as e:
        logging.error(f"Failed to open {device}: {e}")
    except Exception as e:
        logging.error(f"Unexpected error with {device}: {e}")


if __name__ == "__main__":
    for dev in DEVICES:
        reset_esp32(dev)
