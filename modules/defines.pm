# defines module for poebot (http://discore.org/poebot)
# $Id: defines.pm 37 2009-11-13 05:20:22Z discore $
#
# has the following commands:
#   ?? <term> - returns the definition if known
#   !learn <term> <definition> - sets a new term
#   !relearn <term> <definition> - updates a term
#   !forget <term> - removes a term
#   !whoset <term> - returns who set the term and when
#   !search <query> - searches the database for <query>

package defines;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(defines_fetch defines_set defines_update defines_remove defines_whoset defines_checkterm defines_search);
our %EXPORT_TAGS = (
	Main	=> [qw(defines_fetch defines_set defines_update defines_remove defines_whoset defines_checkterm defines_search)]
);

$::commands{'^\?\?\s(\S+)$'} = ["defines", "defines_fetch"];
$::commands{'^!learn\s(\S+)\s(.+)'} = ["defines", "defines_set"];
$::commands{'^!relearn\s(\S+)\s(.+)'} = ["defines", "defines_update"];
$::commands{'^!forget\s(\S+)$'} = ["defines", "defines_remove"];
$::commands{'^!whoset\s(\S+)$'} = ["defines", "defines_whoset"];
$::commands{'^!search\s(.+)'} = ["defines", "defines_search"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;
my $table_prefix = $::table_prefix;

# ?? <term>
sub defines_fetch {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($term) = $text =~ /$command_key/;

	my $define;
	if(defines_checkterm($term)) {
		my $query = db_mysql->dbh->selectrow_hashref("SELECT definition FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));
		$define = $term . ": " . $query->{'definition'};
	}
	else {
		$define = "$term is not defined";
	}

	global->poebotLogger("defines: defines_fetch returned '$define'") if($verbose);
	return $define;
}

# !learn <term> <definition>
sub defines_set {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($newterm, $newdefinition) = $text =~ /$command_key/;

	my $output;
	if(defines_checkterm($newterm)) {
		$output = "$newterm is already defined";
	}
	else {
		db_mysql->dbh->do("INSERT INTO $table_prefix\_defines (term, definition, whoset, timestamp) VALUES(".db_mysql->dbh->quote($newterm).", ".db_mysql->dbh->quote($newdefinition).", ".db_mysql->dbh->quote($nick).", NOW())");
		$output = "$newterm defined";
	}

	global->poebotLogger("defines: defines_set returned '$output'") if($verbose);
	return $output;
}

# !relearn <term> <definition>
sub defines_update {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($term, $newdefinition) = $text =~ /$command_key/;

	my $output;
	if(defines_checkterm($term)) {
		db_mysql->dbh->do("UPDATE $table_prefix\_defines SET definition=".db_mysql->dbh->quote($newdefinition).", whoset=".db_mysql->dbh->quote($nick).", timestamp=NOW() WHERE term=".db_mysql->dbh->quote($term));
		$output = "$term updated";
	}
	else {
		$output = "$term is not defined";
	}

	global->poebotLogger("defines: defines_update returned '$output'") if($verbose);
	return $output;
}

# !forget <term>
sub defines_remove {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($term) = $text =~ /$command_key/;

	my $output;
	if(defines_checkterm($term)) {
		db_mysql->dbh->do("DELETE FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));
		$output = "$term removed";
	}
	else {
		$output = "$term is not defined";
	}

	global->poebotLogger("defines: defines_remove returned '$output'") if($verbose);
	return $output;
}

# !whoset <term>
sub defines_whoset {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($term) = $text =~ /$command_key/;

	my $whoset;
	if(defines_checkterm($term)) {
		my $query = db_mysql->dbh->selectrow_hashref("SELECT whoset, timestamp FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));
		$whoset = "$term set by $query->{'whoset'} on $query->{'timestamp'}";
	}
	else {
		$whoset = "$term is not defined";
	}

	global->poebotLogger("defines: defines_whoset returned '$whoset'") if($verbose);
	return $whoset;
}

# !search <query>
sub defines_search {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($search) = $text =~ /$command_key/;

	my $query = db_mysql->dbh->prepare("SELECT term FROM $table_prefix\_defines WHERE term REGEXP ".db_mysql->dbh->quote($search)." OR definition REGEXP ".db_mysql->dbh->quote($search)." ORDER BY term");
	$query->execute();
	my @results;
	while(my $row = $query->fetchrow_hashref()) {
		push(@results, $row->{'term'});
	}
	$query->finish();

	my $result_count = 0;
	$result_count = $#results + 1 if(@results);

	# raw list of results, comma delimited
	my $results_raw;
	if(@results) {
		foreach my $result (@results) {
			$results_raw .= "$result, ";
		}
		$results_raw = substr($results_raw, 0, -2);
	}

	# too many results, greater than 4 full lines of irc (or about 1700 chars)
	if(@results and length($results_raw) > 1700) {
		undef(@results);
		$results[0] = "too many matches found ($result_count total), be more specific";
	}
	# one result
	elsif(@results and $result_count == 1) {
		my $term = $results[0];
		my $query = db_mysql->dbh->selectrow_hashref("SELECT definition FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));
		undef(@results);
		$results[0] = "(one result) $term: " . $query->{'definition'};
	}
	# more than one result
	elsif(@results and $result_count > 1) {
		# only 1 line worth of results
		if(length($results_raw) <= 450) {
			my $result_list;
			foreach my $result (@results) {
				$result_list .= "$result, ";
			}
			$result_list = substr($result_list, 0, -2);
			undef(@results);
			$results[0] = "$result_count terms found: $result_list";
		}
		# up to about 4 lines of results
		else {
			my @result_lines;
			my $results_line = "$result_count terms found: ";
			# prepare lines for irc 400 characters at a time until out of results
			for(my $i=0; $i<=$#results; $i++) {
				$results_line .= "$results[$i], ";
				if(length($results_line) >= 400 or $i == $#results) {
					$results_line = substr($results_line, 0, -2);
					push(@result_lines, $results_line);
					$results_line = "";
				}
			}
			@results = @result_lines;
		}
	}
	# no matches
	else {
		undef(@results);
		$results[0] = "no matches found";
	}

	global->poebotLogger("defines: defines_search found $result_count results");

	return @results;
}

# checks to see if a term exists
sub defines_checkterm {
	my ($term) = @_;

	my $query = db_mysql->dbh->selectrow_hashref("SELECT term FROM $table_prefix\_defines WHERE term=".db_mysql->dbh->quote($term));

	global->poebotLogger("defines: defines_checkterm checked term '$term'") if($verbose);

	if($query->{'term'}) {
		return 1;
	}
	else {
		return 0;
	}
}

1;
