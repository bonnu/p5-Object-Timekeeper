use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More'     => '0.98',
        'Test::Requires' => 0,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        perl                => '5.008005',
        'Time::HiRes'       => '1.9718',
        'Text::SimpleTable' => '2.03',
        'Scope::Container'  => '0.04',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Object-Timekeeper',
    module_name => 'Object::Timekeeper',

    # script_files => [''],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
