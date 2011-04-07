# module tinyurl_auto for poebot (http://discore.org/poebot)
# $Id: tinyurl_auto.pm 37 2009-11-13 05:20:22Z discore $
#
# automatically creates tinyurls for every url seen in irc

package tinyurl_auto;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(tinyurl_return);
our %EXPORT_TAGS = (
	Main	=> [qw(tinyurl_return)]
);

$::commands{'http://(\S+\.\S+)|https://(\S+\.\S+)'} = ["tinyurl_auto", "tinyurl_return"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# tinyurl generation
sub tinyurl_return {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	# skip lines that have urls in them but are meant for other bot commands
	foreach my $key (%::commands) {
		if($text =~ /$key/) {
			return 0 if($::commands{$key}[0] ne "tinyurl_auto");
		}
	}

	# don't tinyurl tinyurls!
	if($text =~ /http:\/\/tinyurl.com/ or $text =~ /http:\/\/www.tinyurl.com/) {
		return 0;
	}

	my ($longurl) = $text =~ /$command_key/;

	# use a helper module to create them since other modules want tinyurls as well
	my $tinyurl = tinyurl_create->poebotCreatetinyurl($longurl);

	global->poebotLogger("tinyurl_auto: tinyurl_return returned '$tinyurl'") if($verbose);
	return $tinyurl;
}

1;
