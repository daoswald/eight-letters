package EightLetters::Oswald;

# Name:

# Implementation Notes:
#
# This implementation stores buckets in a HoA, where each hash element is a
# bucket, and each bucket contains an array of letter counts.
#


###############################################################################
# Modules used                                                                #
###############################################################################

use strict;
use warnings;
use Moo;
use MooX::Types::MooseLike::Base qw( Int Str HashRef ArrayRef InstanceOf );

###############################################################################
# Constants and helpers for indexing into data structures                     #
###############################################################################

use constant ASCII_OFFSET => ord('a');
use constant Z_INDEX      => ord('z') - ASCII_OFFSET;
use constant COUNT_INDEX  => Z_INDEX + 1;

# There must be a constructor called "new" that accepts a "dict => aref" param.
# Using the Role::EightLetters role provides this constructor.  See the
# Role::EightLetters POD for details.


###############################################################################
# Attributes                                                                  #
###############################################################################


# Primary accessors:

has count           => ( is => 'lazy', isa => Int );
has letters         => ( is => 'lazy', isa => Str );


# Internal accessors:

has _count_internal => ( is => 'rw',   isa => Int );

###############################################################################
# Builders                                                                    #
###############################################################################

sub _build_count {
  my $self = shift;
  $self->letters;     # Populates _count_internal.
  return $self->_count_internal;
}

sub _build_letters {
  my $self  = shift;

  my %eights;
  my @rest;

  my $debug_counter = 0;

  # Prepare the buckets.
  foreach my $word ( @{$self->dict} ) {
    next unless $word =~ m/^([a-z]{1,8})\b/; # Skip words longer than 8 letters
                                             # and drop any non-alpha suffix.
    my $valid_word = $1;
    my @letters = split //, $valid_word;
    my @letter_counts;
    $letter_counts[ ord($_) - ASCII_OFFSET ]++ for @letters;

    if( 8 == length $valid_word ) {
      my $sorted_letters = join '', sort @letters;
      @{$eights{$sorted_letters}}[0..Z_INDEX] = @letter_counts;
      $eights{$sorted_letters}[COUNT_INDEX]++;    # Bucket tally starts at 1
    }
    else {
      push @rest, \@letter_counts;
    }
  }

  # Summarize buckets in debug mode.
  if( $self->debug ) {
    my $num_buckets = 0;
    $num_buckets += $eights{$_}[COUNT_INDEX] for keys %eights;
    my $remaining = scalar @rest;
    my $orig_dict = scalar @{$self->dict};
    print STDERR "Dict: $orig_dict. Buckets: $num_buckets. Remaining: $remaining.\n";
  }
  
  # Increment buckets into which remaining words fit.
  foreach my $word ( @rest ) {
    BUCKET: while( my( $letters, $counts ) = each %eights ) {
      my @indices = grep { defined $word->[$_] } 0 .. $#{$word};
      foreach my $ix ( @indices ) {
        next BUCKET  # Word DOESN'T fit in bucket;
          if ! defined $counts->[$ix]  ||  $word->[$ix] > $counts->[$ix];
      }
      $counts->[COUNT_INDEX]++; # Word DOES fit in bucket if we arrive here.
    }
  }

  # Find which set of letters has highest tally.
  my( $max_count, $max_key ) = (0);
  while( my( $letters, $meta ) = each %eights ) {
    if( $max_count < $meta->[COUNT_INDEX] ) {
      $max_key = $letters;
      $max_count = $meta->[COUNT_INDEX];
    }
  }

  # Set the basis for the count attribute, and return the best set of letters.
  $self->_count_internal($max_count);
  return $max_key;
}


###############################################################################
# Internals                                                                   #
###############################################################################




# End of implementation.



###############################################################################
# Roles used                                                                  #
###############################################################################

with 'Role::EightLetters';


1;


__END__

=pod

=cut

