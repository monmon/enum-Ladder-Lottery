#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use FindBin::libs;
use MyApp::Vertex;
use MyApp::Stack;
use MyApp::Amida;

local $[ = 1; # arrray start index is 1

my @perms = @ARGV;

# Global
my $DEBUG = 1;
my $count;
my %start_line_of;
my $active_bar;
my $stack = MyApp::Stack->new;
my $amida = MyApp::Amida->new;


my($uppers_ref, $lowers_ref) = init(@perms);
make_root(\@perms, $uppers_ref, $lowers_ref);
$count++;
find_all_children(\@perms, $uppers_ref, $lowers_ref, 1);
#output_amidas(\@perms, $uppers_ref, $lowers_ref);
printf("Count = %.0f\n", $count);





# init
sub init {
    my @perms = @_;

    my(@uppers, @lowers);
    for my $i (reverse (1 .. scalar @perms)) {
        my $upper = MyApp::Vertex->new({
            line      => $i,
            route_num => 0,
        });
        my $lower = MyApp::Vertex->new({
            line      => $i,
            route_num => 0,
        });
        $amida->v_connect($upper, $lower);
    
        unshift @uppers, $upper;
        unshift @lowers, $lower;
    }

    return (\@uppers, \@lowers);
}

# Construct root amida
sub make_root {
    my($perms_ref, $uppers_ref, $lowers_ref) = @_;

    # 一番大きい数から順番に探す
    for my $curr_num (reverse (1 .. scalar @{$perms_ref})) {
        my $start_line = 1;   # curr_numが左から何番目の線にあるか
        my $restart_line;

        # Calc of the zigzag-path for curr_num.
        #printf("currNum = %d\n", $curr_num);
        while ($perms_ref->[$start_line] ne $curr_num) {
            $start_line++;
            #printf("startLine = %d, ", $start_line);
        }

        # Construct start_line_of
        $start_line_of{$curr_num} = $start_line;
        #printf("startLines[currNum] = %d\n", $start_line_of{$curr_num});

        # Move to down
        my $curr_vertex = $uppers_ref->[$start_line];
        $restart_line = $start_line;
        while (defined $curr_vertex->down) {
            if (defined $curr_vertex->left) { 
                $curr_vertex = $curr_vertex->left;
                $restart_line--;
            }
            else {
                $curr_vertex = $curr_vertex->down;
            }
        }
        
        # Make zigzag-path for curr_num.
        # We insert a new vertex between upper_vertex and lower_vertex.
        my($upper_vertex, $lower_vertex)
            = ($curr_vertex->up, $curr_vertex);
        for my $i ($restart_line .. $curr_num-1) {
            my $left_new_vertex = MyApp::Vertex->new({
                line      => $i,
                route_num => $curr_num,
            });
            my $right_new_vertex = MyApp::Vertex->new({
                line      => $i + 1,
                route_num => $curr_num,
            });

            $amida->insert_bar(
                $upper_vertex,
                $lower_vertex, 
                $lowers_ref->[$i + 1]->up,
                $lowers_ref->[$i + 1],
                $amida->h_connect($left_new_vertex, $right_new_vertex)
            );
            
            # Update of upperVertex and lowerVertex.
            $upper_vertex = $right_new_vertex;      
            $lower_vertex = $lowers_ref->[$i + 1];
        }
    }
}

#  Find all children
sub find_all_children {
    my($perms_ref, $uppers_ref, $lowers_ref, $clean_level) = @_;
    my $curr_clean_level = $clean_level;

    # Omit for efficiency @ 8th.Apr.2009.
    printf("%d-th amida, cleanLv = %d:\n", $count, $clean_level);
    output_amidas(\@perms, $uppers_ref, $lowers_ref); # Count & Print

    # Turn bar children
    for my $i (reverse ($curr_clean_level-1 .. scalar @{$perms_ref})) {
        # If cleanLv = 1 then, we have error case: i = 0!.
        last if $i == 0;
    
        #  find turn bar for route of i.
        my $curr_vertex = $uppers_ref->[$start_line_of{$i}]; 
        while (1) { # 0: find turn bar
            $curr_vertex = $curr_vertex->down;

            last unless defined $curr_vertex->left;
            $curr_vertex = $curr_vertex->left;
        }
        next unless defined $curr_vertex->right;
        # We have just found the turn bar of route i.

        while ($curr_vertex->line != $i) {
            my $lowerleft = $curr_vertex->down;  # Find lower-left vertex of current vertex

            if (! defined $lowerleft->right) {
                $curr_vertex = $curr_vertex->right->down;
                next; # increment & continue (skip recursive call)
            }
            elsif (is_rightswappable($lowerleft, $lowerleft->right)
                    && (($i >= ($clean_level - 1))
                    || (($lowerleft->line + 2) < $active_bar->line))) {
                my $route = $curr_vertex->route_num;
                my $bar = $amida->h_connect($lowerleft, $lowerleft->right);
                $bar->active_bar($active_bar);
                $stack->push($bar);

                rightswap($lowerleft, $lowerleft->right);

                $active_bar = $lowerleft; # Update of active bar
                $count++;  # Count up

                # Written in 9th.Apr.2009
                printf "The %.0f-th amida was generated\n", $count if $DEBUG;

                # Recursive call
                find_all_children($perms_ref, $uppers_ref, $lowers_ref, $route + 1);

                my $bar2 = $stack->pop;
                leftswap($bar2->left, $bar2->right);  # Return to the parent
                $active_bar = $bar2->active_bar;  # Return to the parent
            }

            # increment curr_vertex
            $curr_vertex = $curr_vertex->right->down;
        }  # while

    } # for loop (biggest loop in this subroutine.)
}


#  Print amidas
sub output_amidas {
    my($perms_ref, $uppers_ref, $lowers_ref) = @_;
    my $n = scalar @{$perms_ref};

    my @was_printed; # 0: not printed in the previous loop.
                     # 1: surely printed in the previous loop.
    my $final = 0;

    my @curr_vertices;
    # Initialization
    for my $i (1 .. $n) {
        $curr_vertices[$i] = $uppers_ref->[$i];
        $was_printed[$i] = 1;
    }

    while ($final != $n) {
        $final = 0;
    
        # 1st: Go down phase.
        for my $i (1 .. $n) {
            if ($was_printed[$i] == 1) { 
                if (defined $curr_vertices[$i]->down) {
                    $curr_vertices[$i] = $curr_vertices[$i]->down;
                }
                else {
                    $final++;
                }

                $was_printed[$i] = 0;
            }
        }

        # 2nd: Print phase.
        for my $i (1 .. $n-1) {
            print("|");
            if (defined $curr_vertices[$i]->right 
                && ($curr_vertices[$i]->right eq $curr_vertices[$i + 1])) {
                print("-");
                $was_printed[$i] = 1;
                $was_printed[$i + 1] = 1;
            }
            else {
                print(" ");
            }
        }
        print("|\n");

        # 3rd: Check final or not.
        for my $i (1 .. $n) {
            $final++ if $curr_vertices[$i] eq $lowers_ref->[$i];
        }

    }
    print("\n");
}

# is_rightswappable
sub is_rightswappable {
    my($left, $right) = @_;
    my($leftup, $rightup) = ($left->up, $right->up);

    return 1 if (defined $leftup->up) 
                && (defined $rightup->up)
                && (! defined $leftup->left)
                && (! defined $rightup->left)
                && ($leftup->right eq $rightup->up);
    
    return;
}

# rightswap and leftswap
# 
#           g     h                  g      h
#     |      |     |            |     |      |
#    a|     b|     |            |     |      |
#     |------|     |            | left| right|
#     |      |     |            |     |------|
#     |     c|    d|           a|    b|      |
#     |      |-----|            |-----|      |
#     |      |     |  ------>   |     |      |
# left| right|     |            |    c|     d|
#     |------|     |            |     |------|
#     |      |     |            |     |      |
#    e|     f|     |           e|    f|      |
# 
sub rightswap {
    my($left, $right) = @_;
    my($a, $b, $c, $d, $e, $f, $g, $h);
  
    $a = $left->up;
    $c = $right->up;
    $b = $c->up;
    $d = $c->right;
  
    $e = $left->down;
    $f = $right->down;
    $g = $b->up;
    $h = $d->up;
  
    # Remove $left and $right.
    $e->up($a);
    $a->down($e);
    $f->up($c);
    $c->down($f);
  
    # Add $left and $right to new places.
    $b->up($left);
    $left->down($b);
    $left->up($g);
    $g->down($left);
  
    $d->up($right);
    $right->down($d);
    $right->up($h);
    $h->down($right);
  
    $left->line($left->line + 1);
    $right->line($right->line + 1);
}

sub leftswap {
    my($left, $right) = @_;
    my($a, $b, $c, $d, $e, $f, $g, $h);

    $e = $left->up;
    $f = $right->up;

    $b = $left->down;
    $a = $b->left;

    $c = $b->down;
    $d = $right->down;

    $g = $a->down;
    $h = $c->down;

    # remove left and right
    $e->down($b);
    $b->up($e);
    $f->down($d);
    $d->up($f);

    # add left and right
    $c->down($right);
    $right->up($c);
    $right->down($h);
    $h->up($right);

    $a->down($left);
    $left->up($a);
    $left->down($g);
    $g->up($left);

    $left->line($left->line - 1);
    $right->line($right->line - 1);
}
