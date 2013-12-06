

use strict;
use warnings;
use Test::More;

use FindBin;

use lib "$FindBin::Bin/../lib";

use_ok 'Dictionary';

can_ok 'Dictionary', 'DICTIONARY';
can_ok 'Dictionary', 'LENGTH_LIMIT';
can_ok 'Dictionary', 'LENGTH_DEFAULT';

can_ok 'Dictionary', 'new';

my $dict = new_ok 'Dictionary';

can_ok $dict, qw( path max_length words );

my $limit      = Dictionary::LENGTH_LIMIT();
my $path       = Dictionary::DICTIONARY();
my $length_def = Dictionary::LENGTH_DEFAULT();

is $dict->path, $path, 'Dictionary->new initializes to dictionary path.';

is $dict->max_length, $length_def,
  'Dictionary->new initializes to default max length.';

my $words = $dict->words;

isa_ok $words, 'ARRAY';

ok scalar @$words > 0, 'words() returns a reference to a populated array.';

my $max = 0;
my $min;
foreach my $word ( @$words ) {
  $max = length $word > $max ? length $word : $max;
  $min = ! defined $min || $min > length $word ? length $word : $min;
}

diag "Min and max word length: ($min, $max)";

ok $max <= $length_def,
  'Longest word does not exceed "max_length" attribute.';

ok $min >  0, 'Shortest word has non-zero length.';

my $dict2 = Dictionary->new( path => 'Hello', max_length => $limit );

is $dict2->path, 'Hello', 'new( path => ..., ) overrides default.';
is $dict2->max_length, $limit, 'new( max_length => ... ) overrides default.';

my $result = eval <<'EOP';
  my $dict3 = Dictionary->new( max_length => $limit + 1 );
  1;
EOP

ok !defined $result, 'Exceeding max_length limit throws.';

my $result2 = eval <<'EOP';
  my $dict3 = Dictionary->new( max_length => 0 );
  1;
EOP

ok !defined $result2, 'max_length <= 0 throws.';

done_testing();
