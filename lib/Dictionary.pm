package Dictionary;

use feature qw( unicode_strings );
use FindBin;
use Moo;


# Sane defaults.
use constant DICTIONARY     => "$FindBin::Bin/../lib/dict/2of12inf.txt";
use constant LENGTH_LIMIT   => 45;
use constant LENGTH_DEFAULT => 8;
has words => ( is => 'lazy' );

has path  => (
  is      => 'ro',
  default => DICTIONARY,
);


has max_length => (
  is      => 'ro',
  default => LENGTH_DEFAULT,
  isa     => sub {
    my $len = shift;
    die "Error: <$len> must be a positive integer in range of 1-" . LENGTH_LIMIT
      if $len !~ m/^[0-9]+$/ || $len < 1 || $len > LENGTH_LIMIT;
    return $len;
  }
);


# Run through the dictionary file, and keep only words of 8 characters or less,
# and drop any non-word characters at the end.
sub _build_words {
  my $self = shift;
  my $max = $self->max_length;
  open my $dict_fh, '<:encoding(utf8)', $self->path or die $!;
  return [    map { ( m/^([a-z]{1,$max})\b/ && $1 ) || () } <$dict_fh>    ];
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

=head1 DESCRIPTION

Provides an English dictionary of words of length no greater than eight
characters.  The dictionary file should have one word per line, and no
hyphenation or punctuation.  Trailing punctuation will be truncated.

=head1 ATTRIBUTES


=head2 path

  my $dict = Dictionary->new( path => 'path/to/dictionary.txt' );

B<Optional>. Provides the path where the dictionary may be found.  If none is
specified, the default dictionary bundled with the module will be used.


=head2 max_length

  my $dict = Dictionary->new( path => 'path', max_length => 8 );

B<Optional>. The dictionary generated will have words of C<max_length> letters
or less. All others will be dropped.  Default is 8.  Max is 45, which ought to
suffice. ;)


=head1 METHODS


=head2 new

  my $dict = Dictionary->new;
  my $dict = Dictionary->new( path => 'path/to/dictionary', max_length => 10 );

The constructor.  Defaults to the bundled dictionary, and max word length of 8.
May be passed a path and/or a max_letters parameter.  A Dictionary object will
be returned.


=head2 words

Returns a reference to an array containing all the words from the dictionary
that meet the C<max_length> criteria (by default, all words of 1-8 characters).


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

