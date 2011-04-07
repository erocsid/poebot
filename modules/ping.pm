# module ping for poebot (http://discore.org/poebot)
# $Id: ping.pm 41 2010-05-12 19:31:09Z discore $
#
# command: !ping
# returns: "pong"
#
# mainly used as an example module

# define the name of the package
package ping;

use strict;
use warnings;

# set up as a typical module
require Exporter;
our @ISA = qw(Exporter);

# list of functions that can be exported
our @EXPORT_OK = qw(ping_pong);

# list of functions that are actually exported
# ../modules_loaded would load this module like: use modules::ping qw(:Main);
our %EXPORT_TAGS = (
	Main	=> [qw(ping_pong)]
);

# register as a command
# this has the following format:
#
# $main::commands{'regular_expression'} = ["module_name", "function_name"];
#
# regular_expression: the regexp to use to catch the command
# module_name: the name of the module the command uses
# function_name: the function within module_name that you want to execute for this command

$::commands{'^!ping$'} = ["ping", "ping_pong"];

# here's an alias
$::commands{'^!pingplease$'} = $::commands{'^!ping$'};

# i always set these even if they aren't always used
my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# the function that executes for this command
sub ping_pong {
	global->poebotLogger("ping: ping_pong returned a pong") if($verbose);
	return "pong";
}

1;
