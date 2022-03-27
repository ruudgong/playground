#!/bin/bash

###
# Define constants
#####
curwd=$( pwd )
whohami=$( whoami )
shopt -s nullglob

###
# Functions
#####

format_combine() {
	v1=$1
	v3=$2
	name=$3

	echo "[INDEX]" > "$name"
	cat "$v1" >> "$name"
	echo "[INDEX]" >> "$name"
	cat "$v3" >> "$name"
}

combiner() {
	# Setting the v1 and v3 files to
	# the arguments passed from the script below
	###
	v1prl=$1
	v3prl=$2

	# Verify that the prl choices are good, or return
	###
	read -p "v1 $v1prl to be combined with v3 $v3prl correct? " ans
	case $ans in
		[Yy]* ) ;;
		* ) return 1;;
	esac

	echo && echo "Enter the new name for the combined PRL file"
	read -p "(This will automatically suffix .prl_hex): " newname
	newname="$newname.prl_hex"

	# Check if the file already exists, if it does, verify overwrite
	###
	if ( test -f "/ins/sms/conf/sspr_profiles/grp_id1/$newname" ); then
		read -p "$newname already exists in grp_id1 directory. Overwrite?: " ans
		case $ans in
			[Yy]* ) format_combine $v1prl $v3prl $newname;;
			* ) exit 1;;
		esac
	else
		format_combine $v1prl $v3prl $newname
	fi
}

###
# Tasks
#####

echo && echo "Pre-checks..." && echo

# Verify that pre-steps have been taken to make automation function
# Accept input from person running
###
read -p "Are the PRLs already in the correct dir (/ins/tools/create_prl)? " ans
case $ans in
	[Nn]* ) echo "Place the *.prl files in /ins/tools/create_prl" && exit 1;;
esac

# Verify we're working out of the proper directory
# If we're not, then let's switch it
###
if [ "$curwd" != '/ins/tools/create_prl' ]; then
	read -p "Must be running in the correct directory, switch now? " ans
	case $ans in
		[Yy]* ) cd /ins/tools/create_prl || exit 1;;
		[Nn]* ) exit;;
		* ) echo "Must be yes or no."; exit 1;;
	esac
fi
# Am I 'ins'?
# If not, I need to be
###
if [ "$whohami" != 'ins' ]; then
	echo "Must be running as 'ins' user."
	exit 1
fi

# Create standard full, and custom backup points
# Input received for custom, full is automatic
###
echo && echo "Creating backup points..." && echo
tar cvf "/var/tmp/sspr_full-`date +%Y-%m-%d`.tar" /ins/sms/conf/sspr_profiles/
hexlist=()
echo && echo && echo "Existing PRLs:"
for f in /ins/sms/conf/sspr_profiles/grp_id1/*hex; do
	hexlist+=($f)
	echo "$f"
done

read -p "How *MANY* existing PRLs will be modified?" i
backuplist=()
if [ $i -gt 0 ]; then
	while [ $i -gt 0 ]; do
		# Iterate through prls to show available
		x=0
		for f in ${hexlist[*]}; do
			echo "[$x]: $f"
			x=$((x+1))
		done
		read -p "Select PRL to backup: " ans
		read -p "Backup ${hexlist[ans]}?: " valid
		case $valid in
			[Yy]* ) backuplist+=(${hexlist[ans]});;
			* ) i=$((i+1));;
		esac
		i=$((i-1))
	done
	# Change directory to complete custom backups.
	# Failure of any parts will result in exit
	cd /ins/sms/conf/sspr_profiles/grp_id1 || exit 1
	tar cvf "/var/tmp/sspr-changes-`date +%Y-%m-%d`.tar" ${backuplist} || exit 1
	cd /ins/tools/create_prl || exit 1
fi

echo && echo "Starting..." && echo "Identify **Version 1 PRLs**:"
# Setting arrays
###
v1prls=()
v3prls=()

# Iterate through files in directory ending in .prl
# If they're found, ask if they're version 1 or 3
# If invalid input is received, then the file is skipped.
###
for f in *.prl; do
	read -p "Verify: Is $f a Version-1 or Version-3 PRL? [1 or 3]: " ans
	case $ans in
		[1]* ) v1prls+=($f);;
		[3]* ) v3prls+=($f);;
		* ) echo "Must answer 1 or 3, file SKIPPED";;
	esac
done

# For each entry in each v1 or v3 array, chown the file to ins:insgroup
# If it fails for any of them, exit
###
echo && echo "Updating ownership or PRLs..." && echo
for prl in ${v1prls[*]}; do
	sudo chown ins:insgroup $prl && echo "Updated $prl successfully" || exit 1
done
for prl in ${v3prls[*]}; do
	sudo chown ins:insgroup $prl && echo "Updated $prl successfully" || exit 1
done

# for each file in v1, create the post-hex name and
# display guidance for the runner
#
# Run the script, allowing them to do the input
# Move the file after it's been processed, in accordance with policy
###
echo && echo "Running bin to hex on v1 PRLs..."
for prl in ${v1prls[*]}; do
	prlNoExt=$prl"_hex"
	echo && echo "Running bin to hex for '$prl'"
	echo "Rename to: '$prlNoExt'"
	./prl_bin_to_hex.pl || echo "failed to run bin to hex"
	if ( test -f "$prlNoExt" ); then
		dest="/ins/sms/conf/sspr_profiles/grp_id1/$prlNoExt"
		if ( test -f "$dest" ); then
			echo "Archiving conflict file: $dest"
			mv "$dest" "/ins/sms/conf/sspr_profiles/archive/" || exit 1
		fi
		echo "Moving $prlNoExt to /ins/sms/conf/sspr_profiles/grp_id1"
		mv "$prlNoExt" /ins/sms/conf/sspr_profiles/grp_id1/ || exit 1
	else
		echo "File not found: $prlNoExt, file not moved to /ins/sms/conf/sspr_profiles/grp_id1"
	fi
done

# for each file in v3, create the post-hex name and
# display guidance for the runner
#
# Run the script REV3, allowing them to do the input
# Move the file after it's been processed, in accordance with policy
###
echo && echo "Running bin to hex on v3 PRLs..."
for prl in ${v3prls[*]}; do
	prlNoExt=$prl"_hex"
	echo && echo "Running bin to hex R3 for '$prl'"
	echo "Rename to: '$prlNoExt'"
	./prl_bin_to_hex_rev3.pl || echo "failed to run bin to hex v3"
	if ( test -f "$prlNoExt" ); then
		dest="/ins/sms/conf/sspr_profiles/grp_id1/$prlNoExt"
		if ( test -f "$dest" ); then
			echo "Archiving conflict file: $dest"
			mv "$dest" "/ins/sms/conf/sspr_profiles/archive/" || exit 1
		fi
		echo "Moving $prlNoExt to /ins/sms/conf/sspr_profiles/grp_id1"
		mv "$prlNoExt" /ins/sms/conf/sspr_profiles/grp_id1/ || exit 1
	else
		echo "File not found: $prlNoExt, file not moved to /ins/sms/conf/sspr_profiles/grp_id1"
	fi
done

# Change to the new working directory
# Exit if not ready to proceed
###
echo && echo "Changing to the /ins/sms/conf/sspr_profiles/grp_id1 directory..." && echo
read -p "Are you ready to continue?: " ans
case $ans in
	[Nn]* ) exit 1;;
	* ) cd /ins/sms/conf/sspr_profiles/grp_id1 || exit 1
esac

# Get the number of combined PRLs needed
# Display then take input for the ones to combine
###
echo && echo
read -p "How many combined PRLs do you need to create?: " i
if [ $i -gt 0 ]; then
	while [ $i -gt 0 ]; do
		echo && echo
		echo "PRLs in directory:"
		x=0
		filelist=()
		for f in *.prl_hex; do
			filelist+=($f)
			echo "[$x]: $f"
			x=$((x+1))
		done
		read -p "Which v1 file would you like to combine?: " ans1
		read -p "Which v3 file would you like to combine?: " ans3
		combiner ${filelist[ans1]} ${filelist[ans3]} && i=$((i-1)) || echo "selection backed out, try again"
	done
fi

# Check linked SSPRs, and report available
# Get input to select SSPRs to rebuild and remap
# Show final output
###
echo && echo "Checking currently mapped SSPR slots..." && echo
for f in SSPR.*; do
	echo $( stat "$f" | grep SSPR )
done

read -p "How many SSPR slots need to be replaced?" i
if [ $i -gt 0 ]; then
	while [ $i -gt 0 ]; do
		echo && echo
		ssprlist=()
		x=0
		# Iterate through the current SSPRs
		echo "Current slots:"
		for f in SSPR.*; do
			ssprlist+=($f)
			echo "[$x]: " $( stat "$f" | grep SSPR )
			x=$((x+1))
		done
		read -p "Select SSPR slot to replace: " ans
		echo && echo "Current PRL hex available: "
		prllist=()
		x=0
		# Iterate through the available PRL_HEX files
		for f in *.prl_hex; do
			prllist+=($f)
			echo "[$x]: $f"
			x=$((x+1))
		done
		read -p "Select PRL hex to replace it with: " ans2
		read -p "VALIDATE: Replace ${ssprlist[ans]} with ${prllist[ans2]}? " valid
		# If validated, remove the prior SSPR link and create a new symlink to the new prl_hex
		case $valid in
			[Yy]* ) rm -f ${ssprlist[ans]}; ln -sf /ins/sms/conf/sspr_profiles/grp_id1/${prllist[ans2]} ${ssprlist[ans]} && i=$((i-1)) || exit 1;;
			* ) ;;
		esac
	done
fi

echo "#########" && echo "############" && echo "#########"
echo "File handling complete" && echo

echo "At this time, you now need to take manual actions:"
echo "[1]: cd /ins/tools/create_prl/PRLDIR"
echo "[2]: stop_gateway dl 1"
echo "[3]: cd /ins/gateways/dl/scripts"
echo "[4]: ./dl_clean"
echo "[5]: exit"
echo "[6]: bash"
echo "[7]: cd /ins; stop_gateway cotr 1 && otaf_stop && stop_pgdb"
echo "[8]: start_pgdb && otaf_start && run_gateway cotr 1"
echo "[9]: /ins/gateways/dl/scripts/dl_start && run_gateway dl 1"
echo "Monitor: tail -f /ins/sms/otaf_result/OTAPA_RESULT_<date>.log | grep <MIN>"
echo "Push to a test device:"
echo "cd /ins; otap <MIN> <SSPR>"
