# tinyurl_create module for poebot (http://discore.org/poebot)
# $Id: tinyurl_create.pm 37 2009-11-13 05:20:22Z discore $
#
# returns tinyurls
package tinyurl_create;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(poebotCreatetinyurl);
our %EXPORT_TAGS = (
	Main	=> [qw(poebotCreatetinyurl)]
);

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# create tinyurl
sub poebotCreatetinyurl {
	shift(@_);
	my ($longurl) = @_;

	my $tinyurl;
	# there may be a better way to do this but this way has been working for many years
	my $res = lwp_useragent->ua->post("http://tinyurl.com/create.php", {url=>"$longurl"});
	if($res->is_success()) {
		$res->content =~ /<b>(http:\/\/tinyurl.com\/\S+)<\/b>/;
		$tinyurl = $1;
	}
	else {
		$tinyurl = "(can't connect to tinyurl.com)";
	}

	global->poebotLogger("tinyurl_create: poebotCreatetinyurl created '$tinyurl'") if($verbose);
	return $tinyurl;
}

1;
