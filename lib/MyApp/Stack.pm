package MyApp::Stack;
use strict;
use warnings;
use Carp;

use Data::Dumper;

use Class::Accessor qw(moose-like);
has head => (is => 'rw', isa => 'MyApp::Bar');
has tail => (is => 'rw', isa => 'MyApp::Bar');

sub push {
    my($self, $bar) = @_;
    my($head, $tail) = @{$self}{'head', 'tail'};

    if ((! defined $head) && (! defined $tail)) {
        $head = $tail = $bar;
        $bar->next(undef);
        $bar->prev(undef);
    }
    else {
        $head->prev($bar);
        $bar->next($head);
        $bar->prev(undef);
        $head = $bar;
    }

    $self->{head} = $head;
    $self->{tail} = $tail;
    $self;
}

sub pop {
    my $self = shift;
    my($head, $tail) = @{$self}{'head', 'tail'};

    my $ret;
    return if (! defined $head) && (! defined $tail);

    $ret = $head;
    $head = $head->next;
    ($self->size == 1) ? $tail = undef : $head->prev(undef);

    $self->{head} = $head;
    $self->{tail} = $tail;

    $ret;
}

sub size {
    my $self = shift;
    my $size = 0;

    my $bar = $self->head;
    while (defined $bar) {
        $size++;
        $bar = $bar->next;
    }

    $size;
}


1;
