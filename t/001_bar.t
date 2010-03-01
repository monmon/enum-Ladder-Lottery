use strict;
use warnings;
use Test::More;

use Data::Dumper;

BEGIN { use_ok('MyApp::Bar'); }
require_ok('MyApp::Bar');

#  struct vertex *left;
#  struct vertex *right;
#  struct vertex *activeBar;
#  struct bar *next;
#  struct bar *prev;

my $bar = MyApp::Bar->new;
can_ok($bar, 'left');
can_ok($bar, 'right');
can_ok($bar, 'active_bar');
can_ok($bar, 'next');
can_ok($bar, 'prev');

$bar->next($bar);
$bar->prev($bar);
isa_ok($bar->next, 'MyApp::Bar', 'next');
isa_ok($bar->prev, 'MyApp::Bar', 'prev');


#isa_ok($bar->left, 'MyApp::Vertex', 'left');
#isa_ok($bar->right, 'MyApp::Vertex', 'right');
#isa_ok($bar->active_bar, 'MyApp::Vertex', 'up');

done_testing;
