use strict;
use Module::Build;

my %requires = (
     'DateTime'                  => 0,
     'DateTime::Format::Builder' => 0,
     'DateTime::Calendar::Japanese::Era' => '0.04',
     'Params::Validate'          => 0,
     'perl'                      => '5.7',
);

my $do_trad = Module::Build->y_n(
    "  Would you like to install DateTime::Format::Japanese::Traditional to\n" .
    "  process traditional Japanese dates and DateTime::Calendar::Japanese?\n" .
    "\n" .
    "  Note that if you only plan to deal with modern Japanese dates (which\n" .
    "  are based on the Gregorian calendar) you do NOT need this module.\n" .
    "  Installing this module will add a significant amount of dependencies to\n" .
    "  install in your system if you don't already have\n" .
    "  DateTime::Calendar::Japanese installed.\n\n" .
    "  Install DateTime::Fromat::Japanese::Traditional?",
    "n"
);

if ($do_trad) {
    print "Adding DateTime::Calendar::Japanese into dependencies...\n";
    $requires{ 'DateTime::Calendar::Japanese' } = '0.05';
}

my $build = Module::Build->new(
    module_name => 'DateTime::Format::Japanese',
    dist_name => 'DateTime-Format-Japanese',
    license => 'perl',
    requires => \%requires,
    build_requires => {
        'Test::More' => 0
    },
    sign => 1,
    create_makefile_pl => 'passthrough'
);

# if we aren't installing DT::F::Japanese::Traditional, then we need
# to strip out the module and the traditional tests
if (! $do_trad) {
    my $pm_files = $build->find_pm_files;
    delete $pm_files->{ 'lib/DateTime/Format/Japanese/Traditional.pm' };
    $build->pm_files($pm_files);
    
    my $tests = $build->test_files;
    my @newtests = grep { !/traditional/ } @$tests;
    $build->test_files(@newtests);
}

$build->create_build_script;
