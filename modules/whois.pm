# whois module for poebot (http://discore.org/poebot)
# $Id: whois.pm 37 2009-11-13 05:20:22Z discore $
#
# !whois <domain>
# checks .com, .net, and .org availability for the domain
# works pretty well but occasionally doesn't know how to read the whois output

package whois;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(whois_results);
our %EXPORT_TAGS = (
	Main	=> [qw(whois_results)]
);

use Net::Whois::Raw qw(whois);

$::commands{'^!whois\s(.+)'} = ["whois", "whois_results"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# !whois <query>
sub whois_results {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($domain) = $text =~ /$command_key/;

	# ie !whois google vs. !whois google.com
	if($domain !~ /.+\..+/) {
		$domain .= ".com";
	}

	# more tlds could be added but i have no motivation to do it
	if($domain !~ /(com|net|org)$/) {
		return "invalid tld, only .com, .net, and .org are searchable";
	}

	my $results;
	my @tlds_to_check = qw(com net org);
	my ($next_domain, $domain_tld) = split(/\./, $domain);

	$next_domain .= ".";
	foreach my $tld (@tlds_to_check) {
		$next_domain .= $tld;
		my $whois_raw = whois($next_domain);

		# possibly more options than "no match" and "not found" here
		if($whois_raw =~ /no\smatch/i or $whois_raw =~ /not\sfound/i) {
			$results .= "$next_domain is available, ";
		}
		else {
			# try to find expiration date
			if($whois_raw =~ /(expir.+-.+-\d+)/i) {
				my $expiration = $1;
				$expiration =~ s/^\s*//;
				$expiration =~ s/\s*\.$//;
				$expiration =~ s/\.//g;
				$results .= "$next_domain is taken ($expiration), ";
			} else {
				$results .= "$next_domain is taken (expiration unknown), ";
			}
		}
		$next_domain =~ s/\..+$/./;
	}

	$results = substr($results, 0, -2);

	global->poebotLogger("whois: whois_results returned '$results'") if($verbose);
	return $results;
}

1;
