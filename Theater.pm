package Theater ;

sub new{
	my ($class) = @_;
 
    my $self = {
        _name => undef,
        _addr => undef,
		_phone => undef ,
		_lat  => undef,
		_lng => undef ;

    };

    bless $self, $class;

    return $self;
}



1;
