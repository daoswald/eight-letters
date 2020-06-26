package EightLetters::MCE;

=head1 NAME

EightLetters::MCE - Perl module to calculate which eight letter word spells the most words in a dictionary.

=head1 CONTRIBUTORS

The adaptation from Parallel::ForkManager to MCE was provided
by Mario Roy.

=cut

use integer;
use Moo;

use Inline C => <<'EOC';
#define SIGT 0
#define COUNT 1
#define BUCKET 1

void _process_bucket(SV* self, SV* b, SV* words) {
    AV* b_av     = (AV*) SvRV(b);
    AV* words_av = (AV*) SvRV(words);
    AV* bs_av    = (AV*) SvRV(*(av_fetch(b_av,SIGT,0)));

    uint64_t bs[4] = {
        ~SvIV(*(av_fetch(bs_av,0,0))),
        ~SvIV(*(av_fetch(bs_av,1,0))),
        ~SvIV(*(av_fetch(bs_av,2,0))),
        ~SvIV(*(av_fetch(bs_av,3,0)))
    };

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

EOC
use Inline C => Config => ccflagsex => '-Ofast';

use MCE;

no warnings qw(experimental::postderef experimental::signatures);
use feature qw(postderef signatures);

our $VERSION = '2.0';

has dict_path       => (is => 'ro');
has core_multiplier => (is => 'ro', default => 6);
has _count_internal => (is => 'rw');
has [qw(count letters)] => (is => 'lazy');
has [qw(buckets words)] => (is => 'rw', default => sub {{}});

sub _build_count ($self) {
    $self->letters;
    $self->_count_internal;
}

sub _signature ($word) {
        my($bv, @hist) = ("\0"x256, (0)x26); # Zero bit-vector, histograms.
        $hist[ord() - 97]++ for unpack '(A)*', $word;  # ord('a') == 97.
        for (0 .. $#hist) {
            vec($bv, $hist[$_]*26+$_, 1) = 1 while $hist[$_]--;
        }
        [unpack 'Q4', $bv];
}

sub _organize_words ($self) {
    my($b, $w) = ($self->buckets, $self->words);
    for (map {(m/^([a-z]{1,8})\b/ && $1)||()} do {open my $fh, '<', $self->dict_path; <$fh>}) {
        my ($letters, $ref) = (
            join('', sort unpack '(A)*'),
            (8 == length) ? $b : $w,
        );
        $ref->{$letters} = [_signature($_), 0]
            unless exists $ref->{$letters};
        $ref->{$letters}[1]++;
    }
}

sub _build_letters ($self) {

    $self->_organize_words;
    $self->_increment_counts;

    my($bucket_name, $count) = $self->_count_buckets;
    $self->_count_internal($count);
    $bucket_name;
}

sub _increment_counts ($self) {
    my ($words, $n, $m, $buckets, @batches)
        = ([values $self->words->%*], 0, MCE::Util::get_ncpu() * $self->core_multiplier, $self->buckets, ());

    while (my ($key, $v) = each %$buckets) {
        push @{$batches[$n++ % $m]}, [$key, $v];
    }

    MCE->new(
        max_workers => $m,
        chunk_size  => 1,
        posix_exit  => 1,
        input_data  => \@batches,
        gather      => sub {
            $buckets->{$_->[0]} = $_->[1] for $_[0]->@*;
        },
        user_func   => sub {
            my ($mce, $chunk_ref, $chunk_id) = @_;
            my $batch = $chunk_ref->[0];
            $self->_process_batch($batch, $words);
            MCE->gather($batch);
        },
    )->run;
}

sub _count_buckets ($self) {
    my($count, $buckets, $letters) = (0, $self->buckets, '');

    while(my($bucket_key, $bucket) = each %$buckets) {
        ($letters, $count) = ($bucket_key, $bucket->[1]) if $bucket->[1] > $count;
    }

    ($letters, $count);
}

1;
