package App::MProxyD;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

use Getopt::Long;
use Net::MPD;
use Proc::Daemon;

use App::MProxyD::Server;

sub new {
  my ($class, @options) = @_;

  my $self = bless {
    action  => '',
    daemon  => undef,
    verbose => 2,
    port    => 6600,
    host    => '*',
    user    => undef,
    group   => undef,
    @options,
  }, $class;
}

sub say {
  my ($self, @args) = @_;

  say @args if $self->{verbose};
}

sub parse_options {
  my ($self, @options) = @_;

  local @ARGV = @options;

  Getopt::Long::Configure('bundling');
  Getopt::Long::GetOptions(
    'D|daemon!'  => \$self->{daemon},
    'V|version'  => sub { $self->{action} = 'show_version' },
    'v|verbose+' => \$self->{verbose},
    'q|quiet'    => sub { $self->{verbose} = 0 },
    'h|help'     => sub { $self->{action} = 'show_help' },
    'p|port=i'   => \$self->{port},
    'H|host=s'   => \$self->{host},
    'u|user=s'   => \$self->{user},
    'g|group=s'  => \$self->{group},
  );
}

sub execute {
  my ($self) = @_;

  if (my $action = $self->{action}) {
    $self->$action() and return 1;
  }

  if ($self->{daemon}) {
    $self->say('Forking to background');
    Proc::Daemon::Init;
  }

  App::MProxyD::Server->run(
    log_level => $self->{verbose},
    port      => $self->{port},
    host      => $self->{host},
    proto     => 'tcp',
    user      => $self->{user},
    group     => $self->{group},
  );
}

sub show_version {
  say "mproxyd (App::MProxyD) version $VERSION";
  say "perl version $]";
}

sub show_help {
  print <<HELP;
Usage: mproxyd [options]

Options:
  -D,--daemon   Run server in background
  -v,--verbose  Increase chattiness
  -q,--quiet    Silence

  -p,--port     Port number to listen on
  -H,--host     Host to bind to
  -u,--user     User id or name to use for daemon
  -g,--group    Group id or name to use for daemon

  -V,--version  Show version information and exit
  -h,--help     Show this help and exit
HELP
}

1;
__END__

=encoding utf-8

=head1 NAME

App::MProxyD - Proxy to several mpd servers

=head1 SYNOPSIS

  use App::MProxyD;

=head1 DESCRIPTION

App::MProxyD is a multiplexer for controlling several MPD instances as though
they were a single instance.

=head1 AUTHOR

Alan Berndt E<lt>alan@eatabrick.orgE<gt>

=head1 COPYRIGHT

Copyright 2014- Alan Berndt

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
