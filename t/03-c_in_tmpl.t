#!perl -T

use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;

BEGIN{ use_ok('CGI::Application'); }
$ENV{CGI_APP_RETURN_ONLY} = 1;

C_NOT_IN_TMPL: {
    use TestApp;

    my $app = TestApp->new( TMPL_PATH => [ qw( templates ) ]);
    ok( my $tmpl = $app->load_tmpl( 'test.tmpl' ), "Created new page template" );
    isa_ok( $tmpl, "HTML::Template::Pluggable" );

    # Make sure that c wasn't set.
    isnt( $tmpl->query( name => 'c' ), 'VAR', 'CGI::App object not passed to template' );
}

C_IN_TMPL: {
    use TestApp;

    my $app = TestApp->new(
        TMPL_PATH => [ qw( templates ) ],
        PARAMS    => {
            test_param1 => 'This',
            test_param2 => 'that',
        },
    );
    ok( my $tmpl = $app->load_tmpl( 'test2.tmpl' ), "Created new page template" );
    isa_ok( $tmpl, "HTML::Template::Pluggable" );

    # Make sure that c was set.
    is( $tmpl->query( name => 'c' ), 'VAR', 'CGI::App object passed to template' );

    # Check values of passed parameters
    my $output = $tmpl->output;
    like( $output, qr/^This /, 'First parameter accessed successfully' );
    like( $output, qr/ that$/, 'Second parameter accessed successfully' );
}
