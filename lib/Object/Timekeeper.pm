package Object::Timekeeper;
use strict;
use warnings;
use 5.008005;
our $VERSION = '0.01';

use Object::Timekeeper::Implementation;

my ($disabled, %dummy);

BEGIN {
    $disabled = $ENV{DISABLE_TIMEKEEPER};
    %dummy = map { $_ => /(^dump|logs?$)/ ? '' : undef }
        keys %{*Object::Timekeeper::Implementation::};
    delete @dummy{qw/ new import BEGIN UNITCHECK CHECK INIT END /};
}

use constant +{
    %dummy,
    disabled => $disabled,
};

sub new { bless \(my $value), shift }

sub on_your_mark { shift->new }

*instance = \&Object::Timekeeper::on_your_mark;

unless ($disabled) {
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
