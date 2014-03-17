package Dictionary;

use feature qw( unicode_strings );
use FindBin;
use Moo;

# Sane defaults.
use constant DICTIONARY => "$FindBin::Bin/../lib/dict/2of12inf.txt";

has words => ( is => 'lazy' );
has path  => ( is => 'ro', default => DICTIONARY );

# Run through the dictionary file, and keep only words of 8 characters or less,
# and drop any non-word characters at the end.
sub _build_words {
  my $self = shift;
  open my $dict_fh, '<:encoding(utf8)', $self->path or die $!;
  return [ map { ( m/^([a-z]+)\b/ && $1 ) || () } <$dict_fh> ];
}

1;
