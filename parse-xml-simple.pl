#!/usr/bin/perl -w
use strict;
use utf8;
use XML::Simple qw(:strict);
use Data::Dumper;


sub transliterate_to_german {
    local $_ = shift;
    s/Е/Je/g;
    s/Ё/Jo/g;
    s/Ж/Sch/g;
    s/Х/Ch/g;
    s/Ч/Tsch/g;
    s/Ш/Sch/g;
    s/Щ/Schtsch/g;
    s/Ю/Ju/g;
    s/Я/Ja/g;
    s/е/je/g;
    s/ё/jo/g;
    s/ж/sch/g;
    s/х/ch/g;
    s/ч/tsch/g;
    s/ш/sch/g;
    s/щ/schtsch/g;
    s/ю/ju/g;
    s/я/ja/g;
    s/[ъь]//g;
    y/АБВГДЕЗИЙКЛМНОПРСТУФЦЫЭ/ABWGDESIJKLMNOPRSTUFZYE/;
    y/абвгдезийклмнопрстуфцыэ/abwgdesijklmnoprstufzye/;
    
    return $_;
}


my $structure = XMLin(
    'node-adzhatar.osm',
    'KeyAttr'    => { 'tag' => 'k' },
    'ForceArray' => 1,
    'KeepRoot'   => 1,
);

#print Dumper($structure);

foreach my $osm ( @{ $structure->{'osm'} } ) {
    foreach my $node ( @{ $osm->{'node'} } ) {
        my $tags = $node->{'tag'};
        
        # Check existence and copy if possible
        if ( $tags->{'name'} ) {
            $tags->{'name:ru'}->{'v'} //= $tags->{'name'}->{'v'};
                #if $tags{'name'}->{'v'} =~ /[\x400-x4FF]/; # name contains cyrillic
            $tags->{'name:de'}->{'v'} //= transliterate_to_german($tags->{'name'}->{'v'});
            print "name:ru = ", $tags->{'name:ru'}->{'v'};
            print "name:de = ", $tags->{'name:ru'}->{'v'};
        }
        
    }
}

# my %tags = $structure->{osm}->[0]->{node}->[0]->{tag};
#p join ' ', keys %tags
#p join ' ', keys $structure->{'osm'}->[0]->{'node'}->[0]->{'tag'}


my $xml = XMLout(
    $structure,
    'KeyAttr'    => { 'tag' => 'k' },
    'KeepRoot'   => 1,
);
print $xml;