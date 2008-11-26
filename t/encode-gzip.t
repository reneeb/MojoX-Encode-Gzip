#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use FindBin '$Bin';
use lib "$Bin/lib";
use Mojo::Transaction;
use MojoX::Dispatcher::Static;
use MojoX::Encode::Gzip;

my $tx = Mojo::Transaction->new_get('/gzippable.txt' );

    MojoX::Dispatcher::Static
        ->new(root => "$Bin/public")
        ->dispatch($tx);
my $res = $tx->res;

{
    my $test= "Pre-check";
    is($res->code, 200, "$test: starting with a 200 code"); 
    is($res->headers->content_type, "text/plain", "$test: Starting with text/plain"); 
    ok( ($res->body_length > 500), "$test: body_length > 500"); 

}

{
    my $test = "attempt with client request";
    MojoX::Encode::Gzip->new->maybe_gzip($tx); 
    is($res->code,   200, "$test: response code is 200");
    isnt($res->headers->header('Content-Encoding'), 'gzip', " $test: Content-Encoding isn't set to gzip"); 
}
{
    my $test = "client requests gzip, all systems go";
    $tx->req->headers->header('Accept-Encoding','gzip'); 
    MojoX::Encode::Gzip->new->maybe_gzip($tx); 
    is($tx->res->code,   200, "$test: response code is 200");
    is($tx->res->headers->header('Content-Encoding'), 'gzip', "$test: Content-Encoding is set to gzip"); 
    is($tx->res->headers->header('Vary'), 'Accept-Encoding', "$test: Vary is set to Accept-Encoding"); 
    unlike($tx->res->body, qr/gzipping/, "$test: plain text is no longer there"); 
    ok( ($tx->res->body_length < 500), "$test: body shrank"); 

} 
