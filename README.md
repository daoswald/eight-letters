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

* new      -- A constructor.
* letters  -- Returns the optimal set of letters as a string.
* count    -- Returns how many words from 'dict' those letters spell.

The constructor will be called with the following attributes:

* dict     -- An array ref to a dictionary.
* debug    -- Optional; may cause output of additional debug info.

A constructor call ould look like this:

my $puzzle = EightLetters::YourModule->new( dict => $dict_aref, debug => 0 );

...followed by...

my $best_letters = $puzzle->letters;
my $num_words_spelled = $puzzle->count;


For details and ideas on impmementation, see the POD in:

* Role::EightLetters      -- A Moo role you may optionally use to
                             facilitate your module.

* EightLetters::Template  -- A Moo template class you may optionally
                             use as a starting point to build upon,
                             or even subclass it if you wish.

See also the slides in ./eightletters_slides.odf.

Here's what will happen.  Add your module's name to the list contained in
bin/bencheight.pl, and your module will be benchmarked against the others.

The benchmark script willcall the constructor, and then call
the two accessors: letters, and count.  All modules in the list will be
benchmarked, and the results will be sent to the screen.  This may take a long
time.

Remember: We are only concerned with words that are eight characters or less.
The dictionary supplied contains longer words too, and also contains some words
that need to be cleaned (there may be trailing non-alpha characters that may
safely be truncated).

There is a working implementation (not in "module" form, not pure-Perl)
at bin/eight.pl.

My rough draft working implementation of a pure-Perl module is
at lib/EightLetters/Oswald.pm.  On my machine that version takes 18 mintues
to run.


Required distributions:
Moo
MooX::Types::MooseLike
... Add any other module names here that I will need to install to use your
implementation
