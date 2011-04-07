# lwp_useragent module for poebot (http://discore.org/poebot)
# $Id: lwp_useragent.pm 37 2009-11-13 05:20:22Z discore $
#
# returns an LWP::UserAgent handle to various modiles

package lwp_useragent;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(ua);
our %EXPORT_TAGS = (
	Main	=> [qw(ua)]
);

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

use LWP::UserAgent;

my $ua;
sub ua {
	if(!$ua) {
		$ua = LWP::UserAgent->new();
	}

	global->poebotLogger("lwp_useragent: ua returned a UserAgent handle") if($verbose);
	return $ua;
}

1;
