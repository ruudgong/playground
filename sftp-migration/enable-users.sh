#!/bin/bash

enable_user() { passwd -u $1; }

while read user; do
	enable_user $user
done < "$1"
