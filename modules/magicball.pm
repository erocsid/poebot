# magicball module for poebot (http://discore.org/poebot)
# $Id: magicball.pm 37 2009-11-13 05:20:22Z discore $
#
# answers questions using mysterious forces that dwell beyond the realms of humanity
# !8ball <question>
# if the question starts with a "where", a location is returned
# if the question starts with a "when", a time is returned
# otherwise, it is considered to be a yes/no question

package magicball;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(magicball_answer);
our %EXPORT_TAGS = (
	Main	=> [qw(magicball_answer)]
);

$::commands{'^!8ball\s(.+)'} = ["magicball", "magicball_answer"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# there should be an even amount of yes and no answers
my @answers_yesno = (
	"Signs point to yes.",
	"Yes.",
	"Without a doubt.",
	"As I see it, yes.",
	"You may rely on it.",
	"It is decidedly so.",
	"Yes - definitely.",
	"It is certain.",
	"Most likely.",
	"Yes, in due time.",
	"Looks good to me!",
	"Looking good!",
	"Probably.",
	"Go for it!",
	"Sure why not, you know I'm a robot right?",
	"Absolutely yes!",
	"Prospect looks hopeful.",
	"I like to think so.",
	"Yes, yes, yes, and yes again.",
	"Most likely.",
	"All signs point to yes.",
	"As I see it, yes.",
	"It is certain.",
	"Yes, definitely.",
	"Most likely.",
	"Outlook good.",
	"You may rely on it.",
	"Signs point to yes.",
	"Without a doubt.",
	"YES FOR THE LOVE OF GOD YES",
	"My sources say no.",
	"Outlook not so good.",
	"Very doubtful.",
	"My reply is no.",
	"Don't count on it.",
	"My sources say no.",
	"Definitely not.",
	"I have my doubts.",
	"Are you kidding?",
	"Don't bet on it.",
	"Forget about it.",
	"Fuck no.",
	"Prospect looks bleak.",
	"Not even on a GOOD day.",
	"You wish.",
	"Not bloody likely.",
	"No way.",
	"Never.",
	"Over my dead body.",
	"It is decidedly so.",
	"Don't count on it.",
	"It is doubtful.",
	"Outlook not so good.",
	"My reply is no.",
	"My sources say no.",
	"Fuck off and die (that's a No)",
	"Absolutely, positively, without-a-doubt, indubidubly, profoundly, inarguably, obviously no.",
	"Not a snowball's chance in hell.",
	"NEIN",
	"n.",
	"Better not tell you now.",
	"Ask again later.",
	"You will have to wait.",
	"Outlook so so.",
	"Who knows?",
	"That's a question you should ask yourself.",
	"It would take a disturbed person to even ask.",
	"Maybe -- give me more money and ask again.",
	"I'm busy.",
	"I wouldn't know anything about that.",
	"That question is better remained unanswered.",
	"We won't go there.",
	"Better not tell you now.",
	"Fuck off.",
	"I will kill you.",
	"Headfuck the socket.",
	"I'm sorry Dave, I can't let you do that.",
	"Unmatched right curly bracket at line 10, at end of line",
	"\"I prefer not to,\" he replied in a flute-like tone. It seemed to me that while I had been addressing him, he carefully revolved every statement that I made; fully comprehended the meaning; could not gainsay the irresistible conclusion; but, at the same time, some paramount consideration prevailed with him to reply as he did.",
);

my @answers_where = (
	"In bed.",
	"Outside.",
	"Inside.",
	"In Minnesota.",
	"In New York.",
	"In Seattle.",
	"In Salt Lake.",
	"In Sydney, Australia.",
	"At home.",
	"At work.",
	"Under the bed.",
	"In the street.",
	"In your friend's car.",
	"In the back seat of a car.",
	"In a doorway.",
	"At your box.",
	"In Middle Earth.",
	"At the Jiffy Lube.",
	"In a chair.",
	"At the dinner table.",
	"In the refrigerator.",
	"At your friend's house.",
	"Sitting on the lap of someone you love.",
	"At Disneyworld.",
	"At McDonald's.",
	"In the restroom.",
	"In the bathtub.",
	"In the shower.",
	"Behind closed doors.",
	"In a prison cell.",
	"In a drug rehab.",
);

my @answers_when = (
	"Tomorrow at 6:00pm.",
	"In an hour.",
	"In ten minutes.",
	"In less than 2 hours.",
	"It won't happen unless you act now.",
	"In three days.",
	"3, 2, 1... bling bling.",
	"Today.",
	"Now.",
	"Tonight.",
	"Three days before the second full moon after your next birthday.",
	"Next week.",
	"In the next year.",
	"Never.",
	"Tomorrow afternoon.",
	"Next month.",
	"In January.",
	"In February.",
	"In March.",
	"In April.",
	"In May.",
	"In June.",
	"In July.",
	"In August.",
	"In September.",
	"In October.",
	"In November.",
	"In December.",
	"Summertime.",
	"Wintertime.",
	"Springtime.",
	"Autumn.",
	"Right... NOW!",
);

# !8ball <question>
sub magicball_answer {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($question) = $text =~ /$command_key/;

	my $reply;
	if($question =~ /^\s*when/i) {
		$reply = $answers_when[rand($#answers_when)];
	}
	elsif($question =~ /^\s*where/i) {
		$reply = $answers_where[rand($#answers_where)];
	}
	else {
		$reply = $answers_yesno[rand($#answers_yesno)];
	}

	global->poebotLogger("magicball: magicball_answer returned '$reply'") if($verbose);
	return $reply;
}

1;
