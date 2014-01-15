#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Dictionary;
use Test::More;
use EightLetters::Oswald;

my $dict_aref = Dictionary->new->words;

# my $el = EightLetters::Oswald->new( dict => $dict_aref );
my $el = new_ok( 'EightLetters::Oswald' => [ dict => $dict_aref ] );

is(
  join( '', sort split //, $el->letters ), 'aeinprst', 
  'Found correct letters.'
);

is( $el->count, 346, 'Found correct word count.' );

done_testing();
