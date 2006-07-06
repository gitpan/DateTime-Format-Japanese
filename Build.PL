# $Id: /mirror/DateTime-Format-Japanese/Build.PL 1688 2006-07-06T10:00:51.388109Z lestrrat  $
#
# Copyright (c) 2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Module::Build;

my %requires = (
    'DateTime'                  => 0,
    'DateTime::Format::Builder' => 0,
    'DateTime::Calendar::Japanese::Era' => '0.07',
    'DateTime::Calendar::Japanese' => '0.05',
    'Encode'                    => 0,
    'Params::Validate'          => 0,
);

my $build = Module::Build->new(
    module_name => 'DateTime::Format::Japanese',
    dist_name => 'DateTime-Format-Japanese',
    dist_version_from => 'lib/DateTime/Format/Japanese.pm',
    license => 'perl',
    requires => \%requires,
    build_requires => {
        'Test::More' => 0
    },
    create_readme => 1,
    create_makefile_pl => 'traditional',
);

$build->create_build_script;
