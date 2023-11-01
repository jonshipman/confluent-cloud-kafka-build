#!/bin/bash

echo "$1"
echo $'\nPress any key to continue...\n'
if read -n 1 -s -r; then :; fi
