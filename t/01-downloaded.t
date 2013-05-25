use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;
use Test::Warnings;

use Plack::Test;
use HTTP::Request::Common;
use Plack::App::BeanstalkConsole;

my $app = Plack::App::BeanstalkConsole->new->to_app;

foreach my $url (
    '/public/',
)
{
    my $http_request = GET $url;

    my $response = test_psgi($app, sub { shift->($http_request) });

    is($response->code, '200', 'can successfully contact the app');
}


