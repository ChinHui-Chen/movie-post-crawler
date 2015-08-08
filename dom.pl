#!/usr/bin/perl
use HTML::DOM;
do "lib.pl" ;
use Data::Dumper ;

my $dom_tree = new HTML::DOM;
$dom_tree->parse_file('html');



#print Dumper( $dom_tree->getElementsByClassName('col-1') );

print $dom_tree->lastModified ;
