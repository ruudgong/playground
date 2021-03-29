#!/bin/bash

user_exists() { id "$1" &>/dev/null; }

print_if_not_exists() {
	if !  user_exists $1 ; then
		echo "User: $1 not found"
	fi
}


while read user; do
	print_if_not_exists $user
done < "$1"
