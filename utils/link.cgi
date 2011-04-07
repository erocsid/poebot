#!/usr/bin/perl -w
# $Id$

use strict;
use CGI::Pretty;
use CGI::Carp('fatalsToBrowser');
my $cgi = new CGI;

print $cgi->header();
print $cgi->start_html(
	-title	=> 'link.cgi',
);
if($cgi->param('url')) {
	my $url = $cgi->param('url');
	if($url !~ /^http:\/\//) {
		$url = "http://$url";
	}
	print $cgi->p($cgi->a({-href=>$url}, $url));
}

print $cgi->start_form({-name=>"link", -method=>"GET", -action=>"link.cgi"}) .
$cgi->textfield({-name=>"url", -size=>"30", -maxlength=>"1000"}) .
$cgi->submit({-name=>"link", -value=>"Link me"}) .
$cgi->end_form();

print $cgi->end_html();
