package EightLetters;

use integer;
use FindBin ();
use Moo;
use File::Slurp ();
use Inline C => 'DATA';

use constant {
  DICTIONARY => "$FindBin::Bin/../lib/dict/2of12inf.txt",
  SIGT       => 0,
  COUNT      => 1,
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

# Skip words with jkqvxz (each letter having less than 1% frequency in English
# usage for both the Wikipedia article and Cornel study.
# Wikipedia: http://en.wikipedia.org/wiki/Letter_frequency
# Cornel: http://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
#        W.P.    Cornel
# j ==  0.153%    0.10
# k ==  0.772%    0.69
# q ==  0.095%    0.11
# x ==  0.150%    0.17
# z ==  0.074%    0.07
# Also skip words with letters that appear more than once.
sub _build_dict {
  [
    map {
      ( !m/(\w).*\1/aa && m/^([abcdefghilmnoprstuvwy]{1,8})\b/aa && $1 ) || ()
    } File::Slurp::read_file($_[0]->dict_path)
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
    $ref->{$letters} = [ $_[0]->_build_signature($_), 0 ]
        unless exists $ref->{$letters};
    $ref->{$letters}[COUNT]++;
  }
  for my $bucket ( values %$b ) {
    $_ = ~$_ for @{$bucket->[SIGT]};
  }
}

sub _build_letters {
  my $self = shift;

#  print "Organizing words.\n";
  $self->_organize_words;

#  print "Tallying buckets.\n";
  $self->_increment_counts;
  
#  print "Finding biggest bucket.\n";
  my( $bucket_name, $count ) = $self->_count_buckets;
  $self->_count_internal($count);
  $bucket_name;
}


sub _increment_counts {
  my $words = [ values %{$_[0]->words} ];
  for my $b ( values %{$_[0]->buckets} ) {
#    $_[0]->_process_bucket( $b, $words ); # Perl implementation call.
    $_[0]->_process_bucket( $b, $words, SIGT, COUNT ); # Inline::C (XS) call.
  }
}

# This subroutine is replaced by an Inline::C implementation.

#sub _process_bucket {
#  my( $self, $b, $words ) = @_;
#  my $bs = $b->[SIGT];
#  for my $w ( @{$words} ) {
#    my $ws = $w->[SIGT];
#    $b->[COUNT] += $w->[COUNT]
#      if(  !( $bs->[0] & $ws->[0] )
#        && !( $bs->[1] & $ws->[1] )
#        && !( $bs->[2] & $ws->[2] )
#        && !( $bs->[3] & $ws->[3] )
#    );
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

#define PERL_NO_GET_CONTEXT

/* Big risk: We aren't checking SvROK or SvTYPE anywhere.  Know your data is
 * clean, because if it isn't, you'll core-dump.
 * ..... EFFICIENCY TRUPS SAFETY HERE. This is called in a tight loop. .....
 */

void _process_bucket( SV* self, SV* b, SV* words, int SIGT, int COUNT ) {

  // Unpack the arguments.
  AV* b_av     = (AV*) SvRV(b);
  AV* words_av = (AV*) SvRV(words);

  SV* b_count = (SV*) *( av_fetch(b_av,COUNT,0) );
  AV* bs_av    = (AV*) SvRV( *( av_fetch(b_av,SIGT,0) ) );

  uint64_t bs[4];
  size_t bsix = 0;
  for( bsix=0; bsix != 4; ++bsix ) {
    bs[bsix] = SvIV( *( av_fetch(bs_av,bsix,0) ) );
  }

  size_t ix=0;
  size_t top = av_top_index(words_av);

  // Optimization: Skip remainder of bucket if it's not growing fast enough.
  // Assumes words are in relatively random order (hash randomization offers).
  int stop_test_ix = top / 4;
  int stop_min_count = stop_test_ix / 100;
  
  for( ix = 0; ix <= top; ++ix ) {
    
    // Execution of optimization
    if( ix > stop_test_ix && SvIV(b_count) < stop_min_count ) break;    

    AV* word_av = (AV*) SvRV( *( av_fetch(words_av,ix,0 ) ) );
    AV* ws_av   = (AV*) SvRV( *( av_fetch(word_av,SIGT,0) ) );

    if(  !( SvIV( *( av_fetch(ws_av,0,0) ) ) & bs[0] )
      && !( SvIV( *( av_fetch(ws_av,1,0) ) ) & bs[1] )
      && !( SvIV( *( av_fetch(ws_av,2,0) ) ) & bs[2] )
      && !( SvIV( *( av_fetch(ws_av,3,0) ) ) & bs[3] )
    ) {
      sv_setiv(
        b_count,
        SvIV(b_count) + SvIV( *( av_fetch(word_av,COUNT,0) ) )
      );
    }
  }
}
