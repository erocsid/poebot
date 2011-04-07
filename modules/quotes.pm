# module quotes for poebot (http://discore.org/poebot)
# $Id: quotes.pm 37 2009-11-13 05:20:22Z discore $
#
# has the following commands:
#   !quote - returns a random quote
#   !quote <new_quote> - adds a new quote
#   !unquote <quote_id> - removes a quote

package quotes;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(quotes_fetch quotes_add quotes_remove);
our %EXPORT_TAGS = (
	Main	=> [qw(quotes_fetch quotes_add quotes_remove)]
);

$::commands{'^!quote$'} = ["quotes", "quotes_fetch"];
$::commands{'^!quote\s(.+)'} = ["quotes", "quotes_add"];
$::commands{'^!unquote\s(\d+)'} = ["quotes", "quotes_remove"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;
my $table_prefix = $::table_prefix;

# !quote
sub quotes_fetch {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my $quote;
	my $query = db_mysql->dbh->selectrow_hashref("SELECT id, quote, timestamp FROM $table_prefix\_quotes ORDER BY RAND() LIMIT 1");
	if($query->{'id'} and $query->{'quote'} and $query->{'timestamp'}) {
		$quote = "[$query->{'id'}] $query->{'quote'} - $query->{'timestamp'}";
	}
	# this can happen if somehow one of the database columns is empty for the quote
	else {
		$quote = "error fetching quote, perhaps there are none";
	}

	global->poebotLogger("quotes: quotes_fetch returned a quote") if($verbose);
	return $quote;
}

# !quote <new_quote>
sub quotes_add {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($newquote) = $text =~ /$command_key/;

	db_mysql->dbh->do("INSERT INTO $table_prefix\_quotes (quote, timestamp) VALUES(".db_mysql->dbh->quote($newquote).", NOW())");
	my $output = "quote added";

	global->poebotLogger("quotes: quotes_add returned '$output'") if($verbose);
	return $output;
}

# !unquote <quote_id>
sub quotes_remove {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($quoteid) = $text =~ /$command_key/;

	my $output;
	my $query = db_mysql->dbh->selectrow_hashref("SELECT id FROM $table_prefix\_quotes WHERE id=".db_mysql->dbh->quote($quoteid));
	if($query->{'id'}) {
		db_mysql->dbh->do("DELETE FROM $table_prefix\_quotes WHERE id=".db_mysql->dbh->quote($quoteid));
		$output = "quote removed";
	}
	else {
		$output = "unknown quote id";
	}

	global->poebotLogger("quotes: quotes_remove returned '$output'") if($verbose);
	return $output;
}

1;
