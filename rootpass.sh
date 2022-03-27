#!/bin/bash
#===============================================================================
#
#          FILE: rootpass.sh
#
#         USAGE: ./rootpass.sh
#
#       OPTIONS: 
#   DESCRIPTION:This script will accept a single server (presumably for
#               testing), a text list (CR delimited), or LDAP search for OES servers
#               to reset root password on multiple servers in your network.
#               You need the Crypt-PasswdMD5-1.3 for Perl for this script to work.
#               As of this date you can download it here...
#               http://search.cpan.org/~luismunoz/Crypt-PasswdMD5-1.3/PasswdMD5.p
#
#               Stuff you'll need to modify for your environement...
#               Get the package listed above.
#               Change the variables below.
#               CNFILTER=A CN search filter for Linux servers.
#               LDAPBASE=Where to start looking for Linux servers.
#               You'll need to put this script and cryptpass in /opt/rootpass.
#               Modify the SED statement about 75% of the way down this script.
#               Anonymous browsing of your LDAP server is required otherwise
#               you'll need to modify the ldapsearch statement below.                 
#				                                                     
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#		 Author: Bryan Green <bryan.green@cme.com>
#       UPDATED: Smart Nwachukwu, smart.nwachukwu@gmail.com
#  ORGANIZATION: 
#       CREATED: 04/24/2016 
#      REVISION: 
#
#
#===============================================================================


LDAPHOST='ldapnds.merc.chicago.cme.com'
CNFILTER='slx*'
LDAPBASE='o=merc'

clear
echo "*********************************************************"
echo ""
echo "WARNING, this script is used for changing root passwords"
echo ""
echo "You should be running this script as root and your shell"
echo "connected via a secure (SSH) or local connection."
echo ""
echo "*********************************************************"
echo "Do you want to continue? [y|n]"
read blah

case $blah in
Y*|y*)
	echo ""
	echo "Please enter the new password:"
	read "newpass"
	echo ""
	if [ -x /opt/rootpass/cryptpass ];then
	HASH=`/opt/rootpass/cryptpass $newpass`
	HASHRHLX='$1$82gUYyNV$VWb5dxPAOqMFo9ZMWqFEW1'
	HASHRHLX=`echo "$HASH" | cut -f2 -d ":"`
	HASHLINUX=`echo "$HASHRHLX" | perl -p -e 's#\\$#\\\\\\$#g'`
	else 
	echo "Cannot find cryptpass"
	exit 1
	fi
	echo "Here's the whole hash, $newpass -> $HASH"
	echo "Linux MD5 is $HASHRHLX"
	echo "Please verify this is the correct password because this is the hash I got. [y|n]"
	read bettergoback

	case $bettergoback in
	Y*|y*)
		echo ""
		echo "Are you changing individual hosts, a list of hosts, or a directory search?"
		echo "[H for host | L for list | D for directory]"
		read hostorenv

		case $hostorenv in
		H|h)
			clear
			echo "Please enter the hostname or hostnames you want to change."
			read machine

			echo ""
			echo "Last Chance Saloon! Are you sure you want to continue? [y|n]"
       		        read lastchancesaloon

                	case $lastchancesaloon in
                	Y*|y*)
                		for i in $machine
                		do
                		ping -c2 $i > /dev/null 2>&1
				if [ $? -eq 0 ];then
				echo "Connecting to" $i "..."                                
				echo "Please enter the current"
                                ssh $i "perl -p -i.bk -e  's#^root:.*?:#root:$HASHLINUX:#' /etc/shadow"
                		fi
				done
				echo "All done changing your one host.  Have a nice day!"				
			;;
			*)
                	echo "No changes made, exiting!"
                	exit 0
                	;;
                	esac
		;;
		L|l)
			clear
			echo "Please enter the full path to the file name containing only names"
			read machine

			echo ""
			echo "Last Chance Saloon! Are you sure you want to continue? [y|n]"
       		        read lastchancesaloon

                	case $lastchancesaloon in
                	Y*|y*)
                		for i in `cat $machine`
                		do
                		ping -c2 $i > /dev/null 2>&1
				if [ $? -eq 0 ];then
                                echo "Connecting to" $i "..."
				echo "Please enter the current"
                                ssh $i "perl -p -i.bk -e  's#^root:.*?:#root:$HASHLINUX:#' /etc/shadow"
                                fi
                                done
				echo "All done with your list.  Have a nice day!"
               		;;
                	*)
                	echo "No changes made, exiting!"
                	exit 0
                	;;
                	esac
		;;
                D|d)
			clear			
                        echo "This option will seach LDAP for Linux hosts where cn=$CNFILTER"
			echo "and create a file for you to set root passwords."
			echo "Last Chance Saloon!  Are you sure you want to continue? [y|n]"
                        read lastchancesaloon

                        case $lastchancesaloon in
                        Y*|y*)
				echo "Doing the LDAP search for servers where cn=$CNFILTER..."
				/usr/ldaptools/bin/ldapsearch -b $LDAPBASE -s sub -h $LDAPHOST -p 389 -x -LLL "(&(cn=$CNFILTER)(objectClass=ncpServer))" dn > ./lxservers.ldif
				echo "Fixing up the file to strip unwanted LDIF syntax..."
				sed -e 's/dn: cn=//g' -e '/^$/d' -e 's/,ou=CHICAGO,o=MERC//g' -e 's/,ou=ANX,o=MERC//g' -e 's/,ou=RDC,o=MERC//g' ./lxservers.ldif > ./lxservers.txt
				echo "Here we go..."
                                for i in `cat lxservers.txt`
                                do
                                	ping -c2 $i > /dev/null 2>&1
                                	if [ $? -eq 0 ];then
                                		echo "Connecting to" $i "..."
						echo "Please enter the current"
                                		ssh $i "perl -p -i.bk -e  's#^root:.*?:#root:$HASHLINUX:#' /etc/shadow"
						if [ $? -eq 0 ];then
							echo "Successfully changed" $i
						fi
						echo ""
                                	fi
                                done
				echo "All done with the dynamically generated list.  Have a nice day!"
                        ;;
                        *)
                        echo "No changes made, exiting!"
                        exit 0
                        ;;
                        esac
		;;
		*)
		echo "You entered no Evironment or hostname, exiting."
		exit 0
		;;
		esac
	;;
	*)
	echo "You didn't like something so I'll exit."
	exit 0
	;;
	esac
;;
*)
echo "OK wrong script, exiting!"
exit 0
;;
esac
