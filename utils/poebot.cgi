#!/usr/bin/perl -w
# web interface for poebot (http://discore.org/poebot)
# $Id: poebot.cgi 39 2009-11-16 05:58:54Z discore $
# 
# edit the neccesary variables and put it into a directory with ExecCGI
# totally standalone, does not require any libraries from the bot itself

use strict;


################################################################################
# you may need to edit this
my $script_name = "poebot.cgi";
# and this
my %config = do("/full/path/to/Poebot.config");
################################################################################


use CGI::Pretty;
use CGI::Carp('fatalsToBrowser');
my $cgi = new CGI;

use DBI;

my $db_info = "dbi:mysql:$config{'mysql_db'};";
if($config{'mysql_use_tcp'}) {
	$db_info .= "host=$config{'mysql_host'}";
}
else {
	$db_info .= "socket=$config{'mysql_socket'}";
}

my $dbh = DBI->connect($db_info, $config{'mysql_user'}, $config{'mysql_pass'}) or die("Unable to connect to MySQL");

print $cgi->header();
print $cgi->start_html(
	-title	=> 'poebot web interface',
	-style	=> {-src=>'poebot.css'} # totally editable
);

print $cgi->div({-style=>"text-align: center"}, $cgi->h1({-class=>"header"}, $cgi->a({-href=>"$script_name"}, "$config{'nickname'} web interface")));

# search form
print $cgi->div({-style=>"text-align: center"},
	$cgi->start_form({-name=>"search", -method=>"GET", -action=>$script_name}) .
	"Search: " . $cgi->textfield({-name=>"query", -size=>"30", -maxlength=>"250"}) . $cgi->br() .
	$cgi->radio_group({-name=>"searching", -values=>["terms", "definitions", "both"], -default=>"both"}) . $cgi->br() .
	$cgi->submit({-class=>"submit", -name=>"search", -value=>"Search"}) .
	$cgi->end_form()
);

# handle searching
my $search = "";
if($cgi->param('search') and $cgi->param('query') and $cgi->param('searching')) {
	if($cgi->param('searching') eq "terms") {
		$search = "WHERE term LIKE(".$dbh->quote("%".$cgi->param('query')."%").")";
	}
	elsif($cgi->param('searching') eq "definitions") {
		$search = "WHERE definition LIKE(".$dbh->quote("%".$cgi->param('query')."%").")";
	}
	else {
		$search = "WHERE term LIKE(".$dbh->quote("%".$cgi->param('query')."%").") OR definition LIKE(".$dbh->quote("%".$cgi->param('query')."%").")";
	}
}

# handle multiple pages
my $perpage = "50";
my $start = 0;
if($cgi->param('start')) {
	$start = $cgi->param('start');
}

print $cgi->p("&nbsp;");

# start results table
my $results = $cgi->Tr(
	$cgi->th("term") .
	$cgi->th("definition") .
	$cgi->th({-style=>"width: 200px"}, "set by") .
	$cgi->th({-style=>"width: 175px"}, "date")
);

# populate results table
my $query = $dbh->prepare("SELECT * FROM $config{'mysql_prefix'}\_defines $search ORDER BY term LIMIT $start,$perpage");
$query->execute();
while(my $row = $query->fetchrow_hashref()) {
	$results .= $cgi->Tr(
		$cgi->td(fix_html($row->{'term'})) .
		$cgi->td(fix_html($row->{'definition'})) .
		$cgi->td({-style=>"text-align: center"}, fix_html($row->{'whoset'})) .
		$cgi->td({-style=>"text-align: center"}, fix_html($row->{'timestamp'}))
	);
}
$query->finish();

# print results table
print $cgi->start_table() . $results . $cgi->end_table();

# multiple page links goddamn it's ugly but it works well!
$query = $dbh->selectrow_hashref("SELECT COUNT(*) AS count FROM $config{'mysql_prefix'}\_defines $search");
my $total_results = $query->{'count'};
if($total_results > $perpage) {
	my $total_pages = $total_results / $perpage;
	# round up
	if($total_pages != int($total_pages)) {
		$total_pages = int($total_pages + 1);
	}
	my $current_page = (int($start / $perpage)) + 1;

	# get args ready for links
	my %args = $cgi->Vars();
	my $args = "";
	foreach my $arg (keys(%args)) {
		$args .= "&$arg=$args{$arg}";
	}
	$args =~ s/&start=\d*//;

	my $pagelinks;
	for(my $i=1; $i<=$total_pages; $i++) {
		if($i == $current_page) {
			$pagelinks .= "$i ";
		}
		else {
			my $new_start = ($i-1) * $perpage;
			$pagelinks .= $cgi->a({-href=>"$script_name?$args&start=$new_start"}, $i);
		}
	}

	print $cgi->div({-style=>"text-align: center"}, $cgi->p("Total Results: $total_results" . $cgi->br() . "Page: $pagelinks"));
}
else {
	print $cgi->div({-style=>"text-align: center"}, $cgi->p("Total Results: $total_results"));
}

print $cgi->end_html();

# tricky users thwarted
sub fix_html {
	my ($string) = @_;

	$string =~ s/</&lt;/g;
	$string =~ s/>/&gt;/g;

	return $string;
}
