use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'DateTime::Format::Japanese',
    dist_name => 'DateTime-Format-Japanese',
    license => 'perl',
    requires => {
        'DateTime'                  => 0,
        'DateTime::Format::Builder' => 0,
        'DateTime::Calendar::Japanese::Era' => '0.04',
        'Params::Validate'          => 0,
        'perl'                      => '5.8.1',
    },
    build_requires => {
        'Test::More' => 0
    },
    sign => 1,
    create_makefile_pl => 'passthrough'
);
$build->create_build_script;
