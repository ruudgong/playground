#!/usr/bin/perl -w
##===============================================================================
##
##          FILE: cryptpass.pl 
##
##         USAGE: ./cryptpass.pl
##
##   DESCRIPTION:This script generates an encrypted password string for a given plaintext and salt                  
##       OPTIONS: No option is required                             
##				                                                     
##  REQUIREMENTS: ---
##          BUGS: ---
##         NOTES: ---
##		 Author: Tom Peterson <tpeterso@cme.com>
##       UPDATED: Smart Nwachukwu <smart.nwachukwu@gmail.com>
##  ORGANIZATION: 
##       CREATED:  
##      REVISION: $Revision: 1.2 $
##
##
##===============================================================================

use strict;
use File::Basename;
use Crypt::PasswdMD5;

my @valid_salt_chars = ( 'a'..'z', 'A'..'Z', '0'..'9', '.', '/' );

my $salt;
my $plaintext;

if (@ARGV == 2)
{
   $plaintext = $ARGV[0];
   $salt = $ARGV[1];
   local $" = '';
   die "invalid salt.\n" if($salt !~ /^[@valid_salt_chars]{2}$/); } elsif (@ARGV == 1) {
   $plaintext = $ARGV[0];
   $salt = @valid_salt_chars[rand(@valid_salt_chars)] .
           @valid_salt_chars[rand(@valid_salt_chars)];
}
else
{
   die "usage: ", basename($0), " plaintext [ salt ]\n"; }

print crypt($plaintext, $salt) . ":" . unix_md5_crypt($plaintext, $salt) . "\n";

__END__

=head1 NAME

cryptpass - a utility to create encrypted password strings suitable for use in the shadow file.

=head1 SYNOPSIS

cryptpass password [ salt ]

=head1 DESCRIPTION

cryptpass will generate an encrypted password string for a given plaintext and salt. If the salt is omited, a random one will be used.

Beware that the password that you specify on the command line will be visible in a ps listing. If secrecy of the password is at all important, cryptpass.secure should be used instead.
     
=head1 BUGS

Bugs? We don't write no stinking bugs!

Please report anything odd to the author.

=cut

