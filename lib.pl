use LWP ;
use strict ;

sub lwp{
	my $url = shift ;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;

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

1; 
