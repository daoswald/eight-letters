package EightLetters::DavidoSQLite;

# Name:

# Implementation Notes:
#
#
#



###############################################################################
# Modules used                                                                #
###############################################################################

use strict;
use warnings;
use Moo;
use DBI;
use Scalar::Util qw( reftype );



###############################################################################
# Constants and helpers for indexing into data structures                     #
###############################################################################

use constant DECOMP_KEY            => 0;
use constant DECOMP_LETTER_COUNTS  => 1;
use constant DECOMP_BUCKET_COUNT   => 2; 
use constant BUCKETS_LETTER_COUNTS => 0;
use constant BUCKETS_COUNT         => 1;
use constant DB_ALPHAS             => 0;
use constant DB_COUNT              => 1;


# There must be a constructor called "new" that accepts a "dict => aref" param.
# Using the Role::EightLetters role provides this constructor.  See the
# Role::EightLetters POD for details.


###############################################################################
# Attributes                                                                  #
###############################################################################

# Primary accessors:

has count           => ( is => 'lazy' );
has letters         => ( is => 'lazy' );

# Internal accessors:

has _count_internal => ( is => 'rw' );

has _bags_aref      => (
  is  => 'rw',
  isa => sub {
    die '_bags_aref must be an aref.'
      unless reftype shift eq 'ARRAY';
  }
);

has _shorter_aref   => (
  is  => 'rw',
  isa => sub {
    die '_shorter_aref must be an aref.'
      unless reftype shift eq 'ARRAY';
  }
);

has _alpha_freq_href => (
  is  => 'rw',
  isa => sub {
    die '_alpha_freq_href must be an href.'
      unless reftype shift eq 'HASH';
  }
);

has _ordered_letters_aref => (
  is  => 'rw',
  isa => sub {
    die '_ordered_letters_aref must be an aref.'
      unless reftype shift eq 'ARRAY';
  }
);

has db => (
  is  => 'lazy',
  isa => sub { die 'Not a database handle' unless ref shift eq 'DBI::db'; }
);


###############################################################################
# Builders                                                                    #
###############################################################################

sub _count_builder {
  my $self = shift;
  $self->letters;     # Populates _count_internal.
  return $self->_count_internal;
}

sub _letters_builder {
  my $self = shift;

  # $self->_count_internal($count);
}

sub _db_builder {
  my $self = shift;

  ...
}


###############################################################################
# Internals                                                                   #
###############################################################################

sub _initialize_buckets {
  my $self = shift;
  foreach my $word ( @{ $self->dict } ) {
    push @{ length $word == 8 ? $self->_bags_aref : $self->_shorter_aref }, $word;
    $self->_alpha_freq_href->{$word}++ for split //, $word;
  }
}



# End of implementation.



###############################################################################
# Roles used                                                                  #
###############################################################################

with 'Role::EightLetters';


1;


__END__

=pod

=cut

