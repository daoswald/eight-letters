package EightLetters;

use integer;

use FindBin;
use Moo;

use constant {
  DICTIONARY => "$FindBin::Bin/../lib/dict/2of12inf.txt",
  WORD       => 0,
  SIGT       => 1,
  COUNT      => 2,
  ZEROBV     => do { my $bv; vec( $bv, $_ * 32, 32 ) = 0 for 0 .. 7; $bv },
  ORD_A      => ord 'a',
};

has dict_path       => ( is => 'ro', default => DICTIONARY );
has dict            => ( is => 'lazy' );
has count           => ( is => 'lazy' );
has letters         => ( is => 'lazy' );
has buckets         => ( is => 'rw', default => sub { {} } );
has words           => ( is => 'rw', default => sub { {} } );
has _count_internal => ( is => 'rw'   );

sub _build_dict {
  open my $dict_fh, '<', $_[0]->dict_path or die $!;
  return [ map { ( m/^([a-z]{1,8})\b/ && $1 ) || () } <$dict_fh> ];
}

sub _build_count {
  $_[0]->letters;
  $_[0]->_count_internal;
}

sub _build_signature {
  my( $bv, @hist ) = ( ZEROBV, (0) x 26 );
  $hist[ ord() - ORD_A ]++ for split //, $_[1];
  for ( 0 .. $#hist ) {
    vec( $bv, $hist[$_] * 26 + $_, 1 ) = 1 while $hist[$_]--;
  }
  return [ unpack 'Q4', $bv ];
}

sub _sig_to_alpha {
  my ($self, $signature ) = @_;
  my $bv = pack 'Q4', @{$signature};
  my %letter;
  vec($bv,$_,1) && $letter{chr(($_%26)+ORD_A)}++ for 0 .. 255;
  return join '', map { $_ x $letter{$_} } sort keys %letter;
}

sub _organize_words {
  my( $b, $w ) = ( $_[0]->buckets, $_[0]->words );
  for ( @{$_[0]->dict} ) {
    my $letters = join '', sort split //;
    my $ref = ( 8 == length ) ? $b : $w;
    $ref->{$letters} = [ $_, $_[0]->_build_signature($_), 0 ]
        unless exists $ref->{$letters};
    $ref->{$letters}[COUNT]++;
  }
  for my $bucket ( values %$b ) {
    $_ = ~$_ for @{$bucket->[SIGT]};
  }
}

sub _build_letters {
  my $self = shift;

  print "Organizing words.\n";
  $self->_organize_words;

  print "Tallying buckets.\n";
  $self->_increment_counts;
  
  print "Finding biggest bucket.\n";
   my( $bucket_name, $count ) = $self->_count_buckets;
   $self->_count_internal($count);
   return $bucket_name;
}

sub _increment_counts {
  my $buckets = [ values %{$_[0]->buckets} ];
  for my $w ( values %{$_[0]->words} ) {
    my $ws = $w->[SIGT];
    for my $b ( @{$buckets} ) {
      my $bs = $b->[SIGT];
      $b->[COUNT] += $w->[COUNT]
        if (  !( $ws->[0] & $bs->[0] )
           && !( $ws->[1] & $bs->[1] )
           && !( $ws->[2] & $bs->[2] )
           && !( $ws->[3] & $bs->[3] ) );
    }
  }
}  

sub _count_buckets {
  my( $count, $buckets, $letters ) = ( 0, $_[0]->buckets, '' );
  while( my( $bucket_key, $bucket ) = each %$buckets ) {
    if( $bucket->[COUNT] > $count ) {
      $letters = $bucket_key;
      $count = $bucket->[COUNT];
    }
  }
  return ( $letters, $count );
}

1;
