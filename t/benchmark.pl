use strict;
use warnings;
use Benchmark qw/cmpthese timethese/;

use Object::Timekeeper;

my $keeper = Object::Timekeeper->instance;

$keeper->record('hoge');

cmpthese(500000, {
    'keeper' => sub { $keeper->elapsed_since_previous },
});
