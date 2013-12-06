#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters::Template;
use Dictionary;

my $el = EightLetters::Template->new( dict => Dictionary->new->words );

print scalar @{$el->dict}, "\n";
