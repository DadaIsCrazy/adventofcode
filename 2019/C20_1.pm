#!/usr/bin/perl

package C20_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub parse_string {
    my ($input) = @_;

    my @input = map { [ split // ] } split /\n/, $input;

    # Parsing maze only
    my @maze;
    for my $i (0 .. $#input) {
        for my $j (0 .. $#{$input[$i]}) {
            if ($input[$i][$j] eq '.') {
                $maze[$i][$j] = 1;
            } else {
                $maze[$i][$j] = 0;
            }
        }
    }

    # Parsing portals
    my %pre_portals;
    for my $i (0 .. $#input) {
        for my $j (0 .. $#{$input[$i]}) {
            if ($input[$i][$j] =~ /[A-Z]/) {
                if ($input[$i][$j+1] && ($input[$i][$j+1] =~ /[A-Z]/)) {
                    push @{$pre_portals{$input[$i][$j] . $input[$i][$j+1]}},
                        ($input[$i][$j+2] && $input[$i][$j+2] eq ".") ? [$i,$j+2] : [$i,$j-1];
                    $input[$i][$j] = " ";
                    $input[$i][$j+1] = " ";
                    $maze[$i][$j] = "2";
                    $maze[$i][$j+1] = "2";
                } elsif ($input[$i+1][$j] && ($input[$i+1][$j] =~ /[A-Z]/)) {
                    push @{$pre_portals{$input[$i][$j] . $input[$i+1][$j]}},
                        ($input[$i+2][$j] && $input[$i+2][$j] eq ".") ? [$i+2,$j] : [$i-1,$j];
                    $input[$i][$j] = " ";
                    $input[$i+1][$j] = " ";
                    $maze[$i][$j] = "2";
                    $maze[$i+1][$j] = "2";
                } else {
                    die "Invalid portal (input[$i][$j] = $input[$i][$j])";
                }
            }
        }
    }

    # Creating portal hash
    my %portals;
    for my $portal_name (keys %pre_portals) {
        next if $portal_name =~ /^(AA|ZZ)$/;
        my ($p1, $p2) = @{$pre_portals{$portal_name}};
        $portals{$p1->[0]}->{$p1->[1]} = $p2;
        $portals{$p2->[0]}->{$p2->[1]} = $p1;
    }

    return (\@maze, \%portals, $pre_portals{AA}[0], $pre_portals{ZZ}[0]);
}


sub solve_maze {
    my ($maze, $portals, $start, $end) = @_;

    my @costs = map { [ (10000000)x@{$maze->[0]} ] } 0 .. $#$maze;
    my @worklist = ([$start->[0],$start->[1],0]);

    while (@worklist) {
        my ($x,$y,$cost) = @{pop @worklist};
        next if $costs[$x][$y] < $cost;
        $costs[$x][$y] = $cost;
        for ([$x+1,$y],[$x,$y+1],[$x-1,$y],[$x,$y-1]) {
            my ($nx,$ny) = @$_;
            next if $costs[$nx][$ny] <= $cost;
            next unless $maze->[$nx][$ny] == 1;
            push @worklist, [$nx,$ny,$cost+1];
        }
        if (exists $portals->{$x}->{$y}) {
            my ($nx,$ny) = @{$portals->{$x}->{$y}};
            next if $costs[$nx][$ny] <= $cost;
            push @worklist, [$nx,$ny,$cost+1];
        }
    }

    return $costs[$end->[0]][$end->[1]];
}

sub main {
    my $test_input1 =
"         A         
         A         
  #######.#########
  #######.........#
  #######.#######.#
  #######.#######.#
  #######.#######.#
  #####  B    ###.#
BC...##  C    ###.#
  ##.##       ###.#
  ##...DE  F  ###.#
  #####    G  ###.#
  #########.#####.#
DE..#######...###.#
  #.#########.###.#
FG..#########.....#
  ###########.#####
             Z     
             Z     ";

    my $test_input2 =
"                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               ";

    
    my $test_input3 = 
"             Z L X W       C                
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     ";   

    die "BAAAAH" unless solve_maze(parse_string($test_input1)) == 23;
    die "BAAAAH" unless solve_maze(parse_string($test_input2)) == 58;
    die "BAAAAH" unless solve_maze(parse_string($test_input3)) == 77;

    open my $FH, '<', 'input_20.txt' or die $!;
    my $input = do { local $/; <$FH> };
    chomp $input;
    my ($maze, $portals, $start, $end) = parse_string($input);
    say solve_maze($maze,$portals,$start,$end);

}

1;
