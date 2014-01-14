#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters::Oswald;
use Dictionary;

my $el = EightLetters::Oswald->new( dict => Dictionary->new->words );
my $letters = $el->letters;
my $count   = $el->count;

print "$letters spells $count words.\n";
