

use strict;
use warnings;
use Test::More;

use FindBin;

use lib "$FindBin::Bin/../lib";

use_ok 'Dictionary';

can_ok 'Dictionary', 'DICTIONARY';
can_ok 'Dictionary', 'new';

my $dict = new_ok 'Dictionary';
can_ok $dict, 'words';

my $path = Dictionary::DICTIONARY();
is $dict->path, $path, 'Dictionary->new initializes to dictionary path.';

my $words = $dict->words;
isa_ok $words, 'ARRAY';
ok scalar @$words > 0, 'words() returns a reference to a populated array.';


my $dict2 = Dictionary->new( path => 'Hello' );
is $dict2->path, 'Hello', 'new( path => ..., ) overrides default.';

my $dict3 = Dictionary->new( path => "$FindBin::Bin/../lib/dict/test_dict.txt" );
ok scalar @{ $dict3->words } > 0, 'Alternate Test Dictionary instantiates.';

done_testing();
