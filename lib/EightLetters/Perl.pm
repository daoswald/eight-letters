package EightLetters::Perl;

use Moo;

use constant TARGET_LENGTH => 8;

has dict_path => (is => 'ro');
has count     => (is => 'lazy');
has letters   => (is => 'lazy');
has _buckets   => (is => 'rw', default => sub { {} });
has _words     => (is => 'lazy');

sub _build__words {
    my $self = shift;
    my $dict_path = $self->dict_path;
    open my $fh, '<', $dict_path or die "Cannot open $dict_path: $!\n";
    my @words = map {(m{^([a-z]{1,8})\b} && $1) || ()} <$fh>;
    return \@words;
}


1;
