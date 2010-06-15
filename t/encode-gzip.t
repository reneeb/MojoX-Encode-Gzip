#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use FindBin '$Bin';
use lib "$Bin/lib";
use MojoX::Encode::Gzip;
use Mojo::Transaction::HTTP;
use Mojo::Message::Response;
use Mojo::Headers;

open my $fh, "<$Bin/public/gzippable.txt" || die "can't open: $!";

my $tx =  Mojo::Transaction::HTTP->new(
    res => Mojo::Message::Response->new
           ->code(200)
           ->body( do { local $/ = <$fh> } )
           ->headers( Mojo::Headers->new->content_type('text/plain') )
);
my $res = $tx->res;

{
    my $test= "Pre-check";
    is($tx->error,undef,"$test: no tx error");
    is($res->code, 200, "$test: starting with a 200 code");
    is($res->headers->content_type, "text/plain", "$test: Starting with text/plain");
    ok( ($res->body_size > 500), "$test: body_length > 500");

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
    ok( ($tx->res->body_size < 500), "$test: body shrank");

}
