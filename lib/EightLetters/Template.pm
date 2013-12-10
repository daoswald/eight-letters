package EightLetters::Template;

# Name:

# Implementation Notes:
#
#
#


# Your implementation goes here:


# (Feel free to remove Moo stuff, so long as the interface remains consistent).

use Moo;

# There must be a constructor called "new" that accepts a "dict => aref" param.
# Using the Role::EightLetters role provides this constructor.  See the
# Role::EightLetters POD for details.

# my $puzzle = EightLetters->new( dict => [ qw( aref of words ) ] );

# my $count = $puzzle->count;
sub count { ... }

# my $letters = $puzzle->letters;
sub letters { ... }





# End of implementation.

with 'Role::EightLetters';
# Role::EightLetters provides the dict and debug attributes.  dict must be
# passed to the constructor as an array ref.  debug is an optional Boolean flag.

1;


__END__

=pod

=head1 NAME

EightLetters::Template

A sample framework for an EightLetters::I<YourPackage> class.

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

This template provides a framework based on L<Moo> and the L<Role::EightLetters>
role which may be used as a starting point in building an
EightLetters::I<YourPackage> class.

=head1 ATTRIBUTES


=head2 dict

  my $search = EightLetters::Example->new( dict => [ @dictionary_words ] );

Pass the trial dictionary to the constructor as an array reference, one word per
element.


=head2 debug

  my $search = EightLetters::Example->new( dict => $dict_aref, debug => 1 );

Optional: A Boolean value.  Use a true value to set debugging mode for your
class. Debugging mode is left as an exercise for the class's developer, but is
useful for conditionally printing progress reports.


=head1 ADDITIONAL REQUIRED METHODS


=head2 new

  my $search = EightLetters::Example->new( dict => \@dict_aref, debug => 0 );

Pass the trial dictionary (required), and optionally a debug flag.  The
constructor will be implemented by L<Moo> in the consuming class.

Moo will create this constructor for you if you use this template and its
associated role.  If you choose to write your own blessed-ref class you'll need
to implement a constructor that accepts a "C<dict => [aref]>" parameter.


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

  perldoc EightLetters::Template

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

=cut

