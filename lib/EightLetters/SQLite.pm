package EightLetters::SQLite;

use strict;
use warnings;

use Moo;
use DBI;

# Helpers for indexing into data structures;
use constant DECOMP_KEY            => 0;
use constant DECOMP_LETTER_COUNTS  => 1;
use constant DECOMP_BUCKET_COUNT   => 2;
use constant BUCKETS_LETTER_COUNTS => 0;
use constant BUCKETS_COUNT         => 1;
use constant DB_ALPHAS             => 0;
use constant DB_COUNT              => 1;

has dict_path => (is => 'ro');
has count     => (is => 'rw');
has letters   => (is => 'lazy');
has dbh       => (is => 'lazy');

sub _build_dbh {
    my $self = shift;
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=eightletters", "", "",
        { RaiseError => 1 }
    );
    return $dbh;
}

sub _build_letters {
    my $self = shift;

    my( $bags_aref, $shorter_aref, %alpha_freq ) = ( [], [], () );

    open my $dict_fh, '<:encoding(utf8)', $self->dict_path or die $!;

    while( my $word = <$dict_fh> ) {
      next unless $word =~ m/^([a-z]{1,8})\b/;
      my $wanted_word = $1;

      my $ref = 8 == length $wanted_word ? $bags_aref : $shorter_aref;
      push @$ref, $wanted_word;

      $alpha_freq{$_}++ for split //, $wanted_word;
    }

    # Find those buckets that have the least common letter in target word.
    # Use this as a comparison key for fastest rejection of letters from bags.
    my @ordered_letters
      = sort { $alpha_freq{$a} <=> $alpha_freq{$b} } keys %alpha_freq;

    # Open the db, and create the empty 'buckets' table.
    my $dbh = $self->dbh;
    $self->db_prepare( \@ordered_letters );

    {
      # Create the buckets.  These will become database rows, so we only need them
      # for a short time.
      my %buckets;
      $self->{'alpha_freq'} = \%alpha_freq;
      foreach my $word ( @$bags_aref ) {

        my $decomposed = $self->decompose_word($word);

        if( exists $buckets{$decomposed->[DECOMP_KEY]} ) {
          $buckets{$decomposed->[DECOMP_KEY]}[BUCKETS_COUNT]++;
        }
        else {
          $buckets{$decomposed->[DECOMP_KEY]} = [
            $decomposed->[DECOMP_LETTER_COUNTS],
            $decomposed->[DECOMP_BUCKET_COUNT]
          ];
        }

      }

      # Build the database.  Doing it in a transaction gives better performance.
      # This creates a bucket for each unique letter-set from words of length == 8.
      # If there are several of the same letter-set, the bucket count inserted is
      # some value greater than 1.  Otherwise, 1.
      # Column letter indices (eg, a, b, c) are a lie; we use frequency-ascending
      # column order in reality, which is determined at runtime.
      #                                             \ /--- letters                                                   count ----------\ /
      #                                              L  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  C
      my $insert = q{ INSERT INTO 'buckets' VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ); };

      $dbh->do( 'BEGIN TRANSACTION;' );

      my $sth = $dbh->prepare($insert);

      foreach my $bucket_key ( keys %buckets ) {

        my( $letters, $letter_counts, $bucket_count ) = (
          $bucket_key,
          $buckets{$bucket_key}[DB_ALPHAS],
          $buckets{$bucket_key}[DB_COUNT]
        );

        $sth->execute(
          $letters,
          @{$letter_counts}{@ordered_letters},
          $bucket_count
        );

      }

      $dbh->do( 'COMMIT TRANSACTION;' );

    }  # Database is built.  We're done with %buckets.

    # Now, tally each bucket by accumulating all the words of size < 8.
    $dbh->do( 'BEGIN TRANSACTION' );

    my $entry = 0;  # An iteration counter for outputting periodic progress report.

    # Iterate over every word of length < 8.
    foreach my $word ( @$shorter_aref ) {


      # Get the word's composition.
      my( $letters, $letter_counts, $bucket_count ) = @{ $self->decompose_word($word) };

      # We only care about the letters that exist in $word.
      # We use least frequent first order, as an optimization.
      my @criteria_keys = grep { $letter_counts->{$_} != 0 } @ordered_letters;
      my @criteria_values = @{$letter_counts}{@criteria_keys};

      # Example: UPDATE buckets SET count = count + 1 WHERE b >= 1 and o >= 2; ('boo')
      # Any buckets where these criteria are met could spell "boo"
      my $query = q{UPDATE 'buckets' SET count = count + 1 WHERE };
      my $where_clause = join ' AND ', map { "$_ >= ?" } @criteria_keys;
      $query .= $where_clause . ';';

      my $sth = $dbh->prepare( $query );
      $sth->execute(@criteria_values);  # Values come in the same order as @ordered_letters.
    }

    $dbh->do( 'COMMIT TRANSACTION' );

    my $stats = $self->gather_stats;
    $self->count($stats->{'count'});
    return $stats->{'letters'};
}


# Pass in a database handle.  Outputs current best letters and how many words
# they spell.
sub gather_stats {
  my $self = shift;
  my $dbh  = $self->dbh;

  # Now we find the maximum value in the "count" column among all buckets.
  my $sth = $dbh->prepare( 'SELECT MAX(count) FROM buckets' );
  $sth->execute;
  my( $count ) = $sth->fetchrow_array;


  # Now we find any rows that have this maximum count.
  $sth = $dbh->prepare( q{SELECT letters FROM buckets WHERE count = ? } );
  $sth->execute($count);

  my $letters = ($sth->fetchrow_array)[0];

  return {count => $count, letters => join('', sort split //, $letters)};
}

# Open up a database, create an empty "buckets" table that looks like:
# letters, a, b, c, d, e, f, ... z, count.
# "letters" is all the letters for a bucket together as a string.
# a, b, c... will be in frequency-ascending order. Each value represents number
#            of times a letter appears in this bucket.
# "count" is a count of how many times the bucket can be used.

sub db_prepare {
    my ($self, $ordered_letters_aref) = @_;

    my $create_sql = q{CREATE TABLE 'buckets' ( letters VARCHAR(8), };
    $create_sql .= "$_ INTEGER, " for @$ordered_letters_aref;
    $create_sql .= "count INTEGER )";

    my $dbh = $self->dbh;

    $dbh->do( q{DROP TABLE IF EXISTS 'buckets';} );

    my $sth = $dbh->prepare($create_sql);
    $sth->execute();
}

# Pass in a word, get back a structure:
# word == 'boo':
# [
#   'boo',  # In reverse letter frequency order
#   { a => 0, b => 1, c => 0, ... o => 2 ... z => 0, },
#   1,  # Initial state of bucket; we found one occurrence.
# ]

sub decompose_word {
  my ($self, $word) = @_;

  my $alpha_freq = $self->{'alpha_freq'};

  my @letters = sort { $alpha_freq->{$a} <=> $alpha_freq->{$b} } split //, $word;

  my $letter_counts_href;
  $letter_counts_href->{$_} = 0 for 'a' .. 'z';
  $letter_counts_href->{$_}++ for @letters;

  return [ join( '', @letters ), $letter_counts_href, 1 ];

}

1;
