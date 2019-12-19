package Enrollment::Server;
use strict;
use warnings FATAL => 'all';

use Data::Dump;
use XML::Compile::Schema;
use XML::LibXML::Reader;


my $schema_dir = File::Basename::dirname(__FILE__) . '/../../schema';

sub new {
    return bless {}, __PACKAGE__;
}

sub discoveryResponse {
    my ($self, @params) = @_;


    my $schema = XML::Compile::Schema->new($schema_dir . '/enrollment.xsd');
    my $response_element = ($schema->elements)[1]; # Response.

    my $response_data = eval $schema->template('PERL', $response_element);

    my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $write  = $schema->compile(WRITER => $response_element);
    my $xml    = $write->($doc, $response_data);

    $doc->setDocumentElement($xml);

    return $doc->toString(1); # 1 indicates "pretty print"
}

1;
