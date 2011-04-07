# google module for poebot (http://discore.org/poebot)
# $Id: google.pm 37 2009-11-13 05:20:22Z discore $
#
# has the following commands:
#   !google <query> - returns the first result
#   !map <query> - searches google maps, can be used with to: keyword to get directions

package google;

use strict;
use warnings;

# this allows us to use defined terms (from defines.pm) as aliases for !map
# ie: !learn home 1234 fake street
# !map term:home to 555 main street
my $use_defined_aliases = 1;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(google_lucky google_map);
our %EXPORT_TAGS = (
	Main	=> [qw(google_lucky google_map)]
);

$::commands{'^!google\s(.+)'} = ["google", "google_lucky"];
$::commands{'^!map\s(.+)'} = ["google", "google_map"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;
my $table_prefix = $::table_prefix;

use JSON;
my $json = JSON->new();

# for stuff like &#39; from google results
use HTML::Entities;

# !google <query>
sub google_lucky {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($query) = $text =~ /$command_key/;

	# query ajax
	my $response = lwp_useragent->ua->get("http://ajax.googleapis.com/ajax/services/search/web?q=$query&v=1.0");
	my @results;
	if($response->is_success()) {
		# convert to perl friendly data
		my $json_data = $json->decode($response->content());
		my $title = $json_data->{'responseData'}{'results'}[0]{'titleNoFormatting'};
		my $url = $json_data->{'responseData'}{'results'}[0]{'url'};
		my $content = $json_data->{'responseData'}{'results'}[0]{'content'};
		if($url) {
			# remove content oddities
			$title = fix_google_content($title);
			$content = fix_google_content($content);
			push(@results, "$url - $title: $content");
			push(@results, tinyurl_create->poebotCreatetinyurl($url));
		}
		else {
			push(@results, "no results found");
		}
	}
	else {
		@results = ["can't connect to ajax.googleapis.com"];
	}

	global->poebotLogger("google: google_lucky returned '" . join(" ", @results) . "'") if($verbose);
	return @results;
}

# !map <query>
sub google_map {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($query) = $text =~ /$command_key/;

	my @output;
	# check to see if a term:alias is being used
	if($use_defined_aliases) {
		# part of the query is an alias
		# use 'while' because maybe: !map term:point_a to term:point_b
		while($query =~ /term:(\S+)/) {
			my $term = $1;
			my $db_query = db_mysql->dbh->selectrow_hashref("SELECT definition FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));
			if($db_query->{'definition'}) {
				$query =~ s/term:\S+/$db_query->{'definition'}/;
			}
			else {
				$query =~ s/term:\S+/$term/;
				push(@output, "(warning: $term is unknown)");
			}
		}
	}

	push(@output, tinyurl_create->poebotCreatetinyurl("http://maps.google.com/?q=$query"));

	global->poebotLogger("google: google_map returned '" . join(" ", @output) . "'") if($verbose);
	return @output;
}

# takes care of various html/web related things that come back from google and we don't care about for irc use
sub fix_google_content {
	my $content = shift(@_);

	$content =~ s/<.+?>//g;
	$content =~ s/\s+/ /g;
	$content = decode_entities($content);

	return $content;
}

1;
