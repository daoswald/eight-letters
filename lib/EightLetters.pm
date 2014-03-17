package EightLetters;

use strict;
use warnings;
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
  my( $bv, @hist ) = ( ZEROBV, (0)x26 );
  $hist[ ord() - ORD_A ]++ foreach split //, $_[1];
  foreach ( 0 .. $#hist ) {
    vec( $bv, $hist[$_] * 26 + $_, 1 ) = 1
      while $hist[$_]--;
  }
  return [ unpack 'Q4', $bv ];
}

sub _organize_words {
  my( $b, $w ) = ( $_[0]->buckets, $_[0]->words );
  foreach ( @{$_[0]->dict} ) {
    my $letters = join '', sort split //;
    my $ref = ( 8 == length ) ? $b : $w;
    $ref->{$letters} = [ $_, $_[0]->_build_signature($_), 0 ]
        unless exists $ref->{$letters};
    $ref->{$letters}[COUNT]++;
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
  foreach my $w ( values %{$_[0]->words} ) {
    my $wd = $w->[SIGT];
    foreach my $b ( @{$buckets} ) {
      my $bd = $b->[SIGT];
      $b->[COUNT] += $w->[COUNT]
        if (  !( $wd->[0] & ~$bd->[0] )
           && !( $wd->[1] & ~$bd->[1] )
           && !( $wd->[2] & ~$bd->[2] )
           && !( $wd->[3] & ~$bd->[3] ) );
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
