#!/bin/bash

sudo ./usb-downloader -t slsiap -b bl1-usbboot.bin -a 0xffff0000 -j 0xffff0000
sleep 1
sudo ./usb-downloader -t slsiap -f fip-loader-usb.img -m
