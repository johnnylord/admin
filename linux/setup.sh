#!/bin/bash

if [ $USER != 'root' ]; then
    echo "Please execute this script with sudo command"
    exit 1
fi

apt-get update
apt-get install build-essential kmod linux-headers-`uname -r`
