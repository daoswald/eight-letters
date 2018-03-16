package EightLetters;

=head1 NAME

EightLetters - Perl module to calculate which eight letter word spells the most words in a dictionary.

=cut

use integer;
use Moo;
use Inline C => 'DATA';
use Inline C => Config => ccflagsex => '-Ofast';
use Parallel::ForkManager;
use Sys::Info;
no warnings 'experimental::postderef';
use feature 'postderef';

our $VERSION = '2.0';

use constant CORE_MULTIPLIER => 3;  # In testing, 2 is better on an i5 with 4 cores,
                                    # 3 seems better on i7 with 4 cores, 8 logical.
has dict_path       => (is => 'ro',);
has count           => (is => 'lazy');
has letters         => (is => 'lazy');
has buckets         => (is => 'rw', default => sub {{}});
has words           => (is => 'rw', default => sub {{}});
has _count_internal => (is => 'rw');

sub _build_count {
    $_[0]->letters;
    $_[0]->_count_internal;
}

sub _signature {
        my($bv, @hist) = ("\0"x256, (0)x26); # Zero bit-vector, histograms.
        $hist[ord() - 97]++ for unpack '(A)*', $_[0];  # ord('a') == 97.
        for (0 .. $#hist) {
            vec($bv, $hist[$_]*26+$_, 1) = 1 while $hist[$_]--;
        }
        [unpack 'Q4', $bv];
}

sub _organize_words {
    my($b, $w) = ($_[0]->buckets, $_[0]->words);
    for (map {(m/^([a-z]{1,8})\b/ && $1)||()} do {open my $fh, '<', $_[0]->dict_path; <$fh>}) {
        my ($letters, $ref) = (
            join('', sort unpack '(A)*'),
            (8 == length) ? $b : $w,
        );
        $ref->{$letters} = [_signature($_), 0]
            unless exists $ref->{$letters};
        $ref->{$letters}[1]++;
    }
}

sub _build_letters {
    my $self = shift;

    $self->_organize_words;
    $self->_increment_counts;

    my($bucket_name, $count) = $self->_count_buckets;
    $self->_count_internal($count);
    $bucket_name;
}

sub _increment_counts {
    my ($words, $n, $m, $buckets, @batches)
        = ([values $_[0]->words->%*], 0, (Sys::Info->new->device('CPU')->count) * CORE_MULTIPLIER, $_[0]->buckets, ());

    while (my ($key, $v) = each %$buckets) {
        push @{$batches[$n++ % $m]}, [$key, $v];
    }

    my $pm = Parallel::ForkManager->new($m);
    $pm->set_waitpid_blocking_sleep(0);
    $pm->run_on_finish(sub {$buckets->{$_->[0]} = $_->[1] for $_[5]->@*});

    for my $batch (@batches) {
        $pm->start and next;
        $_[0]->_process_batch($batch, $words);      # $_[0]->_process_bucket($_->[1], $words) for @$batch; # Replaced with the _process_batch XS call.
        $pm->finish(0, $batch);
    }
    $pm->wait_all_children;
}

sub _count_buckets {
    my($count, $buckets, $letters) = (0, $_[0]->buckets, '');

    while(my($bucket_key, $bucket) = each %$buckets) {
        ($letters, $count) = ($bucket_key, $bucket->[1]) if $bucket->[1] > $count;
    }

    ($letters, $count);
}

1;

__DATA__
__C__

#define SIGT 0
#define COUNT 1
#define BUCKET 1

void _process_bucket( SV* self, SV* b, SV* words ) {
    AV* b_av     = (AV*) SvRV(b);
    AV* words_av = (AV*) SvRV(words);
    AV* bs_av    = (AV*) SvRV(*( av_fetch(b_av,SIGT,0)));

    uint64_t bs[4];
    bs[0]        = ~SvIV(*(av_fetch(bs_av,0,0)));
    bs[1]        = ~SvIV(*(av_fetch(bs_av,1,0)));
    bs[2]        = ~SvIV(*(av_fetch(bs_av,2,0)));
    bs[3]        = ~SvIV(*(av_fetch(bs_av,3,0)));

    size_t top   = av_top_index(words_av);
    size_t ix    = 0;

    for(ix = 0; ix <= top; ++ix ) {
        AV* word_av = (AV*) SvRV(*(av_fetch(words_av,ix,0 )));
        AV* ws_av   = (AV*) SvRV(*(av_fetch(word_av,SIGT,0)));

        if(    !(SvIV(*(av_fetch(ws_av,0,0))) & bs[0])
            && !(SvIV(*(av_fetch(ws_av,1,0))) & bs[1])
            && !(SvIV(*(av_fetch(ws_av,2,0))) & bs[2])
            && !(SvIV(*(av_fetch(ws_av,3,0))) & bs[3])
        ) {
            SV* b_count = (SV*) *(av_fetch(b_av,COUNT,0));
            sv_setiv(b_count, SvIV(b_count) + SvIV(*(av_fetch(word_av,COUNT,0))));
        }
    }
}

void _process_batch(SV* self, SV* batch, SV* words) {
    AV*    batch_av  = (AV*) SvRV(batch);
    size_t batch_top = av_top_index(batch_av);

    size_t ix = 0;
    for (ix = 0; ix <= batch_top; ++ix) {
        SV* bucket = *(av_fetch((AV*) SvRV(*(av_fetch(batch_av, ix, 0))),BUCKET,0));
        _process_bucket(self,bucket,words);
    }
}

