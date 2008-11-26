use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MojoX::Encode::Gzip',
    AUTHOR              => 'Mark Stosberg <mark@summersault.com>',
    VERSION_FROM        => 'lib/MojoX/Encode/Gzip.pm',
    ABSTRACT_FROM       => 'lib/MojoX/Encode/Gzip.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'     => 0,
        'Compress::Zlib' => 0,
        'Mojo'           => '0.8.7'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MojoX-Encode-Gzip-*' },
);
