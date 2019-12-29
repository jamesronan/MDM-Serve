package MDMServer;
use Dancer ':syntax';

use Try::Tiny;
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

    my ($enrollDiscovery,$authType,$response);

    # Set up object and load templates from disk
    try {
        $enrollDiscovery = Enrollment::Discovery->new();
    } catch {
        send_error($_,500);
    };

    # See if the client sent a valid request
    try {
        $enrollDiscovery->parseRequest(request->body());
    } catch {
        send_error($_,400);
    };

    # See if we can service the clients request
    try {
        $authType = $enrollDiscovery->bestSupportedAuthType();
    } catch {
        send_error($_,501);
    };

    # Build a response for the client
    # I have no idea which error code we should return if this goes wrong,
    # yet...
    try {
        $response = $enrollDiscovery->buildResponseForAuthType($authType);
    } catch {
        send_error($_,500);
    };
    return $response;
};

# TODO: implement for 2FA enrollment
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
