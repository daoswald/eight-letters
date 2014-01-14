#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use Dictionary;
use Benchmark qw( timethese );

# Add the portion of your module's name that follows EightLetters::
# For example: If the module is EightLetters::MyTest, add just "MyTest" to
# the @modules array.
my @modules = qw( Oswald );

# Load the modules to be tested.
foreach my $module ( @modules ) {
  eval "require EightLetters::$module;";
}

# Load the dictionary that all the modules will use.
my $dictionary_aref = Dictionary->new->words;

# Generate a hash of "MyTest => sub{...}, ..." to use for testing each module.
my %timed = map {
  my $module = "EightLetters::$_";
  $_ => sub {
    my $el = $module->new( dict => $dictionary_aref );
    my $letters = $el->letters;
    my $count   = $el->count;
    return $count;
  }
} @modules;

# Now test the modules (this could take a LONG time).
timethese ( 1, \%timed );

