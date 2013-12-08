use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Warnings;
use Plack::Test;
use HTTP::Request::Common;

BEGIN {
    if (-d '.git')
    {
        die 'missing t/app!' unless -d 't/app' and glob("t/app/*");
        note 'creating hard link: share -> t/app';
        link 't/app', 'share';
        END { unlink 'share' };
        require Test::File::ShareDir;
        Test::File::ShareDir->import(-share => { -dist => { 'Plack-App-BeanstalkConsole' => 'share' }});
    }
}

use Plack::App::BeanstalkConsole;

my $app = Plack::App::BeanstalkConsole->new->to_app;

foreach my $url (
    '/',
    '/public/',
)
{
    my $http_request = GET $url;

    # TODO: Plack::Test should do this.
    my $response;
    do {
        $response = test_psgi($app, sub { shift->($http_request) });
        $http_request->uri($response->header('location')) if $response->code eq '301';
    }
    until $response->code ne '301';

    is($response->code, '200', 'can successfully contact the app');
}

done_testing;
