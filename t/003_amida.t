use strict;
use warnings;
use Test::More;

use Data::Dumper;

use MyApp::Vertex;

BEGIN { use_ok('MyApp::Amida'); }
require_ok('MyApp::Amida');

my $amida = MyApp::Amida->new;
can_ok($amida, 'get_bar');
can_ok($amida, 'h_connect');
can_ok($amida, 'v_connect');
can_ok($amida, 'insert_bar');

# vertical
my $v1 = MyApp::Vertex->new;
my $v2 = MyApp::Vertex->new;
$amida->v_connect($v1, $v2);
is($v1->down, $v2, 'v_connect');
is($v2->up, $v1, 'v_connect');

# horizon
$v1 = MyApp::Vertex->new;
$v2 = MyApp::Vertex->new;
my $bar = $amida->h_connect($v1, $v2);
is($bar->left, $v1, 'h_connect');
is($bar->right, $v2, 'h_connect');
# get_bar
is($amida->get_bar($v1, $v2), $bar, 'get_bar');

# insert_bar
$v1 = MyApp::Vertex->new;
$v2 = MyApp::Vertex->new;
$bar = $amida->h_connect($v1, $v2);
my $u_l_v = MyApp::Vertex->new;
my $l_l_v = MyApp::Vertex->new;
my $u_r_v = MyApp::Vertex->new;
my $l_r_v = MyApp::Vertex->new;
$amida->insert_bar($u_l_v, $l_l_v, $u_r_v, $l_r_v, $bar);
is($u_l_v->down, $v1);
is($v1->up, $u_l_v);
is($v1->down, $l_l_v);
is($l_l_v->up, $v1);
is($u_r_v->down, $v2);
is($v2->up, $u_r_v);
is($v2->down, $l_r_v);
is($l_r_v->up, $v2);


done_testing;
