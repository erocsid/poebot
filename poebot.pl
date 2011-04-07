#!/usr/bin/perl -w
# $Id: poebot.pl 38 2009-11-16 05:57:35Z discore $

use strict;

use global qw(:Main);

# read settings, set some commonly used variables
our %config = do("Poebot.config");

our $verbose = $config{'verbose'};
our $extra_verbose = $config{'extra_verbose'};
our $table_prefix = $config{'mysql_prefix'};

# all of our loaded commands
our %commands;

# load custom modules
do("modules_loaded");

# look for module errors
warn($@) if($@);

# write pid file
my $pidfile = "./.$config{'nickname'}.pid";
if(-e "$pidfile") {
	unlink($pidfile);
}
open(FH, ">$pidfile");
print FH "$$\n";
close(FH);

use POE qw(Component::IRC);

# We create a new PoCo-IRC object
our $irc = POE::Component::IRC->spawn( 
	nick => $config{'nickname'},
	ircname => $config{'ircname'},
	server => $config{'server'},
) or die "Failed to create a new PoCo-IRC object: $!";

POE::Session->create(
	package_states => [
		main => [ qw(_default _start irc_001 irc_public irc_msg) ],
	],
	heap => { irc => $irc },
);

$poe_kernel->run();

sub _start {
	my $heap = $_[HEAP];

	# retrieve our component's object from the heap where we stashed it
	my $irc = $heap->{irc};

	$irc->yield( register => 'all' );
	$irc->yield( connect => { } );
	return;
}

sub irc_001 {
	my $sender = $_[SENDER];

	# Since this is an irc_* event, we can get the component's object by
	# accessing the heap of the sender. Then we register and connect to the
	# specified server.
	my $irc = $sender->get_heap();

	# we join our channels
	$irc->yield( join => $_ ) for @{$config{'channels'}};
	return;
}

sub irc_public {
	my ($sender, $who, $where, $what) = @_[SENDER, ARG0 .. ARG2];
	my $nick = ( split /!/, $who )[0];
	my $channel = $where->[0];

	global->poebotCheckinput($nick, $channel, $what);

	return;
}

sub irc_msg {
	my ($sender, $who, $where, $text) = @_[SENDER, ARG0 .. ARG2];
	my $nick = (split /!/, $who)[0];

	# check the text for commands
	global->poebotCheckinput($nick, $nick, $text);

	return;
}

# We registered for all events, this will produce some debug info.
sub _default {
	my ($event, $args) = @_[ARG0 .. $#_];
	my @output = ( "$event: " );

	for my $arg (@$args) {
		if ( ref $arg eq 'ARRAY' ) {
			push( @output, '[' . join(', ', @$arg ) . ']' );
		}
		else {
			push ( @output, "'$arg'" );
		}
	}
	global->poebotLogger(join ' ', @output) if($extra_verbose);
	return 0;
}
