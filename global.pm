# $Id: global.pm 36 2009-11-13 05:12:33Z discore $
package global;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(poebotCheckinput poebotOutout poebotLogger);
our %EXPORT_TAGS = (
	Main	=> [qw(poebotCheckinput poebotOutout poebotLogger)]
);

my $verbose = $main::verbose;
my $extra_verbose = $main::extra_verbose;

# checks lines of irc for input
sub poebotCheckinput {
	shift(@_);
	my ($nick, $channel, $what) = @_;

	my @output;

	foreach my $key (keys(%::commands)) {
		my $package = $::commands{$key}[0];
		my $function = $::commands{$key}[1];
		if($what =~ /$key/) {
			@output = $package->$function($key, $nick, $channel, $what);
			if(@output and $output[0]) {
				last;
			}
			else {
				undef(@output);
			}
		}
	}

	poebotOutput(\$channel, \@output) if(@output);

	return;
}

sub poebotOutput {
	my($channel, $output) = @_;

	foreach my $line (@{$output}) {
		$::irc->yield(privmsg=>$$channel=>$line);
	}

	return;
}

sub poebotLogger {
	shift(@_);
	my ($entry) = @_;

	print "[" . localtime() . "]: $entry\n";

	return;
}

1;
