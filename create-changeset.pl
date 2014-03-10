#!/usr/bin/perl -wl
use strict;

use APIv06;

my $api = APIv06->new(undef, undef, 'as@shoorick.ru'); # test

my $changeset_id
    = $api->create_changeset( 'comment' => 'Just a test' )
    or die "Could not open changeset";

print "Changeset $changeset_id opened";

my $response = $api->close_changeset($changeset_id);

print "Done with response $response";
