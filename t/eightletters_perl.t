#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use lib "$FindBin::Bin/../lib";

our $MODULE = 'EightLetters::Perl';
our @METHODS = qw(dict_path count letters _buckets _words _build__words);
our $DICT_PATH = "$FindBin::Bin/../lib/dict/2of12inf.txt";

subtest module => sub {
    plan tests => 3;
    use_ok $MODULE;
    can_ok $MODULE, 'new', @METHODS;
    my $o = new_ok $MODULE, [dict_path => $DICT_PATH];
};

subtest words => sub {
    plan tests => 2,
    eval "require $MODULE;" or die "Cannot continue without $MODULE.\n";

    my $o = $MODULE->new(dict_path => $DICT_PATH);
    is $o->dict_path, $DICT_PATH, 'Got correct dictionary path.';

    is ref($o->_words()), 'ARRAY', 'words method returns an array.';
}
