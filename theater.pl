#!/usr/bin/perl
use DatabaseMySQL ;
use MyLWP ;
use Encode ;
#use Smart::Comments ;
use Data::Dumper ;

use strict ;
use utf8 ;

&main(@ARGV) ;


sub main{
	my $db = new DatabaseMySQL('movie_expert','localhost','movie_expert','ntucsie') ;
	my $dbh = $db->getDbh ;

	my @array_area ;
	
	# foreach area
	my $results = $dbh->selectall_hashref('SELECT * FROM area_table', 'area_id');
	foreach my $id (keys %$results) {
		my $area_url = $results->{$id}->{area_url} ;

		# lwp url
		my $lwp = new MyLWP($area_url) ; 
		my $all = encode("utf8" , decode("big5" ,$lwp->getContent)) ;

		# parse all info
		my $aref_theaters = &parse_all_html(\$all) ;
		push @array_area , { id => $id , theaters => $aref_theaters } ;
	}

	# insert theaters
	&insert_theaters($dbh , \@array_area) ;


	print STDERR "Insert Finish\n" ;
}

sub insert_theaters{
	my $dbh = shift ;
	my $aref = shift ;

	foreach my $hash (@$aref){
		my $id = $hash->{'id'} ;
		my $aref_theaters = $hash->{'theaters'} ;

	
		# insert each theaters
		foreach (@$aref_theaters){
		
			my $sth = $dbh->prepare('SELECT count(*) as count FROM theater_list WHERE theater_addr='.$dbh->quote($_->{'addr'}) ) ;
			$sth->execute ;
			my $res = $sth->fetchrow_hashref ;

			
			if ($res->{'count'} == 0) {
	
				my $query = sprintf("INSERT INTO theater_list VALUES(%s,%s,%s,%d,%s,%s)" ,
						$dbh->quote('NULL') ,
						$dbh->quote('first') ,
						$dbh->quote($_->{'name'}) ,
						$id ,
						$dbh->quote($_->{'phone'}) ,
						$dbh->quote($_->{'addr'})
						) ;

				$dbh->do($query) ;
			}
		}
	}

}


sub parse_all_html{
	my $all = shift ;
	my $area_id = shift ;

# decide theater/movies
	my @array_all_theaters ;

	while( $$all =~ /<div class="h_area">(.*?)<\/div>/s ){
		$$all = $' ;
		my $theater_or_movie = $1 ;

# is theater
		if(!( $theater_or_movie =~ /\(/s)){
			my $s = encode("utf8" , "二輪") ;
			next if ($theater_or_movie =~ /$s/s);

# get remain
			if( $$all =~ /(.*?)(?=<div class="h_area">)/s ){

# get info
				my $aref_info = &parse_theater_info( $1 )	;		
				@array_all_theaters = (@array_all_theaters , @$aref_info) ;
			}
		}
	}

	return \@array_all_theaters ;
}


sub parse_theater_info{
	my $all = shift ;

	my @array ;
	while( $all =~ /<div class="only_text">(.*?)<!-- only_text end -->/s ){
		my $one = $1 ;
		$all = $' ;

		my %info ;
		if( $one =~ /<div class="col-1">(.*?)<\/div>/s ){
			$info{'name'} = $1 ;
		}

		if( $one =~ /<div class="col-2">(.*?)<\/div>/s ){
			$info{'phone'} = $1 ;
		}

		if( $one =~ /<div class="col-3">(.*?)<\/div>/s ){
			$info{'addr'} = $1 ;
		}

		$info{'name'} =~ s/<.*?>//sg ;
		$info{'name'} = &trim($info{'name'}) ;
		$info{'addr'} =~ s/<.*?>//sg ;
		$info{'addr'} =~ s/\(.*?\)//sg ;
		$info{'addr'} = &trim($info{'addr'}) ;

### %info
		push @array , \%info ;	
	}

	return \@array ;
}

sub trim($){
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
