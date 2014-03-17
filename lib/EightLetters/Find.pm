package EightLetters::Find;

# Modules used                                                                #

use strict;
use warnings;
use Moo;
#use namespace::clean;

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
has words   => ( is => 'rw', default => sub { {} } );

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
  return [ unpack( 'V8', $bv ) ];
}

sub _make_histogram {
  my @hist = (0)x26;
  $hist[ ord() - ORD_A ]++ foreach split //, $_[1];
  return \@hist;
}

sub _organize_words {
  my $self = shift;
  foreach my $word ( @{$self->dict} ) {
    next unless $word =~ m/([a-z]{1,8})\b/;
    my $wanted_word = $1;
    my $letters = join '', sort split //, $wanted_word;
    if ( 8 == length $wanted_word ) {
      my $b = $self->buckets;
      $b->{$letters}
        = [ $wanted_word, $self->_build_signature($wanted_word), 0 ]
        unless exists $b->{$letters};
      $b->{$letters}->[COUNT]++;
    }
    else {
      my $w = $self->words;
      $w->{$letters}
        = [ $wanted_word, $self->_build_signature($wanted_word), 0 ]
          unless exists $w->{$letters};
      $w->{$letters}->[COUNT]++;
    }
  }
}

sub _build_letters {
  my $self = shift;
  
  # Prepare the buckets.
  $self->_organize_words;
  print "Words organized.  There are ", scalar keys %{$self->words}, " words remaining.\n";

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
  my $buckets = [ values %{$_[0]->buckets} ];
  foreach my $w ( values %{$_[0]->words} ) {
    my $wd = $w->[SIGT];
    foreach my $b ( @{$buckets} ) {
      my $bd = $b->[SIGT];
      $b->[COUNT] += $w->[COUNT]
        if (  !( $wd->[0] & ~ $bd->[0] )
           && !( $wd->[1] & ~ $bd->[1] )
           && !( $wd->[2] & ~ $bd->[2] )
           && !( $wd->[3] & ~ $bd->[3] )
           && !( $wd->[4] & ~ $bd->[4] )
           && !( $wd->[5] & ~ $bd->[5] )
           && !( $wd->[6] & ~ $bd->[6] )
           && !( $wd->[7] & ~ $bd->[7] )  );
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
