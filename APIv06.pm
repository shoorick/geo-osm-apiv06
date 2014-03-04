package APIv06;

use strict;
use utf8;
use LWP::UserAgent;

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

=item $uri = APIv06->new( $api_url, $user_agent, $your_email )

Constructs a new APIv06 object. Arguments may be omitted, default values are L<http://api06.dev.openstreetmap.org/api/0.6> (test URL) as API URL and package name joined with version number as User-Agent.

=back

=cut

sub new {
    my ( $class, $url, $agent, $from ) = @_;
    my $self  = {};
    $self->{'url'}   = $url   || 'http://api06.dev.openstreetmap.org/api/0.6'; # test
    $self->{'agent'} = $agent || 'perl-' . __PACKAGE__ . '/' . $VERSION;
    $self->{'from'}  = $from  || $ENV{'USER'} . '@example.com';
    $self->{'ua'}    = LWP::UserAgent->new(
        'agent' => $self->{'agent'},
        'from'  => $self->{'from'},
    );

    bless  $self, $class;
    return $self;
}

=head1 METHODS

=head2 get_object($type, $id)

Get object of given type (which can be C<'node'>, C<'way'> or C<'relation'>) and ID.
Return XML response or die.

=cut

sub get_object {
    my ( $self, $type, $id ) = @_;
    my $ua = $self->{'ua'};
    my $response = $ua->get($self->{'url'} . "/$type/$id");
    # TODO Check args

    if ($response->is_success) {
        return $response->decoded_content;
    }
    # else
        die $response->status_line;
}



1;

=head AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=cut

