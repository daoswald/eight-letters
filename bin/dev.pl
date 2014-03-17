#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters::Find;
use Dictionary;


#my $el = EightLetters::Find->new( dict => Dictionary->new(path=>"$FindBin::Bin/../lib/dict/test_dict.txt")->words );
my $el = EightLetters::Find->new( dict => Dictionary->new->words );
my $letters = $el->letters;
my $count   = $el->count;

print "$letters spells $count words.\n";

