package # hide from pause
    Object::Timekeeper::Implementation;

use strict;
use warnings;
use Carp qw//;
use Time::HiRes qw//;
use Text::SimpleTable;

sub new {
    my ($class, %args) = @_;
    my $self = bless +{
        _records => +[],
        _names   => +{},
    }, $class;
    $self->record('__BEGIN__', $args{_caller_depth} || 1);
    $self;
}

sub checked_intervel { $_[0]->{_checked_interval} }

sub records { $_[0]->{_records} }

sub record {
    my ($self, $name, $expr) = @_;
    push @{ $self->{_records} }, +{
        # info: package, filename, line
        info   => [ (caller($expr || 0))[0..2] ],
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
    $self->elapsed_since('__BEGIN__' => $time);
}

sub dump_log {
    my ($self, %params) = @_;
    my $records = $self->{_records};
    my %width = (
        label    => 5,
        interval => 8,
        elapsed  => 7,
        package  => 7,
        filename => 8,
        line     => 4,
    );
    my $unit = 1;
    $unit = 1000 if ($params{unit} || q{}) eq 'ms';
    my @rows;
    for my $index (0 .. (@{ $records } - 1)) {
        my $cur = $records->[$index];
        _update_col_length(\$width{label}, $cur->{label});
        _update_col_length(\$width{package}, $cur->{info}[0]);
        _update_col_length(\$width{filename}, $cur->{info}[1]);
        _update_col_length(\$width{line}, $cur->{info}[2]);
        if ($index == 0) {
            push @rows, [ $cur->{label}, q{}, q{}, @{$cur->{info}}[0 .. 2] ];
            next;
        }
        my $prev = $records->[$index - 1];
        my $interval = sprintf '%.6f',
            Time::HiRes::tv_interval($prev->{record}, $cur->{record}) * $unit;
        _update_col_length(\$width{interval}, $interval);
        my $elapsed = sprintf '%.6f',
            Time::HiRes::tv_interval($records->[0]{record}, $cur->{record}) * $unit;
        _update_col_length(\$width{elapsed}, $elapsed);
        push @rows, [
            defined $cur->{label} ? $cur->{label} : q{},
            $interval,
            $elapsed,
            @{$cur->{info}}[0 .. 2],
        ];
    }
    my $table = Text::SimpleTable->new(
        map { [ $width{$_}, $_ ] }
            qw/label interval elapsed package filename line/,
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
