requires 'perl', '5.010';

requires 'Net::Server';

on test => sub {
  requires 'Test::More', '0.88';
};
