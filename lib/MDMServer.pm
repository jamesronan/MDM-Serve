package MDMServer;
use Dancer ':syntax';

use Enrollment::Discovery;
#use Enrollment::Authentication;
#use Enrollment::Policy;
#use Enrollment::Token;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

# Step 1: Discovery
# Discovery first step will be a GET request that expects any 200
get '/EnrollmentServer/Discovery.svc' => sub {
    return "OK"
};

post '/EnrollmentServer/Discovery.svc' => sub {

    my $params = params();
    debug "Params: " . Data::Dump::dump($params);
    debug "Body: "   . request->body();

    my $enrollDiscovery = Enrollment::Discovery->new(request->body());
    send_error("Invalid request",400) unless defined $enrollDiscovery;

    my $authType = $enrollDiscovery->bestSupportedAuthType();
    send_error("No supported AuthTypes",501) unless defined $authType;

    return $enrollDiscovery->buildResponseForAuthtype($authType);
};

# TODO: implement for 2FA enrolement
# Step 2: Extra autentication
# Only if the client is using 'Federated' authentication it will request an
# auth token from this address. This is useful specifically for avoiding
# allowing single factor enrollment. See [MS-MDE2(9.0)]:54,84
#post '/EnrollmentServer/Authentication.svc' {
#    my $enrollAuth = Enrollment::Authentication->new();
#
#    my $params = params();
#    debug "Params: " . Data::Dump::dump($params);
#    debug "Body: " . request->body();
#
#    return $enrollAuth->response();
#}

# Step 3: Provide policy for Enrollment
post '/EnrollmentServer/Policy.svc' => sub {

    my $enrollPolicy = Enrollment::Policy->new();

    my $params = params();
    debug "Params: " . Data::Dump::dump($params);
    debug "Body: " . request->body();

    return $enrollPolicy->response();
};

# Step 4: Request security token (i.e. an x509 Certificate)
post '/EnrollmentServer/Token.svc' => sub {

    my $enrollToken = Enrollment::Token->new();

    my $params = params();
    debug "Params: " . Data::Dump::dump($params);
    debug "Body: " . request->body();

    return $enrollToken->response();
};

1;
