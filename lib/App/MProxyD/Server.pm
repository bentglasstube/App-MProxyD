package App::MProxyD::Server;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.18.0';

use base 'Net::Server';

use Net::MPD;
use Text::ParseWords;

sub _error {
  my ($error, $line, $command, $message) = @_;
  return "ACK [$error\@$line] {$command} $message";
}

sub process_request {
  my $self = shift;

  say "OK MPD $VERSION";

  $self->log(3, 'Client connected');

  while (<STDIN>) {
    s/[\r\n]+$//;    # super chomp
    $self->log(4, "Received: $_");

    my ($command, @args) = quotewords(qr/\s+/, undef, $_);
    last if $command eq 'close';

    if (my $method = $self->can("cmd_$command")) {
      $method->(@args);
    } else {
      # TODO send command to clients
    }
  }

  $self->log(3, 'Client disconnected');
}

sub cmd_register {
  my ($self, $connection, $stream_url) = @_;

  if (exists $self->{__mpd_clients}{$connection}) {
    say _error(0, 0, 'register', "There is already a client registered for $connection");
    return;
  }

  eval {
    my $mpd = Net::MPD->connect($connection);

    $self->{__mpd_clients}{$connection} = $mpd;
  }
}

sub cmd_unregister {
  my ($self, $host) = @_;

  if ($self->{client
}

sub cmd_clients {
  my ($self) = @_;

  # TODO list clients
}

sub cmd_stream_url {
  my ($self) = @_;

  # TODO pick random client and return stream url
}

1;
