package Enrollment::Policy;
use strict;
use warnings FATAL => 'all';

use Try::Tiny;
use Data::Dump;
use File::Basename;

use XML::LibXML;
use XML::LibXML::XPathContext;

#my $schemaDir        = File::Basename::dirname(__FILE__) . '/../../xml/schema/';
#my $schemaFileName   = 'Discovery.xsd';
my $templateDir      = File::Basename::dirname(__FILE__) . '/../../xml/template/';
my $templateFileName = 'PolicyResponse.xml';

sub new {
    # We're gonna do this the dirtiest way we can think of to begin with,
    # straight up return the file from the disk
    my $response;
    try {
        $response = XML::LibXML->load_xml(
            location => $templateDir.$templateFileName
        );
    } catch {
        die "ERROR: Failed to load response - "
            . $templateDir.$templateFileName;
    };

    return bless {
        'response' => $response,
        }, __PACKAGE__;
}

sub validateRequest {
    return 1;
}

sub validateResponse {
    return 1;
}

# TODO: we need to think about if this is an initial or update request
# according to the doco (MS-XCEP) there is a different field set depending on if
# the LastUpdateTime field is present. There IS a documented 'nothing has
# changed' response we can give for testing. But for now we assume this is
# initial enroll!
sub updatePolicy {
    return 0;
}

sub newPolicy {
    return 0;
}

1;
