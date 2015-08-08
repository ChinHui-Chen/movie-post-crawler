package DatabaseMySQL ;

use DBI ;
use strict ;
use utf8 ;

sub new {
    my ($class , $db , $ip , $user , $password ) = @_;
 
	my $dbh = DBI->connect("DBI:mysql:$db;host=$ip", 
							$user, $password, { RaiseError => 1 }
			);
	$dbh->do("set names utf8") ;

	
    my $self = {
		_db => $db ,
		_ip => $ip ,
		_user => $user ,
		_password => $password ,
		_dbh => $dbh 
    };
	

    bless $self, $class;

    return $self;
}


sub getDbh{
	my ($self) = @_ ;
	
	return $self->{'_dbh'} ;
}
1;
