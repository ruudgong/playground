#!/bin/bash

disable_user() { passwd -l $1; }

while read user; do
	disable_user $user
done < "$1"
