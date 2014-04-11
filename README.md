eight-letters
=============

Eight Letters, Most Words

* What eight letters will spell the most words for a given dictionary?
* How many words will those eight letters spell?

These seemingly simple questions are computationally difficult
to answer.

Your job, should you choose to accept it, is to write a module
that resolves the answers to these two questions.

The module will reside in the EightLetters heirarcy, and should
implement the following class and object methods:

* new       -- A constructor.
* letters   -- Returns the optimal set of letters as a string.
* count     -- Returns how many words from 'dict' those letters spell.
* dict_path -- Path to a dictionary file to use.

A constructor call dould look like this:

my $puzzle = EightLetters::YourModule->new( dict_path => 'path_to_dictionary_file' );

or

my $puzzle = EightLetters::YourModule->new; # Default dictionary.

...followed by...

my $best_letters = $puzzle->letters;
my $num_words_spelled = $puzzle->count;

See also the slides in ./eightletters_slides.odf (a little outdated.)

Remember: We are only concerned with words that are eight characters or less.
The dictionary supplied contains longer words too, and also contains some words
that need to be cleaned (there may be trailing non-alpha characters that may
safely be truncated).

There is a working implementation (not in "module" form, not pure-Perl)
at bin/eight.pl.

My working implementation of a pure-Perl module is
at lib/EightLetters.pm.  On my machine that version takes about two  mintues
to run.


Required distributions:
Moo
... Add any other module names here that I will need to install to use your
implementation
