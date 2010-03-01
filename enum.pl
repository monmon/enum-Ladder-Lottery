#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use FindBin::libs;
use MyApp::Vertex;
use MyApp::Bar;
use MyApp::Stack;

local $[ = 1; # arrray start index is 1

my @perms = @ARGV;

# Global
my $CHECK = 1000000000;
my $count;
my @start_lines;
my $active_bar;
my $stack = MyApp::Stack->new;
my $state;


my($uppers_ref, $lowers_ref) = init(@perms);
make_root(\@perms, $uppers_ref, $lowers_ref);
#warn Dumper $uppers_ref;
$count++;
find_all_children(\@perms, $uppers_ref, $lowers_ref, 1);
output_amidas(\@perms, $uppers_ref, $lowers_ref);






# init
sub init {
    my @perms = @_;

    my(@uppers, @lowers);
    for my $i (reverse (1 .. scalar @perms)) {
        my $upper = MyApp::Vertex->new;
        my $lower = MyApp::Vertex->new;
    
        $upper->up(undef);
        $upper->down($lower);
        $upper->left(undef);
        $upper->right(undef);
        $upper->line($i);
        $upper->route_num(0);
    
        $lower->up($upper);
        $lower->down(undef);
        $lower->left(undef);
        $lower->right(undef);
        $lower->line($i);
        $lower->route_num(0);
    
        push @uppers, $upper;
        push @lowers, $lower;
    }

    return (\@uppers, \@lowers);
}

# Construct root amida
sub make_root {
    my($perms_ref, $uppers_ref, $lowers_ref) = @_;

    my $start_line = 1;
    my $restart_line;

    for my $curr_num (reverse (1 .. scalar @{$perms_ref})) {
        # Calc of the zigzag-path for curr_num.
        while ($perms_ref->[$start_line] ne $curr_num) {
            $start_line++;
        }

        # Construct start_lines
        $start_lines[$curr_num] = $start_line;

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
        
        my($upper_vertex, $lower_vertex);
        # Make zigzag-path for curr_num.
        # We insert a new vertex between upper_vertex and lower_vertex.
        $upper_vertex = $curr_vertex->up;
        $lower_vertex = $curr_vertex;
    
        my($left_new_vertex, $right_new_vertex);
        for my $i ($restart_line .. $curr_num-1) {
            $left_new_vertex = MyApp::Vertex->new({
                line     => $i,
                route_num => $curr_num,
            });
            $right_new_vertex = MyApp::Vertex->new({
                line     => $i + 1,
                route_num => $curr_num,
            });

            insert_bar($upper_vertex, $lower_vertex, 
                        $lowers_ref->[$i + 1]->up, $lowers_ref->[$i + 1],
                        $left_new_vertex, $right_new_vertex);
            
            # Update of upperVertex and lowerVertex.
            $upper_vertex = $right_new_vertex;      
            $lower_vertex = $lowers_ref->[$i + 1];
        }
    
        $start_line = 1;
    }

}

sub insert_bar {
    my ($upperleft, $lowerleft, $upperright, $lowerright, $leftend, $rightend)
         = @_;

    $upperleft->down($leftend);
    $lowerleft->up($leftend);
  
    $upperright->down($rightend);
    $lowerright->up($rightend);
  
    $leftend->up($upperleft);
    $leftend->left(undef);
    $leftend->down($lowerleft);
    $leftend->right($rightend);
  
    $rightend->up($upperright);
    $rightend->left($leftend);
    $rightend->down($lowerright);
    $rightend->right(undef);
}


#  Find all children
sub find_all_children {
    my($perms_ref, $uppers_ref, $lowers_ref, $clean_level) = @_;
    my $curr_clean_level = $clean_level;

    # Omit for efficiency @ 8th.Apr.2009.
    printf("%d-th amida, cleanLv = %d:\n", $count, $clean_level);
    output_amidas(\@perms, $uppers_ref, $lowers_ref); # Count & Print

    # Turn bar children
    for my $i (reverse (1 .. scalar @{$perms_ref})) {
        #  find turn bar for route of i.
        #  state = 0: go to lowerleft 
        #  state = 1: stop state

        # If cleanLv = 1 then, we have error case: i = 0!.
        next if $i == 0;
    
        my $curr_vertex = $uppers_ref->[$start_lines[$i]]; 
        $state = 0;    # 0: Go to lower-left, 1: stop(find turn bar)

        while ($state != 1) {
            $curr_vertex = $curr_vertex->down;
            if (defined $curr_vertex->left) {
                $curr_vertex = $curr_vertex->left;
            }
            else {
                $state = 1;
            }
        }
        next if ! defined $curr_vertex->right;
        # We have just found the turn bar of route i.

        while ($curr_vertex->line != $i) {
            my $lowerleft = $curr_vertex->down;  # Find lower-left vertex of current vertex

            # monmon
            #return unless defined $lowerleft;

            if (! defined $lowerleft->right) {
                $curr_vertex = $curr_vertex->right->down;
                next; # increment & continue (skip recursive call)
            }
            elsif (is_rightswappable($lowerleft, $lowerleft->right)) {
                my $route;
                my $bar = MyApp::Bar->new;
                my $bar2 = MyApp::Bar->new;
                if ($i == ($clean_level - 1)) {
                    if (! ($lowerleft->line + 2) >= $active_bar->line) {
                        $route = $curr_vertex->route_num;
                        $bar->left($lowerleft);
                        $bar->right($lowerleft->right);
                        $bar->next(undef);
                        $bar->prev(undef);
                        $bar->active_bar($active_bar);
                        $stack->push($bar);

                        rightswap($lowerleft, $lowerleft->right);

                        $active_bar = $lowerleft; # Update of active bar
                        $count++;  # Count up

                        # Written in 9th.Apr.2009
                        printf("The %.0f-th amida was generated\n", $count)
                            if ($count % $CHECK) == 0;
                
                        # Recursive call
                        find_all_children($perms_ref, $uppers_ref, $lowers_ref, $route + 1);
                
                        $bar2 = $stack->pop;
                        leftswap($bar2->left, $bar2->right);  # Return to the parent
                        $active_bar = $bar2->active_bar;  # Return to the parent
                    }
                }
                else {  # Case of i >= clean_level-1
                    $route = $curr_vertex->route_num;
                    $bar->left($lowerleft);
                    $bar->right($lowerleft->right);
                    $bar->next(undef);
                    $bar->prev(undef);
                    $bar->active_bar($active_bar);
                    $stack->push($bar);

                    rightswap($lowerleft, $lowerleft->right);

                    $active_bar = $lowerleft; # Update of active bar
                    $count++;  # Count up

                    # Recursive call
                    find_all_children($perms_ref, $uppers_ref, $lowers_ref, $route + 1);
                    
                    $bar2 = $stack->pop;
                    leftswap($bar2->left, $bar2->right);  # Return to the parent
                    $active_bar = $bar2->active_bar;  # Return to the parent
                }
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

# is_rightswappable and is_leftswappable
sub is_rightswappable {
    my($left, $right) = @_;
    my $leftup = $left->up;
    my $rightup = $right->up;

    if (! (defined $leftup->up && defined $rightup->up)) {
        return 0;
    }
    elsif ((! defined $leftup->left)
            && (! defined $rightup->left)
            && ($leftup->right eq $rightup->up)) {
        return 1;
    }
    else {
        return 0;
    }
}



# rightswap and leftswap
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
  
    # Remove left and right.
    $e->up($a);
    $a->down($e);
    $f->up($c);
    $c->down($f);
  
    # Add left and right to new places.
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
