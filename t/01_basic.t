use strict;
use Test::More;

use Time::HiRes qw//;

BEGIN { $ENV{ENABLE_TIMEKEEPER}++ }

use Object::Timekeeper;

ok my $tk = Object::Timekeeper->instance, 'create Object::Timekeeper instance';

ok ! $tk->disabled, 'enabled Object::Timekeeper';

ok $tk->record;

Time::HiRes::sleep 0.001;

ok $tk->elapsed_since_previous(0.001),
    sprintf 'elapsed time since previous: 0.001 sec <= %s', $tk->checked_intervel;

ok ! $tk->elapsed_since_previous(1),
    sprintf 'elapsed time since previous: %s < 1 sec', $tk->checked_intervel;

ok $tk->record('foobar');

Time::HiRes::sleep 0.001;

ok $tk->elapsed_since(foobar => 0.001),
    sprintf 'elapsed time since "foobar": 0.001 sec <= %s', $tk->checked_intervel;

ok ! $tk->elapsed_since(foobar => 1),
    sprintf 'elapsed time since "foobar": 0.001 %s < 1 sec', $tk->checked_intervel;

ok ! $tk->elapsed_since_beginning(1),
    sprintf 'elapsed time since beginning: %s < 1 sec', $tk->checked_intervel;

is $tk->elapsed_since_beginning, $tk->checked_intervel,
   sprintf 'elapsed time since beginning: %s', $tk->checked_intervel;

TODO: {
    local $TODO = <<__APOLOGY__;
The format of the log was not decided.
And think path of file is extreme length...
__APOLOGY__

    my $LOG_REGEX = <<__LOG_REGEX__;
__LOG_REGEX__

    like $tk->dump_log(unit => 'ms'), qr{^$LOG_REGEX$}ms;
};

done_testing;
