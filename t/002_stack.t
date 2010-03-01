use strict;
use warnings;
use Test::More;

use Data::Dumper;

use MyApp::Bar;

BEGIN { use_ok('MyApp::Stack'); }
require_ok('MyApp::Stack');

#bar *head = NULL;
#bar *tail = NULL;

my $stack = MyApp::Stack->new;
can_ok($stack, 'head');
can_ok($stack, 'tail');
can_ok($stack, 'pop');
can_ok($stack, 'push');
can_ok($stack, 'size');
is($stack->head, undef, 'head');
is($stack->tail, undef, 'tail');
is($stack->size, 0, 'size');
my $ret = $stack->pop;
is($ret, undef, 'pop');
is($stack->head, undef, 'head');
is($stack->tail, undef, 'tail');
is($stack->size, 0, 'size');

# size: 1
my $bar = MyApp::Bar->new;
$stack->push($bar);
is($stack->head, $bar, 'head');
is($stack->tail, $bar, 'tail');
is($stack->size, 1, 'size');
$ret = $stack->pop;
is($ret, $bar, 'pop');
is($stack->head, undef, 'head');
is($stack->tail, undef, 'tail');
is($stack->size, 0, 'size');

# size: 2
my $bar2 = MyApp::Bar->new;
$stack->push($bar);
$stack->push($bar2);
is($stack->head, $bar2, 'head');
is($stack->tail, $bar, 'tail');
is($stack->size, 2, 'size');
$ret = $stack->pop;
is($ret, $bar2, 'pop');
is($stack->head, $bar, 'head');
is($stack->tail, $bar, 'tail');
is($stack->size, 1, 'size');
$ret = $stack->pop;
is($ret, $bar, 'pop');
is($stack->head, undef, 'head');
is($stack->tail, undef, 'tail');
is($stack->size, 0, 'size');





#isa_ok($stack->next, 'MyApp::Stack', 'line');
#isa_ok($stack->prev, 'MyApp::Stack', 'rout_num');

done_testing;
