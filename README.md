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
* letters  -- Returns the optimal set of letters.
* count    -- Returns how many words from 'dict' those letters spell.

As well as the following attributes:

* dict     -- An array ref to a dictionary.
* debug    -- Optional; may cause output of additional debug info.

For details and ideas on impmementation, see the POD in:

* Role::EightLetters      -- A Moo role you may optionally use to
                             facilitate your module.

* EightLetters::Template  -- A Moo template class you may optionally
                             use as a starting point to build upon,
                             or even subclass it if you wish.

Here's what will happen.  A script will invoke all modules in the
lib/EightLetters/* folder, call the constructor, and then call
the two accessors: letters, and count.  Each module will be
benchmarked, and the results will be displayed.

The script skips EightLetters::Template, of course, since that
is mostly just a dummy framework.


Required distributions:
Moo
MooX::Types::MooseLike
DBI

