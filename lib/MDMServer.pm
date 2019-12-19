package MDMServer;
use Dancer ':syntax';

use Enrollment::Server;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any '/EnrollmentServer/Discovery.svc' => sub {

    my $enrollment_server = Enrollment::Server->new();

    my $params = params();
    debug "Params: " . Data::Dump::dump($params);

    debug "Body: " . request->body();

    return $enrollment_server->discoveryResponse();


    #template 'discover', {
    #    types => [
    #        $enrollment_server->discoveryResponse()
    #    ]
    #};
};

1;
