package APIv06;

use strict;
use utf8;
use LWP::UserAgent 6.04;
use URI;
use XML::Simple qw(:strict);

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

Constructs a new APIv06 object.
Arguments may be omitted, default values are
L<http://api06.dev.openstreetmap.org/api/0.6> (test URL) as API URL
and package name joined with version number as User-Agent.

=back

=cut

sub new {
    my ( $class, $url, $agent, $from, $username, $password ) = @_;
    my $self  = {};
    $self->{'url'}
        = URI->new(
            $url
            || 'http://api06.dev.openstreetmap.org/api/0.6' # devel URL when not specified
        );
    $self->{'agent'} = $agent || 'perl-' . __PACKAGE__ . '/' . $VERSION;
    $self->{'from'}  = $from  || $ENV{'USER'} . '@example.com';
    $self->{'ua'}    = LWP::UserAgent->new(
        'agent' => $self->{'agent'},
        'from'  => $self->{'from'},
    );
    $self->{'ua'}->credentials(
        $self->{'url'}->host_port, 'Web Password',
        $username, $password
    );

    bless  $self, $class;
    return $self;
}

=head1 METHODS

=head2 get_object($type, $id)

Get object of given type (which can be C<'node'>, C<'way'> or C<'relation'>) and ID.
Return XML response or die.

=cut

sub get_object($$) {
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


=head2 create_changeset(tag => 'value', [tag => 'value'])

Create changeset with specified tag

=cut

sub create_changeset {
    my $self  = shift;
    
    my %tags
        = ref $_[0] eq 'HASH'
        ? %{ shift() } : @_;
    
    $tags{'created_by'} //= $self->{'agent'};
    
    # Convert
    # key => value
    # into
    # key => { v => value }
    foreach my $key ( keys %tags ) {
        $tags{$key} = { 'v' => $tags{$key} };
    }

    my $changeset_xml = XMLout(
        { 'osm' => { 'changeset' => \%tags } },
        'KeyAttr'    => { 'tag' => 'k' },
        'KeepRoot'   => 1,
    );

    my $ua = $self->{'ua'};
    my $response = $ua->put(
        $self->{'url'} . '/changeset/create',
        'Content' => $changeset_xml,
    );
    # TODO Check args

    if ($response->is_success) {
        return $response->decoded_content;
    }
    # else
        die $response->status_line;
        # TODO not die
}



=head2 close_changeset($id)

Close changeset

=cut


sub close_changeset($) {
    my ( $self, $id ) = @_;
    my $ua = $self->{'ua'};
    my $response = $ua->put($self->{'url'} . "/changeset/$id/close");
    # TODO Check args

    if ($response->is_success) {
        return $response->decoded_content;
    }
    # else
        die $response->status_line;
        # TODO not die
}


1;

=head AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=cut

