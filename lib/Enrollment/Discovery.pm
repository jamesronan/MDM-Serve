package Enrollment::Discovery;
use strict;
use warnings FATAL => 'all';

use Data::Dump;
use XML::Compile::Schema;
use XML::LibXML::Reader;

use XML::LibXML;
use XML::LibXML::XPathContext;

my $schemaDir = File::Basename::dirname(__FILE__) . '/../../schema/';
my $schemaFileName = 'discovery.xsd';

# Everything we're gonna need t process the XML
my $xmlNamespace = 'http://schemas.microsoft.com/windows/management/2012/01/enrollment';
my $xmlNamespacePrefix = 'enroll';
my $xmlRequestXPath    = "//$xmlNamespacePrefix:Discover";
my $xmlResponseXPath   = "//$xmlNamespacePrefix:DiscoverResponse";

sub new {
    # Take the XML given from the client
    my ($class, $reqXML) = @_;
    my ($xml, $schema, $valid);

    eval {
        $xml = XML::LibXML->load_xml(string => $reqXML);
    } or do {
        #TODO output some kind of error internally
        return (undef,"ERROR: Invalid client XML - $@");
    };
    
    # Now we extract the specific part of the message we actually want
    my $xpc = XML::LibXML::XPathContext->new($xml);
    $xpc->registerNs($xmlNamespacePrefix,$xmlNamespace);

    # Load XML schema from disk
    eval {
        $schema = XML::LibXML::Schema->new(
            location => $schemaDir.$schemaFileName);
    } or do {
        #TODO output some kind of error internally
        return (undef,"ERROR: Failed to load schema - $@");
    };

    # Attempt to validate the input
    eval {
        $schema->validate($xpc->findnodes($xmlRequestXPath));
        1;
    } or do {
        #TODO output some kind of error internally
        return (undef,"ERROR: Validation failed - $@");
    };

    return bless {
        request => $xml,
        xpath   => $xpc,
        }, __PACKAGE__;
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

    # I guess we should load a template response?

    # Build response
    # Add the stuff for our server (where our paths are!)
    # Validate what we have against the XSD
    # return it
    return "sure";
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
