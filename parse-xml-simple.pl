#!/usr/bin/perl -w
use strict;
use utf8;
use XML::Simple qw(:strict);
use Data::Dumper;


sub transliterate {
    my %subs = (
        'de' => sub {
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
            y[АБВГДЕЗИЙКЛМНОПРСТУФЦЫЭабвгдезийклмнопрстуфцыэ]
             [ABWGDESIJKLMNOPRSTUFZYEabwgdesijklmnoprstufzye];
            return $_;
        },
        'en' => sub {
            local $_ = shift;
            s/Е/Ye/g;
            s/Ё/Yo/g;
            s/Ж/Zh/g;
            s/Х/Kh/g;
            s/Ц/Ts/g;
            s/Ч/Ch/g;
            s/Ш/Sh/g;
            s/Щ/Shch/g;
            s/Ю/Yu/g;
            s/Я/Ya/g;
            s/е/ye/g;
            s/ё/yo/g;
            s/ж/zh/g;
            s/х/kh/g;
            s/ц/ts/g;
            s/ч/ch/g;
            s/ш/sh/g;
            s/щ/shch/g;
            s/ю/yu/g;
            s/я/ya/g;
            s/[ъь]//g;
            y[АБВГДЕЗИЙКЛМНОПРСТУФЫЭабвгдезийклмнопрстуфыэ]
             [ABVGDEZIYKLMNOPRSTUFYEabvgdeziyklmnoprstufye];
            return $_;
        },
        'fr' => sub {
            local $_ = shift;
            s/А[ий]/Aï/g;
            s/Е[ий]/Ieï/g;
            s/Э[ий]/Eï/g;
            s/О[ий]/Oï/g;
            s/Е/Ie/g;
            s/Ё/Io/g;
            s/Ж/J/g;
            s/У/Ou/g;
            s/Х/Kh/g;
            s/Ц/Ts/g;
            s/Ч/Tch/g;
            s/Ш/Ch/g;
            s/Щ/Chtch/g;
            s/Ю/Iu/g;
            s/Я/Ia/g;
            s/а[ий]/aï/g;
            s/е[ий]/ieï/g;
            s/э[ий]/eï/g;
            s/о[ий]/oï/g;
            s/е/ie/g;
            s/ё/io/g;
            s/ж/j/g;
            s/у/ou/g;
            s/х/kh/g;
            s/ц/ts/g;
            s/ч/tch/g;
            s/ш/ch/g;
            s/щ/chtch/g;
            s/ю/iu/g;
            s/я/ia/g;
            s/[ъь]//g;
            y[АБВГДЗИЙКЛМНОПРСТФЫЭабвгдзийклмнопрстфыэ]
             [ABVGDZIYKLMNOPRSTFYEabvgdziyklmnoprstfye];
            return $_;
        },
        'ru' => sub {
            return shift; # do nothing
        },
    );
    
    my ( $what, $how ) = @_;
    return $subs{$how}($what);
    
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
                #if $tags->{'name'}->{'v'} =~ /[\x400-\x4FF]/; # name contains cyrillic
            foreach my $language ( qw( de en fr ru ) ) {
                $tags->{"name:$language"}->{'v'} //= transliterate($tags->{'name'}->{'v'}, $language);
            }
            $tags->{"int_name"}->{'v'} //= $tags->{'name:en'}->{'v'};
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