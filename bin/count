#!/usr/bin/env perl

my $t;
BEGIN{
  use Time::HiRes;
  $t = [Time::HiRes::gettimeofday()];
}

use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters;

use constant TEST_DICT => "$FindBin::Bin/../lib/dict/test_dict.txt";

print $_->letters, " spells ", $_->count, " words.\n" for EightLetters->new;

END{
  printf "Duration: %.03f seconds.\n", Time::HiRes::tv_interval($t);
}
