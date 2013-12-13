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
use MooX::Types::MooseLike::Base qw( Int Str HashRef ArrayRef InstanceOf );
use DBI;


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

has count           => ( is => 'lazy', isa => Int );
has letters         => ( is => 'lazy', isa => Str );


# Internal accessors:

has _count_internal       => ( is  => 'rw',   isa => Int                     );
has _bags_aref            => ( is  => 'rw',   isa => ArrayRef[Str]           );
has _shorter_aref         => ( is  => 'rw',   isa => ArrayRef[Str]           );
has _alpha_freq_href      => ( is  => 'rw',   isa => HashRef[Str]            );
has _ordered_letters_aref => ( is  => 'rw',   isa => ArrayRef[Str]           );
has _db                   => ( is  => 'lazy', isa => InstanceOf[ 'DBI::db' ] );


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
  my $count = 1; # Incomplete.

  $self->_count_internal($count);
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

