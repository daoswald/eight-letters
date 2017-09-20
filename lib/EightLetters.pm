package EightLetters;

=head1 NAME

EightLetters - Perl module to calculate which eight letter word spells the most words in a dictionary.

=cut

use integer;
use FindBin;
use Moo;
use File::Slurp;
use Config;
use Inline C => 'DATA';
use Inline C => Config => ccflags => $Config{'ccflags'} . ' -Ofast';
use Parallel::ForkManager;
use Sys::Info;
no warnings 'experimental::postderef';
use feature 'postderef';

our $VERSION = '2.0';

use constant {
    DICTIONARY          => "$FindBin::Bin/../lib/dict/2of12inf.txt",
    SIGT                => 0,
    COUNT               => 1,
    ZEROBV              => "\0" x (32*8), #do {my $bv; vec($bv, $_*32, 32) = 0 for 0 .. 7; $bv},
    ORD_A               => ord 'a',
    CORE_MULTIPLIER     => 3,       # In testing, 2 is better on an i5 with 4 cores,
                                    # 3 is better on i7 with 4 cores, 8 logical.
};

has dict_path       => (is => 'ro', default => DICTIONARY);
has dict            => (is => 'lazy');
has count           => (is => 'lazy');
has letters         => (is => 'lazy');
has buckets         => (is => 'rw', default => sub {{}});
has words           => (is => 'rw', default => sub {{}});
has _count_internal => (is => 'rw');
has _pm             => (is => 'lazy');
has _num_processes  => (is => 'lazy');

# Skipping words with jkqvxz is obviously faster but makes unsafe assumptions for an arbitrary dict.
sub _build_dict {[map {(m/^([a-z]{1,8})\b/ && $1) || ()} read_file($_[0]->dict_path)]}

sub _build_count {
    $_[0]->letters;
    $_[0]->_count_internal;
}

sub _build_signature {
    my($bv, @hist) = (ZEROBV, (0)x26);
    $hist[ord() - ORD_A]++ for unpack '(A)*', $_[1];
    for (0 .. $#hist) {
        vec($bv, $hist[$_]*26+$_, 1) = 1 while $hist[$_]--;
    }
    [unpack 'Q4', $bv];
}

sub _build__num_processes {(Sys::Info->new->device('CPU')->count) * CORE_MULTIPLIER}
sub _build__pm {Parallel::ForkManager->new(shift()->_num_processes)}

sub _organize_words {
    my($b, $w) = ($_[0]->buckets, $_[0]->words);
    for ($_[0]->dict->@*) {
        my $letters = join '', sort unpack '(A)*';
        my $ref = (8 == length) ? $b : $w;
        $ref->{$letters} = [$_[0]->_build_signature($_), 0]
            unless exists $ref->{$letters};
        $ref->{$letters}[COUNT]++;
    }
}

sub _build_letters {
    my $self = shift;

    print "Organizing words.\n";
    $self->_organize_words;

    my $np = $self->_num_processes;
    my $mult = CORE_MULTIPLIER;
    my $ncores = $np/$mult;

    print "Tallying buckets with $np processes ($ncores cores * $mult).\n";
    $self->_increment_counts;

    print "Finding biggest bucket.\n";
    my($bucket_name, $count) = $self->_count_buckets;
    $self->_count_internal($count);
    $bucket_name;
}


sub _increment_counts {
    my $words = [values $_[0]->words->%*];

    my $n = 0;
    my $m = $_[0]->_num_processes;

    my @batches;
    my $buckets = $_[0]->buckets;
    scalar keys %$buckets; # Reset the iterator.

    while (my ($key, $v) = each %$buckets) {
        push @{$batches[$n++ % $m]}, [$key, $v];
    }

    my $pm = $_[0]->_pm;
    $pm->run_on_finish(sub {$buckets->{$_->[0]} = $_->[1] for $_[5]->@*});

    for my $batch (@batches) {
        $pm->start and next;

        $_[0]->_process_bucket($_->[1], $words) for @$batch;

        $pm->finish(0, $batch);
    }
    $pm->wait_all_children;
}

sub _count_buckets {
    my($count, $buckets, $letters) = (0, $_[0]->buckets, '');
    scalar keys $_[0]->buckets->%*; # Reset the iterator.
    while(my($bucket_key, $bucket) = each %$buckets) {
        if($bucket->[COUNT] > $count) {
            $letters = $bucket_key;
            $count = $bucket->[COUNT];
        }
    }
    ($letters, $count);
}

1;

__DATA__
__C__

#define SIGT 0
#define COUNT 1

void _process_bucket( SV* self, SV* b, SV* words ) {

    // Unpack the arguments.
    AV* b_av     = (AV*) SvRV(b);
    SV* b_count  = (SV*) *(av_fetch(b_av,COUNT,0));
    AV* words_av = (AV*) SvRV(words);
    AV* bs_av    = (AV*) SvRV(*( av_fetch(b_av,SIGT,0)));

    uint64_t bs[4];
    bs[0] = ~SvIV(*(av_fetch(bs_av,0,0)));
    bs[1] = ~SvIV(*(av_fetch(bs_av,1,0)));
    bs[2] = ~SvIV(*(av_fetch(bs_av,2,0)));
    bs[3] = ~SvIV(*(av_fetch(bs_av,3,0)));

    size_t ix=0;
    size_t top = av_top_index(words_av);
    for( ; ix <= top; ++ix ) {

        AV* word_av = (AV*) SvRV(*(av_fetch(words_av,ix,0 )));
        AV* ws_av   = (AV*) SvRV(*(av_fetch(word_av,SIGT,0)));

        if(    !(SvIV(*(av_fetch(ws_av,0,0))) & bs[0])
            && !(SvIV(*(av_fetch(ws_av,1,0))) & bs[1])
            && !(SvIV(*(av_fetch(ws_av,2,0))) & bs[2])
            && !(SvIV(*(av_fetch(ws_av,3,0))) & bs[3])
        ) {
            sv_setiv(b_count, SvIV(b_count) + SvIV(*(av_fetch(word_av,COUNT,0))));
        }
    }
}
