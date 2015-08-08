package MyLWP ;

use LWP ;
use strict ;

sub new{
	my ($class,$url) = @_ ;

	my $self = {
		url => $url
	} ;

	bless $self , $class ;
	
	return $self ;
}


sub getContent{
	my ($self) = @_ ;
	my $url = $self->{'url'} ;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(10) ;
	$ua->env_proxy ;
	
	my $response = $ua->get( $url );


	my $all ;
	if ($response->is_success) {
		$all = $response->content;  # or whatever
	}
	else {
		die $response->status_line;
	}

	return $all ;
}

sub getUrl{
	my ($self) = @_ ;

	return $self->{'url'} ;
}

1; 
