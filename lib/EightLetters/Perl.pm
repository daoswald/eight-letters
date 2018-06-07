package EightLetters::Perl;

use Moo;

use constant TARGET_LENGTH => 8;

has dict_path => (is => 'ro');
has count     => (is => 'lazy');
has letters   => (is => 'lazy');
has _buckets   => (is => 'rw', default => sub { {} });
has _words     => (is => 'lazy');
our $count = 0;
sub _build__words {
    my $self = shift;
    my $dict_path = $self->dict_path;
    open my $fh, '<', $dict_path or die "Cannot open $dict_path: $!\n";
    my @words = map {(m{^([a-z]{1,8})\b} && $1) || ()} <$fh>;
    return \@words;
}

sub _make_bucket {
    my ($self, $key) = @_;

    my %bucket;
    $bucket{$_}++ foreach split //, $key;
    $bucket{'count'} = 0;
    return \%bucket;
}

sub _make_key {
    my ($self, $word) = @_;
    my $key = join '', sort {$a cmp $b} split //, $word;
    return $key;
}

sub _bucket_fetch {
    my ($self, $key) = @_;
    return $self->_bucket_exists($key) ? $self->_buckets->{$key} : ();
}

sub _bucket_add {
    my ($self, $key) = @_;
    die "Bucket $key already exists, cannot add.\n" if exists $self->_buckets->{$key};
    $self->_buckets->{$key} = $self->_make_bucket($key);
}

sub _bucket_increment {
    my ($self, $key) = @_;
    $self->_buckets->{$key}->{'count'}++;
    return $self->_buckets->{$key}->{'count'};
}

sub _bucket_exists {
    my $self = shift;
    return exists $self->_buckets->{shift()};
}

sub _build_count {
    my $self = shift;
    my ($letters, $count) = $self->_build_internal;
    return $count;
}

sub _build_letters {
    my $self = shift;
    my ($letters, $count) = $self->_build_internal;
    return $letters;
}

sub _build_internal {
    my $self = shift;
    return @{$self->{'_internal_cache'}}
        if exists $self->{'_internal_cache'} && ref $self->{'_internal_cache'};

    my @rest;

    foreach my $word (@{$self->_words}) {
        if(length $word == TARGET_LENGTH) {
            my $key = $self->_make_key($word);
            $self->_bucket_add($key) unless $self->_bucket_exists($key);
            $self->_bucket_increment($key);
        }
        else {
            push @rest, $self->_make_bucket($self->_make_key($word));
        }
    }

    foreach my $bucket_key (keys %{$self->_buckets}) {
        foreach my $word_bucket (@rest) {
            if ($self->_word_fits_bucket($word_bucket, $bucket_key)) {
                $self->_bucket_increment($bucket_key);
            }
        }
    }

    # TODO: This could be a _max_count_calc() method.
    my ($max_count, $max_key) = (0,'');
    foreach my $bucket_key (keys %{$self->_buckets}) {
        my $bucket = $self->_bucket_fetch($bucket_key);
        if ($bucket->{'count'} > $max_count) {
            $max_count = $bucket->{'count'};
            $max_key   = $bucket_key;
        }
    }

    $self->{'_internal_cache'} = [$max_key, $max_count];
    return ($max_key, $max_count);
}


sub _word_fits_bucket {
    my ($self, $word_bucket, $bucket_key) = @_;
    my $bucket = $self->_bucket_fetch($bucket_key);
    foreach my $key (keys %{$word_bucket}) {
        next if $key eq 'count';
        return 0 if !exists $bucket->{$key} || $word_bucket->{$key} > $bucket->{$key};
    }
    return 1;
}

1;
