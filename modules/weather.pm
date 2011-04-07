# weather package for poebot (http://discore.org/poebot)
# $Id: weather.pm 37 2009-11-13 05:20:22Z discore $
#
# !weather <place> - returns the weather
package weather;

use strict;

# see http://www.weather.com/services/xmloap.html
# for information on obtaining a free partner_id and license for using weather.com
my $partner_id = "";
my $license = "";

# this has to be writable by the bot and is required
my $cache = "./modules/weathercache";

if(!-w $cache) {
	warn "weather module cache not writable, this is bad and causes crashes!\n";
}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(weather_fetch);
our %EXPORT_KEYS = (
	Main	=> [qw(weather_fetch)]
);

# note: this module is broken in Debian/etch and probably other older packages
# see CPAN bug reports for the module to get a very easy fix
use Weather::Com::Simple;

$::commands{'^!weather\s(.+)'} = ["weather", "weather_fetch"];

my $verbose = $::verbose;
my $extra_verbose = $::extra_verbose;

# !weather <place>
sub weather_fetch {
	shift(@_);
	my ($command_key, $nick, $channel, $text) = @_;

	my ($place) = $text =~ /$command_key/;


	# setup Weather::Com
	my %params = (
		'partner_id'	=> $partner_id,
		'license'		=> $license,
		'cache'			=> $cache,
		'place'			=> $place 
	);
	my $weather_finder = Weather::Com::Simple->new(%params);
	my $weather = $weather_finder->get_weather();

	my $output;
	if($weather->[0]) {
		$output = "$weather->[0]->{'place'}: $weather->[0]->{'fahrenheit'}F ($weather->[0]->{'celsius'}C), $weather->[0]->{'conditions'}, Wind: $weather->[0]->{'wind'}, $weather->[0]->{'humidity'}% humidity, Updated: $weather->[0]->{'updated'}";
	}
	else {
		$output = "no weather found";
	}

	global->poebotLogger("weather: weather_fetch returned '$output'") if($verbose);
	return $output;
}

1;
