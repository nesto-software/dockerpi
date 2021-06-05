#!/bin/bash

# you need to install sshpass first, for arch e.g.: yay sshpass
sshpass -praspberry ssh pi@localhost -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -p 5022