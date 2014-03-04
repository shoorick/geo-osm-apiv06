package APIv06;

use strict;
use utf8;

our $VERSION = 0.01;

=head1 NAME

Geo::OSM::APIv06 - access to OpenStreetMap via API v. 0.6

=head1 SYNOPSIS

 my $api = APIv06->new();

=head1 CONSTRUCTORS

The following methods construct new C<APIv06> objects:

=over 4

=item $api = APIv06->new( )

=item $api = APIv06->new( $api_url )

=item $uri = APIv06->new( $api_url, $user_agent )

Constructs a new APIv06 object. Arguments may be omitted, default values are L<http://api06.dev.openstreetmap.org/api/0.6> (test URL) as API URL and package name joined with version number as User-Agent.

=back

=cut

sub new {
    my ( $class, $url, $ua ) = @_;
    my $self  = {};
    $self->{'url'} = $url || 'http://api06.dev.openstreetmap.org/api/0.6'; # test
    $self->{'ua'}  = $ua  || __PACKAGE__ . '-' . $VERSION;

    bless  $self, $class;
    return $self;
}

1;

=head AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=cut

