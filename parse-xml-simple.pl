#!/usr/bin/perl -w
use strict;
use XML::Simple qw(:strict);
use Data::Dumper;

my $node = XMLin(
    'node-adzhatar.osm',
    'KeyAttr'    => { 'tag' => 'k' },
    'ForceArray' => 1,
    'KeepRoot'   => 1,
);

#print Dumper($node);

my $xml = XMLout(
    $node,
    'KeyAttr'    => { 'tag' => 'k' },
    'KeepRoot'   => 1,
);
print $xml;