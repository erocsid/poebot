# link module for poebot (http://discore.org/poebot)
# $Id: link.pm 37 2009-11-13 05:20:22Z discore $
#
# when used in conjunction with link.cgi (found in the utils directory), creates right-clickable links
# !link <url>

package link;

use strict;
use warnings;

# you can use this one if you want
my $link_cgi = "http://discore.org/link.cgi";

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(link_url);
our %EXPORT_TAGS = (
	Main	=> [qw(link_url)]
);

$::commands{'^!link\s(.+)'} = ["link", "link_url"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# !link <url>
sub link_url {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($url) = $text =~ /$command_key/;

	my $link_url = "$link_cgi?url=$url";
	my $tinyurl = tinyurl_create->poebotCreatetinyurl($link_url);

	global->poebotLogger("link: link_url returned '$tinyurl'") if($verbose);
	return $tinyurl;
}

1;
