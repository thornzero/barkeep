#!/bin/bash
/**
 * @author Daniel Thornburg
 * @date: 2024-12-01
 * @file: setup.sh
 * @desc:
 */
# installation script for the barkeep app
# TODO: write this script in bash

# copy the service file
cp barkeep.service /etc/systemd/system/barkeep.service

# enable the service
systemctl enable barkeep.service

# start the service
systemctl start barkeep.service

# check the service status
systemctl status barkeep.service

# check the service logs
journalctl -u barkeep.service
