package Role::EightLetters;

use Moo::Role;
use MooX::Types::MooseLike::Base qw( ArrayRef Str Bool );
requires qw( new count letters );

has dict  => (    is  => 'ro',    isa => ArrayRef[Str],    required => 1    );
has debug => (    is  => 'ro',    isa => Bool    );

1;

__END__

=pod

=head1 NAME

Role::EightLetters

An abstract class for EightLetters::* classes.

=head1 SYNOPSIS

  package EightLetters::Example;

  # Your implementation goes here:

  # (You may feel free to remove any Moo stuff, so long as the interface
  #  remains consistent).

  use Moo;

  sub count { ... }
  sub letters { ... }

  # End of implementation.

  with 'Role::EightLetters';

  1;


  # Now in user code:

  package main;
  use EightLetters::Example;

  # ...

  my $search = EightLetters::Example->new( dict => [ @dictionary_words ] );
  my $best_letters = $search->letters;
  my $spell_count  = $search->count;

=head1 DESCRIPTION

Provides an interface specification for EightLetters::* classes.  This role
is optional, so long as your EightLetters::* class implements a constructor
called C<new>, and accessors C<count> and C<letters>.  The constructor, at
minimum, must accept a key/value attribute in the format of

This role also provides the following attributes:  C<dict>, and C<debug>, which
will be described shortly.


=head1 ATTRIBUTES


=head2 dict

  my $search = EightLetters::Example->new( dict => [ @dictionary_words ] );

Pass the trial dictionary to the constructor as an array reference, one word per
element.


=head2 debug

  my $search = EightLetters::Example->new( dict => $dict_aref, debug => 1 );

A Boolean value.  Use a true value to set debugging mode for your class.
Debugging mode is left as an exercise for the class's developer, but is useful
for conditionally printing progress reports, since the process of isolating the
eight letters that will spell the most words could potentially be quite long
running.


=head1 ADDITIONAL REQUIRED METHODS


=head2 new

  my $search = EightLetters::Example->new( dict => \@dict_aref, debug => 0 );

Pass the trial dictionary (required), and optionally a debug flag.  The
constructor will be implemented by L<Moo> in the consuming class.


=head2 letters

  my $best_letters = $search->letters;

Accessor.  Returns a string of letters that will spell the most words.

This is unimplemented. The consumer of this role must complete the
implementation of this method.


=head2 count

  my $most_spelled = $search->count;

Accessor. Returns the number of words spelled by the "best" set of letters.

This is unimplemented.  The consumer of this role must complete the
implementation of this method.

=head1 SUPPORT

You may find documentation for this module with the C<perldoc> command.

  perldoc Role::EightLetters::Template

This module is maintained in a public repo at Github. You may look for
information at:

=over 4

=item * Github: Development is hosted on Github at:

L<http://www.github.com/daoswald/EightLetters>

=item * Salt Lake Perl Mongers Website:

L<http://saltlake.pm.org>

=item * Salt Lake Perl Mongers Emailing List (See website for details).

=back


=head1 ACKNOWLEDGEMENTS

PerlMonks: L<http://perlmonks.org/?node_id=1056884> (Limbic~Region: "8 Letters,
Most Words").


=head1 AUTHOR

Dave Oswald E<lt>F<davido@cpan.org>E<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 David Oswald.

This module is free software; you may redistribute it and/or modify it under the
terms of either: the GNU General Public License as published by the Free
Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for details.

