# db_mysql module for poebot (http://discore.org/poebot)
# $Id: db_mysql.pm 37 2009-11-13 05:20:22Z discore $
#
# returns database handles for use in other modules

package db_mysql;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(dbh);
our %EXPORT_TAGS = (
	Main	=> [qw(dbh)]
);

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

use DBI;
my $dbh;

my $db_info = "dbi:mysql:$::config{'mysql_db'};";
if($::config{'mysql_use_tcp'}) {
	$db_info .= "host=$::config{'mysql_host'}";
}
else {
	$db_info .= "socket=$::config{'mysql_socket'}";
}


# returns a mysql database handle
sub dbh {
	# try one reconnect if $dbh seems broken
	$dbh = DBI->connect($db_info, $::config{'mysql_user'}, $::config{'mysql_pass'})
		unless($dbh and $dbh->do("SELECT 1"));

	global->poebotLogger("db_mysql: dbh returned a database handle") if($extra_verbose);
	return $dbh;
}

1;
