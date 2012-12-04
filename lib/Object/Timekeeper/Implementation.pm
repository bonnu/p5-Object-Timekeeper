package # hide from pause
    Object::Timekeeper::Implementation;

use strict;
use warnings;
use Carp qw//;
use Time::HiRes qw//;
use Text::SimpleTable;

sub new {
    my $class = shift;
    my $self = bless +{
        _records => +[],
        _names   => +{},
    }, $class;
    $self->record('[BEGINNING]');
    $self;
}

sub checked_intervel {
    $_[0]->{_checked_interval}
}

sub record {
    my ($self, $name) = @_;
    push @{ $self->{_records} }, +{
        # info: package, filename, line
        info   => [ (caller 0)[0..2] ],
        record => [ Time::HiRes::gettimeofday ],
    };
    if (defined $name) {
        exists $self->{_names}{$name}
            && Carp::carp sprintf 'name "%s" already registered.', $name;
        my $num = @{ $self->{_records} };
        $self->{_names}{$name} = $num;
        $self->{_records}[ $num - 1 ]{label} = $name;
    }
    1
}

sub elapsed_since {
    my ($self, $name, $time) = @_;
    my $num = $self->{_names}{$name} || return;
    my $elapsed = $self->{_checked_interval} =
        sprintf '%.6f', Time::HiRes::tv_interval($self->{_records}[ $num - 1 ]{record});
    defined $time ? ($elapsed >= $time) : $elapsed;
}

sub elapsed_since_previous {
    my ($self, $time) = @_;
    my $num = @{ $self->{_records} } || return;
    my $elapsed = $self->{_checked_interval} =
        sprintf '%.6f', Time::HiRes::tv_interval($self->{_records}[ $num - 1 ]{record});
    defined $time ? ($elapsed >= $time) : $elapsed;
}

sub elapsed_since_beginning {
    my ($self, $time) = @_;
    $self->elapsed_since('[BEGINNING]' => $time);
}

sub dump_log {
    my $self = shift;
    my $records = $self->{_records};
    my %width = (
        label     => 5,
        package   => 7,
        filename  => 8, 
        line      => 4,
        previous  => 8,
        beginning => 9,
    );
    my @rows;
    for my $index (0 .. (@{ $records } - 1)) {
        my $cur = $records->[$index];
        _update_col_length(\$width{label}, $cur->{label});
        _update_col_length(\$width{package}, $cur->{info}[0]);
        _update_col_length(\$width{filename}, $cur->{info}[1]);
        _update_col_length(\$width{line}, $cur->{info}[2]);
        if ($index == 0) {
            push @rows, [ $cur->{label}, @{$cur->{info}}[0 .. 2], q{}, q{} ];
            next;
        }
        my $prev = $records->[$index - 1];
        my $prev_t = sprintf '%.6f',
            Time::HiRes::tv_interval($prev->{record}, $cur->{record});
        _update_col_length(\$width{previous}, $prev_t);
        my $begin_t = sprintf '%.6f',
            Time::HiRes::tv_interval($records->[0]{record}, $cur->{record});
        _update_col_length(\$width{beginning}, $begin_t);
        push @rows, [
            defined $cur->{label} ? $cur->{label} : q{},
            @{$cur->{info}}[0 .. 2],
            $prev_t,
            $begin_t,
        ];
    }
    my $table = Text::SimpleTable->new(
        map { [ $width{$_}, $_ ] }
            qw/label package filename line previous beginning/,
    );
    $table->row(@{ $_ }) for @rows;
    return $table->draw;
}

sub _update_col_length {
    my ($base_ref, $value) = @_;
    $$base_ref = length $value if $value && $$base_ref < length $value;
}

1;
__END__
