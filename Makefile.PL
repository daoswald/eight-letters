## no critic (RCS,VERSION,may require interpolation)

use 5.010000;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my $PREREQ_PM = {
    'Exporter'              => '5.59',
    'FindBin'               => '0',
    'File::Slurp'           => '0',
    'Inline'                => '0',
    'Inline::C'             => '0',
    'Parallel::ForkManager' => '0',
    'Sys::Info'             => '0',
};

WriteMakefile(
  NAME             => 'EightLetters',
  AUTHOR           => q{David Oswald <davido[at]cpan[dot]org>},
  VERSION_FROM     => 'lib/EightLetters/Perl.pm',
  ABSTRACT_FROM    => 'lib/EightLetters/Perl.pm',
  LICENSE          => 'artistic_2',
  MIN_PERL_VERSION => '5.010000',
  PL_FILES         => {},
  PREREQ_PM        => $PREREQ_PM,
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources   => {
      license     => 'http://www.perlfoundation.org/artistic_license_2_0',
      repository  => {
        type => 'git',
        url  => 'https://github.com/daoswald/eight-letters.git',
        web  => 'https://github.com/daoswald/eight-letters',
      },
    },
    provides => {
      'EightLetters' => {
        file    => 'lib/EightLetters.pm',
        version => '2.0'
      },
    },
    prereqs => {
      runtime => {
        requires => $PREREQ_PM,
      },
    },
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
  clean => { FILES    => 'EightLetters-* _Inline bin/_Inline' },
);
