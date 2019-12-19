#!/usr/bin/env perl

use strict;

use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;

my $xsd = 'schema/enrollment.xsd';

my $schema = XML::Compile::Schema->new($xsd);

# This will print a very basic description of what the schema describes
$schema->printIndex();

# this will print a hash template that will show you how to construct a
# hash that will be used to construct a valid XML file.
#
# Note: the second argument must match the root-level element of the XML
# document.  I'm not quite sure why it's required here.
my $element_type = ($schema->elements)[1];
warn $schema->template('PERL', $element_type);

my $data = {
    # is an unnamed complex
    # all of DiscoverResult

    # is an unnamed complex
    DiscoverResult =>
    { # all of AuthPolicy, EnrollmentPolicyServiceUrl,
        #   EnrollmentServiceUrl, AuthenticationServiceUrl, EnrollmentVersion

        # is a xs:string
        # Enum: Certificate Federated OnPremise
        AuthPolicy => "Certificate",

        # is a xs:anyURI
        # is nillable, hence value or NIL
        # is optional
        EnrollmentPolicyServiceUrl => "http://example.com",

        # is a xs:anyURI
        EnrollmentServiceUrl => "http://example.com",

        # is a xs:anyURI
        # is nillable, hence value or NIL
        # is optional
        AuthenticationServiceUrl => "http://example.com",

        # is a xs:decimal
        # is nillable, hence value or NIL
        # is optional
        EnrollmentVersion => 3.1415,
    },
};

my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
my $write  = $schema->compile(WRITER => $element_type);
my $xml    = $write->($doc, $data);

$doc->setDocumentElement($xml);

print $doc->toString(1); # 1 indicates "pretty print"
