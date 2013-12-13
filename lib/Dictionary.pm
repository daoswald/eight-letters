package Dictionary;

use feature qw( unicode_strings );
use FindBin;
use Moo;
use MooX::Types::MooseLike::Base qw( ArrayRef Str );

# Sane defaults.
use constant DICTIONARY     => "$FindBin::Bin/../lib/dict/2of12inf.txt";

has words => (    is => 'lazy',    isa => ArrayRef[Str]    );
has path  => (    is => 'ro',      default => DICTIONARY    );


# Run through the dictionary file, and keep only words of 8 characters or less,
# and drop any non-word characters at the end.
sub _build_words {
  my $self = shift;
  open my $dict_fh, '<:encoding(utf8)', $self->path or die $!;
  return [    map { ( m/^([a-z]+)\b/ && $1 ) || () } <$dict_fh>    ];
}


1;

__END__

=pod

=head1 NAME

Dictionary

Provides a dictionary list of words.

=head1 SYNOPSIS

  use Dictionary;
  my $words_aref = Dictionary->new->words;

  # or
  my $words_aref = Dictionary->new( path => 'path/to/dict.txt' )->words;

=head1 DESCRIPTION

Provides an English dictionary of words.  The dictionary file should have one
word per line, and no hyphenation or punctuation.  Trailing characters that
don't match C<[A-Za-z]> will be truncated.


=head1 ATTRIBUTES


=head2 path

  my $dict = Dictionary->new( path => 'path/to/dictionary.txt' );

B<Optional>. Provides the path where the dictionary may be found.  If none is
specified, the default dictionary bundled with the module will be used.

=head1 METHODS


=head2 new

  my $dict = Dictionary->new;
  my $dict = Dictionary->new( path => 'path/to/dictionary', max_length => 10 );

The constructor.  Defaults to the bundled dictionary, and max word length of 8.
May be passed a path and/or a max_letters parameter.  A Dictionary object will
be returned.


=head2 words

Returns a reference to an array containing all the words from the dictionary.


=head1 SUPPORT

You may find documentation for this module with the C<perldoc> command.

  perldoc Dictionary

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

