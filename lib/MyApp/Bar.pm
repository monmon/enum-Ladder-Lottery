package MyApp::Bar;
use strict;
use warnings;
use Carp;

use Class::Accessor qw(moose-like);
has left => (is => 'rw', isa => 'MyApp::Vertex');
has right => (is => 'rw', isa => 'MyApp::Vertex');
has active_bar => (is => 'rw', isa => 'MyApp::Vertex');
has next => (is => 'rw', isa => 'MyApp::Bar');
has prev => (is => 'rw', isa => 'MyApp::Bar');


1;
