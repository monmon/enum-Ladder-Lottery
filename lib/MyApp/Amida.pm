package MyApp::Amida;
use strict;
use warnings;

use Class::Accessor qw(moose-like);

use MyApp::Bar;

sub get_bar {
    my $self = shift;
    my($v1, $v2) = @_;

    $self->{bar_of}->{$v1};
}

sub h_connect {
    my $self = shift;
    my($v1, $v2) = @_;

    my $bar = MyApp::Bar->new;
    $bar->left($v1);
    $bar->right($v2);

    $v1->right($v2);
    $v2->left($v1);

    $self->{bar_of}->{$v1} = $bar;

    $bar;
}

sub v_connect {
    my $self = shift;
    my($v1, $v2) = @_;

    $v1->down($v2);
    $v2->up($v1);

    return;
}

sub insert_bar {
    my $self = shift;
    my ($upperleft, $lowerleft, $upperright, $lowerright, $bar)
         = @_;

    $self->v_connect($upperleft, $bar->left);
    $self->v_connect($bar->left, $lowerleft);
    $self->v_connect($upperright, $bar->right);
    $self->v_connect($bar->right, $lowerright);

    1;
}


1;
