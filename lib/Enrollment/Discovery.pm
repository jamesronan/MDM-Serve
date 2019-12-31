package Enrollment::Discovery;
use strict;
use warnings FATAL => 'all';

use Try::Tiny;
use Data::Dump;
use File::Basename;

use XML::LibXML;
use XML::LibXML::XPathContext;

my $schemaDir        = File::Basename::dirname(__FILE__) . '/../../xml/schema/';
my $schemaFileName   = 'Discovery.xsd';
my $templateDir      = File::Basename::dirname(__FILE__) . '/../../xml/template/';
my $templateFileName = 'DiscoverResponse.xml';

# Everything we're gonna need t process the XML
my $xmlNamespace ='http://schemas.microsoft.com/windows/management/2012/01/enrollment';
my $xmlNamespacePrefix = 'enroll';
my $xmlRequestXPath    = "//$xmlNamespacePrefix:Discover";
my $xmlResponseXPath   = "//$xmlNamespacePrefix:DiscoverResponse";

sub new {
    my ($schema, $template);
    # Load XML schema from disk
    try {
        $schema = XML::LibXML::Schema->new(
            location => $schemaDir.$schemaFileName
            );
    } catch {
        die "ERROR: Failed to load schema at - "
            . $schemaDir.$schemaFileName;
    };

    # Load the reponse template from disk
    try {
        $template = XML::LibXML->load_xml(
            location => $templateDir.$templateFileName
            );
    } catch {
        die "ERROR: Failed to load response template - "
            . $templateDir.$templateFileName;
    };

    return bless {
        schema   => $schema,
        template => $template,
        }, __PACKAGE__;
}

sub parseRequest {
    my ($self, $request) = @_;

    my $xml;

    try {
        $xml = XML::LibXML->load_xml(string => $request);
    } catch {
        die "ERROR: Invalid client XML - $_";
    };

    # Now we extract the specific part of the message we actually want into an
    # XPathContext XML object, it acts just like a regular XML object.
    my $xpc = XML::LibXML::XPathContext->new($xml);
    $xpc->registerNs($xmlNamespacePrefix,$xmlNamespace);

    # Attempt to validate the input
    try {
        $self->{schema}->validate($xpc->findnodes($xmlRequestXPath));
    } catch {
        die "ERROR: Validation failed - $_";
    };

    # Save the extracted XML for later use
    $self->{'xpath'} = $xpc;
}

# Clients can request 1-3 types of supported authentication, we need to compare
# this against the list we're willing to support so we can respond properly.
# Right now we only want to support 'OnPremise'
# TODO: Read this from some kind of configuration
sub bestSupportedAuthType {
    my $self = shift;

    my @clientAuth = map{$_->to_literal();}
        $self->{'xpath'}->findnodes("//$xmlNamespacePrefix:AuthPolicy");

    if( grep(/^OnPremise$/,@clientAuth) ){
        return 'OnPremise';
    } else {
        return undef;
    }
}

# Use the XSD to generate a generic response, and then depending on the auth
# type we've been given we can customise bits, the only thing that comes to
# mind right now is AuthenticationServiceUrl for 'Federated' clients.
sub buildResponseForAuthType {
    my ($self, $authType) = @_;
    
    # TODO: be less dirty
    my $hostname   = "https://EnterpriseEnrollment.home.abablabab.co.uk";
    my $authURL    = "/EnrollmentServer/Authentication.svc";
    my $policyURL  = "/EnrollmentServer/Policy.svc";
    my $serviceURL = "/EnrollmentServer/Token.svc";

    # We can use the same xpath technique we used with on the incoming XML
    my $xml = $self->{'template'};
    my $xpc = XML::LibXML::XPathContext->new($xml);
    $xpc->registerNs($xmlNamespacePrefix,$xmlNamespace);

    my ($node,$text);
    # We need to set the AuthPolicy to one we want to do
    ($node) = $xpc->findnodes("//$xmlNamespacePrefix:AuthPolicy");
    ($node->firstChild)->setData($authType);

    # Now we need to set the URLs we want to point the clients to
    ($node) = $xpc->findnodes("//$xmlNamespacePrefix:AuthenticationServiceUrl");
    ($node->firstChild)->setData($hostname.$authURL);
    ($node) = $xpc->findnodes("//$xmlNamespacePrefix:EnrollmentPolicyServiceUrl");
    ($node->firstChild)->setData($hostname.$policyURL);
    ($node) = $xpc->findnodes("//$xmlNamespacePrefix:EnrollmentServiceUrl");
    ($node->firstChild)->setData($hostname.$serviceURL);

    # Now we validate what we've written to see if we've messed it up

    return $xml->toString();
}

#sub response {
#    my ($self, @params) = @_;
#
#    my $schema = XML::Compile::Schema->new($schema_dir . '/discovery.xsd');
#    my $response_element = ($schema->elements)[1]; # Response.
#
#    my $response_data = eval $schema->template('PERL', $response_element);
#
#    my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
#    my $write  = $schema->compile(WRITER => $response_element);
#    my $xml    = $write->($doc, $response_data);
#
#    $doc->setDocumentElement($xml);
#
#    return $doc->toString(1); # 1 indicates "pretty print"
#}

1;
