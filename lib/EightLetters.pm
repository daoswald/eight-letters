package EightLetters;

use integer;
use FindBin;
use Moo;
use List::Util 'reduce';
use File::Slurp;
use Inline C => 'DATA';

use constant {
  DICTIONARY => "$FindBin::Bin/../lib/dict/2of12inf.txt",
  WORD       => 0,
  SIGT       => 1,
  COUNT      => 2,
  ZEROBV     => do { my $bv; vec( $bv, $_ * 32, 32 ) = 0 for 0 .. 7; $bv },
  ORD_A      => ord 'a'
};

has dict_path       => ( is => 'ro', default => DICTIONARY );
has dict            => ( is => 'lazy' );
has count           => ( is => 'lazy' );
has letters         => ( is => 'lazy' );
has buckets         => ( is => 'rw', default => sub { {} } );
has words           => ( is => 'rw', default => sub { {} } );
has _count_internal => ( is => 'rw'   );

# Skip words with jkqvxz.
sub _build_dict {
  [
    map {
      ( m/^([abcdefghilmnoprstuwy]{1,8})\b/ && $1 ) || ()
    } read_file($_[0]->dict_path)
  ]
}

sub _build_count {
  $_[0]->letters;
  $_[0]->_count_internal;
}

sub _build_signature {
  my( $bv, @hist ) = ( ZEROBV, (0)x26 );
  $hist[ ord() - ORD_A ]++ for split //, $_[1];
  for ( 0 .. $#hist ) {
    vec( $bv, $hist[$_] * 26 + $_, 1 ) = 1 while $hist[$_]--;
  }
  [ unpack 'Q4', $bv ];
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
  $bucket_name;
}

#sub _increment_counts {
#  my $buckets = [ values %{$_[0]->buckets} ];
#  for my $w ( values %{$_[0]->words} ) {
#    my $ws = $w->[SIGT];
#    for my $b ( @{$buckets} ) {
#      my $bs = $b->[SIGT];
#      $b->[COUNT] += $w->[COUNT]
#        if (  !( $ws->[0] & $bs->[0] )
#           && !( $ws->[1] & $bs->[1] )
#           && !( $ws->[2] & $bs->[2] )
#           && !( $ws->[3] & $bs->[3] ) );
#    }
#  }
#}  

sub _increment_counts {
  my $words = [ values %{$_[0]->words} ];
  for my $b ( values %{$_[0]->buckets} ) {
    $_[0]->_process_bucket($b,$words,SIGT,COUNT);
  }
}

#sub _process_bucket {
#  my( $self, $b, $words ) = @_;
#  my $bs = $b->[SIGT];
#  for my $w ( @{$words} ) {
#    my $ws = $w->[SIGT];
#    $b->[COUNT] += $w->[COUNT]
#      if(  !( $bs->[0] & $ws->[0] )
#        && !( $bs->[1] & $ws->[1] )
#        && !( $bs->[2] & $ws->[2] )
#        && !( $bs->[3] & $ws->[3] ) );
#  }
#}


sub _count_buckets {
  my( $count, $buckets, $letters ) = ( 0, $_[0]->buckets, '' );
  while( my( $bucket_key, $bucket ) = each %$buckets ) {
    if( $bucket->[COUNT] > $count ) {
      $letters = $bucket_key;
      $count = $bucket->[COUNT];
    }
  }
  ( $letters, $count );
}

1;

__DATA__
__C__

// sub _process_bucket {
//   my( $self, $b, $words ) = @_;
//   my $bs = $b->[SIGT];
//   for my $w ( @{$words} ) {
//     my $ws = $w->[SIGT];
//     $b->[COUNT] += $w->[COUNT]
//       if(  !( $bs->[0] & $ws->[0] )
//         && !( $bs->[1] & $ws->[1] )
//         && !( $bs->[2] & $ws->[2] )
//         && !( $bs->[3] & $ws->[3] ) );
//   }
// }

void _process_bucket( SV* self, SV* b, SV* words, int SIGT, int COUNT ) {

  if( ! SvROK(b) || ( SvTYPE( SvRV(b) ) != SVt_PVAV ) )
    croak( "_process_bucket: First argument must be an array reference." );
    
  if( ! SvROK(words) || ( SvTYPE( SvRV(words) ) != SVt_PVAV ) )
    croak( "_process_bucket: Second argument must be an array reference." );

  AV* b_av = (AV*) SvRV(b);
  AV* words_av = (AV*) SvRV(words);
  AV* bs = (AV*) av_fetch(b_av,SIGT,0);
  size_t i = 0;
  for( i=0; i <= av_top_index(words_av); ++i ) {
    AV* ws_av = (AV*) av_fetch(words_av,SIGT,0);
  }
}
}
