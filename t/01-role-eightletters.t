
package Test;

use strict;
use warnings;

use Moo;

sub count   { ... }
sub letters { ... }

with 'Role::EightLetters';

1;


package main;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

{
  local $@;
  eval {
    my $bad = Test->new( dict => {}, debug => 0 );
  };

  like $@, qr/^isa check for "dict" failed: <<HASH\(/, 'Constructor ISA check.';
}

{
  local $@;
  eval {
    my $bad = Test->new;
  };

  like $@, qr/^Missing required arguments: dict/,
    'Constructor required params check.';
}

my $aref = [];

my $good = new_ok 'Test', [ dict => $aref, debug => 1 ];

can_ok $good, qw/ new dict debug letters count/;

ok $good->does('Role::EightLetters'), 'Test class does Role::EightLetters.';

is $good->dict, $aref, 'Constructed correctly with "dict" param.';
is $good->debug, 1, 'Debug mode correctly detected.';

{
  local $@;
  eval {
    $good->letters;
  };
  like $@, qr/^Unimplemented/, 'letters method is unimplemented.';
}

{
  local $@;
  eval {
    $good->count;
  };
  like $@, qr/^Unimplemented/, 'count method unimplemented.';
}

done_testing();
