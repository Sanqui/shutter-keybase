#! /usr/bin/env perl
###################################################
#
#  Copyright (C) 2016 Sanqui <gsanky@gmail.com>
#
#  This file is part of Shutter.
#
#  Shutter is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Shutter is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Shutter; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################
 
package Keybase;
 
use lib $ENV{'SHUTTER_ROOT'}.'/share/shutter/resources/modules';
 
use utf8;
use strict;
use POSIX qw/setlocale/;
use Locale::gettext;
use Glib qw/TRUE FALSE/;
use Data::Dumper;
use File::Copy;
use File::Basename;
 
use Shutter::Upload::Shared;
our @ISA = qw(Shutter::Upload::Shared);
 
my $d = Locale::gettext->domain("shutter-plugins");
$d->dir( $ENV{'SHUTTER_INTL'} );
 
my %upload_plugin_info = (
    'module'                        => "Keybase",
    'url'                           => "https://keybase.pub/",
    'registration'                  => "https://keybase.io/",
    'name'                          => "Keybase KBFS",
    'description'                   => "Put screenshots in the Keybase filesystem",
    'supports_anonymous_upload'     => FALSE,
    'supports_authorized_upload'    => TRUE,
    'supports_oauth_upload'         => FALSE,
);
 
binmode( STDOUT, ":utf8" );
if ( exists $upload_plugin_info{$ARGV[ 0 ]} ) {
    print $upload_plugin_info{$ARGV[ 0 ]};
    exit;
}
 
 
#don't touch this
sub new {
    my $class = shift;
 
    #call constructor of super class (host, debug_cparam, shutter_root, gettext_object, main_gtk_window, ua)
    my $self = $class->SUPER::new( shift, shift, shift, shift, shift, shift );
 
    bless $self, $class;
    return $self;
}
 
sub init {
    my $self = shift;
 
     
    return TRUE;    
}
 
sub upload {
    my ( $self, $upload_filename, $username, $password ) = @_;
 
    #store as object vars
    $self->{_filename} = $upload_filename;
    $self->{_username} = $username;
    $self->{_password} = $password;
 
    utf8::encode $upload_filename;
    utf8::encode $password;
    utf8::encode $username;
 
    if ( $username eq "" || $username eq "Guest" ) {
        die("Please enter your Keybase username and any password (it will not be used)");
    }
     
    #upload the file
    eval {
        
        my($filename, $dirs, $suffix) = fileparse($upload_filename);
        
        copy($upload_filename, "/keybase/public/".$username."/screenshots/".$filename);
         
        $self->{_links}->{'direct_link'} = 'https://'.$username.'.keybase.pub/screenshots/'.$filename;
        $self->{_links}->{'signed_link'} = 'https://keybase.pub/'.$username.'/screenshots/'.$filename;
        
        #set success code (200)
        $self->{_links}{'status'} = 200;
         
    };
    if($@){
        $self->{_links}{'status'} = $@;
    }
     
    return %{ $self->{_links} };
}
 
 
 
1;
