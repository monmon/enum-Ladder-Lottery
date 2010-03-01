package MyApp::Vertex;
use strict;
use warnings;

use Class::Accessor qw(moose-like);
has up => (is => 'rw', isa => 'MyApp::Vertex');
has down => (is => 'rw', isa => 'MyApp::Vertex');
has left => (is => 'rw', isa => 'MyApp::Vertex');
has right => (is => 'rw', isa => 'MyApp::Vertex');
has line => (is => 'rw', isa => 'Int');
has route_num => (is => 'rw', isa => 'Int');

sub new {
    my $class = shift;
    my $args = shift || {};
    bless {
        up    => undef,
        down  => undef,
        left  => undef,
        right => undef,
        %{$args},
    }, $class;
}

1;
