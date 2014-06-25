use Test::More;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use EightLetters;

ok(1);
my $w = EightLetters->new;
my $bits = $w->_build_signature("eieio");
my $letters = $w->_sig_to_alpha($bits);
is $letters, 'eeiio', "Round trip.";
$bits = $w->_build_signature(
 join('','a'..'z') x 8
);
$letters = $w->_sig_to_alpha($bits);
is $letters,
  join('', map { $_ x 8 } 'a' .. 'z'),
  "Round trip 2.";
done_testing();
