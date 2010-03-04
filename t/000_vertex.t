use strict;
use warnings;
use Test::More;

BEGIN { use_ok('MyApp::Vertex'); }
require_ok('MyApp::Vertex');

#  struct vertex *up;
#  struct vertex *down;
#  struct vertex *left;
#  struct vertex *right;
#  int line, routeNum;  // line number and route number

my $vertex = MyApp::Vertex->new;
can_ok($vertex, 'up');
can_ok($vertex, 'down');
can_ok($vertex, 'left');
can_ok($vertex, 'right');
can_ok($vertex, 'line');
can_ok($vertex, 'route_num');

is($vertex->up, undef, 'default');
is($vertex->down, undef, 'default');
is($vertex->left, undef, 'default');
is($vertex->right, undef, 'default');
is($vertex->line, 0, 'default');
is($vertex->route_num, 0, 'default');

$vertex->up($vertex);
$vertex->up(1);
#isa_ok($vertex->up, 'MyApp::Vertex', 'up');
#isa_ok($vertex->down, 'MyApp::Vertex', 'down');
#isa_ok($vertex->left, 'MyApp::Vertex', 'left');
#isa_ok($vertex->right, 'MyApp::Vertex', 'right');
#isa_ok($vertex->line, 'SCALAR', 'line');
#isa_ok($vertex->route_num, 'SCALAR', 'rout_num');

done_testing;
