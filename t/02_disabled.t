use strict;
use Test::More;

use Time::HiRes qw//;

use Object::Timekeeper;

ok my $tk = Object::Timekeeper->instance, 'create Object::Timekeeper instance';

ok $tk->disabled, 'disabled Object::Timekeeper';

is $tk->record, undef,
   '$obj->record does not function, return undef';

Time::HiRes::sleep 0.001;

is $tk->elapsed_since_previous(0.001), undef,
    'elapsed_since_previous does not function, return undef';

is $tk->elapsed_since_previous(1), undef,
    'elapsed_since_previous does not function, return undef';

is $tk->record('foobar'), undef,
   '$obj->record does not function, return undef';

Time::HiRes::sleep 0.001;

is $tk->elapsed_since(foobar => 0.001), undef,
    'elapsed_since(\'foobar\') does not function, return undef';

is $tk->elapsed_since(foobar => 1), undef,
    'elapsed_since(\'foobar\') does not function, return undef';

is $tk->elapsed_since_beginning(1), undef,
    'elapsed_since_beginning does not function, return undef';

is $tk->checked_intervel, undef,
    'checked_intervel does not function, return undef';

is $tk->dump_log, '';

done_testing;
