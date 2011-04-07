# dictionary package for poebot (http://discore.org/poebot)
# $Id: dictionary.pm 37 2009-11-13 05:20:22Z discore $
#
# !define <word> - tries to define the word
package dictionary;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(define_fetch);
our %EXPORT_TAGS = (
	Main	=> [qw(define_fetch)]
);

$::commands{'^!define\s(.+)'} = ["dictionary", "define_fetch"];
$::commands{'^!dict\s(.+)'} = $::commands{'^!define\s(.+)'};

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# you must specify where your WordNet database files are, /usr/share/wordnet in Debian
my $wordnet_data = "/usr/share/wordnet";
warn("wordnet data can't be read!") if(!-r $wordnet_data);
use WordNet::QueryData;
my $wn = WordNet::QueryData->new($wordnet_data);

# !define <word>
sub define_fetch {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($word) = $text =~ /$command_key/;

	my @output;

	my ($nouns, $verbs, $adjectives) = (0, 0, 0);
	my @word_types = $wn->querySense($word, "glos");
	foreach my $type (@word_types) {
		my @definitions = $wn->querySense($type, "glos");
		foreach my $definition (@definitions) {
			if($type =~ /#n/) {
				$nouns++;
			}
			elsif($type =~ /#v/) {
				$verbs++;
			}
			elsif($type =~ /#a/) {
				$adjectives++;
			}
			if($definition =~ /1$/) {
				foreach my $define ($wn->querySense($definition, "glos")) {
					push(@output, "$definition: $define");
				}
			}
		}
	}

	if(@output) {
		my $plural = "";
		my $word_info;
		if($nouns) {
			$plural = "s" if($nouns > 1);
			$word_info .= "$nouns noun definition$plural, ";
		}
		if($verbs) {
			$plural = "s" if($verbs > 1);
			$word_info .= "$verbs verb definition$plural, ";
		}
		if($adjectives) {
			$plural = "s" if($adjectives > 1);
			$word_info .= "$adjectives adjectives definition$plural, ";
		}
		$word_info = substr($word_info, 0, -2);
		unshift(@output, "$word has $word_info");
		if($nouns + $verbs + $adjectives > 1) {
			push(@output, "more defintions of $word: " . tinyurl_create->poebotCreatetinyurl("http://wordnetweb.princeton.edu/perl/webwn?s=$word"));
		}
	}
	else {
		push(@output, "no definitions found for: $word");
		push(@output, "maybe this will help: " . tinyurl_create->poebotCreatetinyurl("http://www.google.com/search?hl=en&q=define%3A+$word"));
	}
		
	global->poebotLogger("dictionary: define_fetch returned $#output lines") if($verbose);
	return @output;
}

1;
