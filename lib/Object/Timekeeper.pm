package Object::Timekeeper;
use strict;
use warnings;
use 5.008005;
our $VERSION = '0.012';

use Scope::Container;
use Object::Timekeeper::Implementation;

my ($enabled, %dummy);

BEGIN {
    $enabled = $ENV{ENABLE_TIMEKEEPER};
    %dummy = map { $_ => /(^dump|logs?$)/ ? '' : undef }
        keys %{*Object::Timekeeper::Implementation::};
    delete @dummy{qw/ new import BEGIN UNITCHECK CHECK INIT END /};
}

use constant +{
    %dummy,
    disabled => (! $enabled),
};

sub new { bless \(my $value), shift }

sub on_your_mark {
    my $class = shift;
    my $tk;
    my $scope = in_scope_container || start_scope_container;
    unless ($tk = scope_container('Object::Timekeeper')) {
        scope_container('Object::Timekeeper', $tk = $class->new(_caller_depth => 2));
    }
    return $tk;
}

*instance = \&Object::Timekeeper::on_your_mark;

if ($enabled) {
    no strict 'refs';
    while (my ($sub, $code) = each %{*Object::Timekeeper::Implementation::}) {
        next if $sub =~ /^(?:BEGIN UNITCHECK CHECK INIT END|)$/;
        *{"Object::Timekeeper::$sub"} = $code;
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Object::Timekeeper - careless timekeeper for your application

=head1 SYNOPSIS

  BEGIN { $ENV{ENABLE_TIMEKEEPER}++ }

  use Object::Timekeeper;
  
  my $timekeeper = Object::Timekeeper->instance;
  
  # check point
  $timekeeper->record;
  
  # Processing which requires time
  do {
      sleep int(rand() * 10);
  };
  
  if ($timekeeper->elapsed_since_previous(5)) {
      $your_logger->info($timekeeper->checked_intervel);
  }
  
  $timekeeper->record;
  
  # over 50 ms?
  $timekeeper->elapsed_since_beginning(0.05)
      or die;

=head1 DESCRIPTION

Object::Timekeeper is careless timekeeper for your application.

B<THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE>.

The B<ENABLE_TIMEKEEPER> env variable needs to be true in order to use this module.

=head1 METHODS

=head2 instance

  my $joshi_manager = Object::Timekeeper->instance;

=head2 record

  $joshi_manager->record;
  
  $joshi_manager->record('on your mark, set'); # named check-point

=head2 elapsed_since_previous

  if ($joshi_manager->elapsed_since_previous(0.05)) { # over 50 ms
      $your_logger->info('Run faster!');
  }

=head2 elapsed_since

  if ($joshi_manager->elapsed_since('on your mark, set')) {
      $your_logger->info('lap time: ' . $joshi_manager->checked_intervel);
  }

=head2 elapsed_since_beginning

  if ($joshi_manager->elapsed_since_beginning(0.1)) { # over 100 ms
      $your_logger->info('This half-wit!');
  }

=head2 dump_log

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Satoshi Ohkubo

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
