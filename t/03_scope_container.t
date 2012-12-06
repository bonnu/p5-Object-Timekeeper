use strict;
use Test::More;

BEGIN { $ENV{ENABLE_TIMEKEEPER}++ }

use Object::Timekeeper;

use Scope::Container;

my $app = sub {
    my $tk = Object::Timekeeper->instance;
    $tk->record('application.in_application');
    is 3, 0 + @{ $tk->records };
};

{ # middleware like
    my $scope = start_scope_container;

    my $before_scope = Object::Timekeeper->instance;
    is 1, 0 + @{ $before_scope->records };

    sub {
        my $tk = Object::Timekeeper->instance;
        $tk->record('middleware.before_application');
        $app->();
        $tk->record('middleware.after_application');
        is 4, 0 + @{ $tk->records };
    }->();

    my $after_scope = Object::Timekeeper->instance;
    is 4, 0 + @{ $after_scope->records };
}

my $out_of_scope = Object::Timekeeper->instance;
is 1, 0 + @{ $out_of_scope->records };

done_testing;
