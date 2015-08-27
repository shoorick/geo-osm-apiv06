#!/usr/bin/perl -w
use strict;
use utf8;

my $VERSION = 0.01;

=head1 NAME

transliterate.pl - Transliterate names in OpenStreetMap data

=head1 DESCRIPTION

Read Russian names from C<name> and C<name:ru> tags and then store them to C<name:en> and C<int_name>.

=head1 SYNOPSIS

  ./transliterate.pl [options]

=head1 OPTIONS

=over 4

=item B<-a>, B<--api> url

Override API URL. Default value is http://api.openstreetmap.org/api/0.6

=item B<-t>, B<--test>

Use test API URL http://api06.dev.openstreetmap.org/api/0.6

=item B<-b>, B<--bbox>, B<--bounds> coordinates

Set bounds to C<coordinates> left,bottom,right,top. Values can be separated by comma or space.

=item B<-f>, B<--filter> key[=value], B<--filter> value

Process subset instead of full dataset.

=item B<-u>, B<--username> username

Username for OpenStreetMap.

=item B<-p>, B<--password> [password]

Password for OpenStreetMap. Password will be asked when not specified.

=item B<-?>, B<-h>, B<--help>,

Print a brief help message and exit.

=item B<-m>, B<--man>, B<--manual>

Prints the manual page and exit.

=item B<-v>, B<--verbose>

Be verbose.

=back

=head1 SEE ALSO

L<http://wiki.openstreetmap.org/wiki/API_v0.6>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Alexander Sapozhnikov
E<lt>shoorick@cpan.orgE<gt> L<http://shoorick.ru>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl programming language system itself.

See L<http://dev.perl.org/licenses/> for more information.

=cut

use Data::Dumper;
use Getopt::Long;
use LWP::UserAgent;
use XML::Parser;
use open qw( :std :utf8 );

use FindBin;
use lib $FindBin::Bin;

use APIv06;

my (@bounds, $need_help, $need_manual, $verbose);
our $filter;

my      $api_url = 'http://api.openstreetmap.org/api/0.6';
my $test_api_url = 'http://api06.dev.openstreetmap.org/api/0.6';

GetOptions(
	'bbox|bounds=s{1,4}' => \@bounds,
    'filter=s'  => \$filter,

    'api=s'     => \$api_url,
    'test'      => sub { $api_url = $test_api_url },

    'help|?'    => \$need_help,
    'manual'    => \$need_manual,
    'verbose'   => \$verbose,
    'quiet'     => sub { $verbose = 0 },
);

use Pod::Usage qw( pod2usage );
pod2usage(1)
    if $need_help;
pod2usage('verbose' => 2)
    if $need_manual;


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
            # https://fr.wikipedia.org/wiki/Transcription_du_russe_en_fran%C3%A7ais
            local $_ = shift;
            s/А[ий]/Aï/g;
            s/Е[ий]/Ieï/g;
            s/Г([еёиюя])/Gu$1/g;
            s/Э[ий]/Eï/g;
            s/О[ий]/Oï/g;
            s/([АЕЁИОУЫЭЮЯ])я/$1ïa/g;
            s/\bЕ/Ie/g;
            s/Ё/Io/g;
            s/([иы])н$/$1ne/g;
            s/Ж/J/g;
            s/([АЕЁИОУЫЭЮЯ])с([аеёиоуыэюя])/$1ss$2/g;
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
            s/([аеёиоуыэюя])я/$1ïa/g;
            s/е/ie/g;
            s/ё/io/g;
            s/ж/j/g;
            s/ий\b/i/g;
            s/([аеёиоуыэюя])с([аеёиоуыэюя])/$1ss$2/g;
            s/у/ou/g;
            s/х/kh/g;
            s/ц/ts/g;
            s/ч/tch/g;
            s/ш/ch/g;
            s/щ/chtch/g;
            s/ый\b/y/g;
            s/ю/iu/g;
            s/я/ia/g;
            s/[ъь]//g;
            y[АБВГДЕЗИЙКЛМНОПРСТФЫЭабвгдезийклмнопрстфыэ]
             [ABVGDEZIIKLMNOPRSTFYEabvgdeziiklmnoprstfye];
            return $_;
        },
        'ru' => sub {
            return shift; # do nothing
        },
    );

    my ( $what, $how ) = @_;
    return $subs{$how}($what);

} # sub transliterate


our $state  = 0; # initial
our $tags   = {};
our $object = {};

# Function is called whenever an XML tag is started
sub start_event {
    my ($expat, $name, %attr) = @_;

    if ( $name =~ /^node|way|relation$/ ) {
        $state++;
        $object = {%attr};
        return;
    }
    # else
    $tags->{ $attr{'k'} } = $attr{'v'}
        if $state && $name eq 'tag';

} # sub start_event

# Function is called whenever an XML tag is ended
sub end_event {
    my ($expat, $name) = @_;
    my $found = 1;

    if ( $name =~ /^node|way|relation$/ ) {

       FILTER:
        if ( $filter ) {
            $found = 0;
            while ( my ($k, $v) = each %$object ) {
                if ( "$k=$v" =~ /$filter/ ) {
                    $found = 1;
                    #last FILTER;
                    # Exiting subroutine via last at ./transliterate.pl line 257.
                    # Label not found for "last FILTER" at ./transliterate.pl line 257.
                }
            }
        }

        # Check existence and copy if possible
        if ( $tags->{'name'} ) {
                #if $tags->{'name'}->{'v'} =~ /[\x400-\x4FF]/; # name contains cyrillic
            foreach my $language ( qw( de en fr ru ) ) {
                $tags->{"name:$language"} //= transliterate($tags->{'name'}, $language);
            }
            $tags->{'int_name'} //= $tags->{'name:en'};
        }

        # Store changes
        my $names = {};
        while ( my ($k, $v) = each %$tags ) {
            $names->{ $k } = $v if $k =~ /name/;
            
            if ( !$found && "$k=$v" =~ /$filter/ ) {
                $found = 1;
            }
        } # while
        
        if ( $found && scalar %$names ) {
            print "\n$name: ", join(' / ', %$object), "\n";
            while ( my ($k, $v) = each %$names ) {
                print "\t$k = $v\n";
            };
        }

        # Return to initial state
        $state--;
        $object = {};
        $tags   = {};
    }
} # sub end_event



###################
#
# Workflow

my $api = APIv06->new($api_url);
my $map = $api->get_map(@bounds);

my $parser = XML::Parser->new(
    'Handlers' => {
        'Start' => \&start_event,
        'End'   =>   \&end_event,
    }
);
my $result = $parser->parse($map);


