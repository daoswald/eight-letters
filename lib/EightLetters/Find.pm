package EightLetters::Find;

# Modules used                                                                #

use strict;
use warnings;
use Moo;
use namespace::clean;

# Constants:

use constant WORD       => 0;
use constant SIGT       => 1;
use constant COUNT      => 2;
use constant ZEROBV     => do { my $bv; vec($bv,$_*32,32)=0 for 0 .. 7; $bv; };
use constant ORD_A      => ord('a');

# Primary accessors:

has dict    => ( is  => 'ro'  );
has debug   => ( is  => 'ro'  );
has count   => ( is => 'lazy' );
has letters => ( is => 'lazy' );
has buckets => ( is => 'rw', default => sub { {} } );
has words   => ( is => 'rw', default => sub { [] } );

# Internal accessors:

has _count_internal => ( is => 'rw' );

sub _build_count {
  $_[0]->letters;         # Populates _count_internal.
  $_[0]->_count_internal; # rv.
}

sub _build_signature {
  my ( $histogram, $bv ) = ( $_[0]->_make_histogram($_[1]), ZEROBV );
  foreach my $card_letter ( 0 .. $#{$histogram} ) {
    vec($bv, ( ( 32 * $histogram->[$card_letter] ) + $card_letter ), 1 ) = 1
      while $histogram->[$card_letter]--;
  }
  return [ map { vec( $bv, $_, 32 ) } 0 .. 7 ];
}

sub _make_histogram {
  my @hist = (0)x26;
  # 0 .. 25 will each contain a count of how many times a given letter appears.
  $hist[ ord() - ORD_A ]++ foreach split //, $_[1];
  return \@hist;
}

sub _organize_words {
  my $self = shift;
  my( %buckets, @rest );
  foreach my $word ( @{$self->dict} ) {
    next unless $word =~ m/([a-z]{1,8})\b/;
    my $wanted_word = $1;
    if ( 8 == length $wanted_word ) {
      my $letters = join '', sort split //, $wanted_word;
      ${$self->buckets}{$letters}
        = [ $wanted_word, $self->_build_signature($wanted_word), 0 ]
        unless exists ${$self->buckets}{$letters};
      ${$self->buckets}{$letters}->[COUNT]++;
    }
    else {
      push @{$self->words},
        [ $wanted_word, $self->_build_signature($wanted_word), 0 ];
    }
  }
}

sub _build_letters {
  my $self = shift;
  
  # Prepare the buckets.
  $self->_organize_words;
  print "Words organized.  There are ", scalar @{$self->words}, " words remaining.\n";

  # Increment the counts.
  print "Tallying buckets.\n";
  $self->_increment_counts;
  
  # Find the max of the counts.
  print "Finding best bucket.\n";
   my( $bucket_name, $count ) = $self->_count_buckets;
   $self->_count_internal($count);
   return $bucket_name;
}

sub _increment_counts {
  foreach my $w ( @{$_[0]->words} ) {
    foreach my $b ( values %{$_[0]->buckets} ) {
      $b->[COUNT]++
        if   ( ( $w->[SIGT][0] & $b->[SIGT][0] ) == $w->[SIGT][0] )
          && ( ( $w->[SIGT][1] & $b->[SIGT][1] ) == $w->[SIGT][1] )
          && ( ( $w->[SIGT][2] & $b->[SIGT][2] ) == $w->[SIGT][2] )
          && ( ( $w->[SIGT][3] & $b->[SIGT][3] ) == $w->[SIGT][3] )
          && ( ( $w->[SIGT][4] & $b->[SIGT][4] ) == $w->[SIGT][4] )
          && ( ( $w->[SIGT][5] & $b->[SIGT][5] ) == $w->[SIGT][5] )
          && ( ( $w->[SIGT][6] & $b->[SIGT][6] ) == $w->[SIGT][6] )
          && ( ( $w->[SIGT][7] & $b->[SIGT][7] ) == $w->[SIGT][7] );
    }
  }
}  

sub _count_buckets {
  my( $count, $buckets, $bucket_name ) = ( 0, $_[0]->buckets, '' );
  while( my( $bucket_key, $bucket ) = each %$buckets ) {
    if( $bucket->[COUNT] > $count ) {
      $bucket_name = $bucket_key;
      $count = $bucket->[COUNT];
    }
  }
  return ( $bucket_name, $count );
}

1;
