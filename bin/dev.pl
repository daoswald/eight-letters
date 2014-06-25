#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters;

use constant TEST_DICT => "$FindBin::Bin/../lib/dict/test_dict.txt";

my $el = EightLetters->new;
my( $letters, $count ) = ( $el->letters, $el->count );

print "$letters spells $count words.\n";
