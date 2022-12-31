import 'dart:io';
import 'dart:math';

// I initially solved part 2 without using my hand-cut cube (see
// "cube_day22.png"), but there was a bug in my code, so I ended up crafting
// this small cube to visualize better how things were wrapping. It turned out
// that my code was fine, except for the final "Computing score" part where I
// had forgotten to take the input layout into account... Still, cutting this
// small cube was funny, so I though I'd add a picture here to make me smile
// next time I look at this code.

class Move {
  String? dir;
  int? amount;
  Move(this.dir, this.amount);
}

class Input {
  List<List<String>> grid;
  List<Move> moves;
  Input(this.grid, this.moves);
}

Input read_input(filename) {
  var lines = File(filename).readAsLinesSync();
  // Computing which line is the longest of the grid
  int longest = lines.sublist(0, lines.length-2).map((s) => s.length).reduce(max);

  List<List<String>> grid = [];
  for (var line in lines.sublist(0, lines.length-2)) {
    var row = line.split('');
    row.addAll(List.filled(longest-line.length, ' '));
    grid.add(row);
  }

  List<Move> moves = [];
  var line = lines.last;
  int idx = 0;
  while (idx != line.length) {
    int num_end = idx;
    while (num_end != line.length && int.tryParse(line[num_end]) != null) num_end++;
    int n = int.parse(line.substring(idx, num_end));
    moves.add(Move(null, n));
    if (num_end == line.length) break;
    idx = num_end;
    moves.add(Move(line[idx], null));
    idx++;
  }

  return Input(grid, moves);
}

String rotate_dir(String dir, String rot) {
  if (rot == 'R') {
    switch(dir) {
      case 'L': return 'U';
      case 'U': return 'R';
      case 'R': return 'D';
      case 'D': return 'L';
    }
  } else if (rot == 'L') {
    switch(dir) {
      case 'L': return 'D';
      case 'D': return 'R';
      case 'R': return 'U';
      case 'U': return 'L';
    }
  }
  print("ERROR with rot $rot");
  exit(1);
}

part1(Input input) {
  var grid = input.grid;

  int x = 0, y = 0;
  String dir = 'R';
  // Finding initial position
  for (int j = 0; j < grid[0].length; j++) {
    if (grid[0][j] != ' ') {
      y = j;
      break;
    }
  }

  for (Move move in input.moves) {
    //print("$x - $y - $dir");
    if (move.dir != null) {
      dir = rotate_dir(dir, move.dir!);
    } else {
      out:
      for (int i = 0; i < move.amount!; i++) {
        switch (dir) {
          case 'R':
            if (y+1 >= grid[x].length || grid[x][y+1] == ' ') {
              int prev_y = y;
              for (y = 0; grid[x][y] == ' '; y++) {}
              if (grid[x][y] == '#') {
                y = prev_y;
                break out;
              }
              continue out;
            }
            if (grid[x][y+1] == '#') {
              break out;
            }
            y += 1;
            break;
          case 'L':
            if (y-1 < 0 || grid[x][y-1] == ' ') {
              int prev_y = y;
              for (y = grid[x].length-1; grid[x][y] == ' '; y--) {}
              if (grid[x][y] == '#') {
                y = prev_y;
                break out;
              }
              continue out;
            }
            if (grid[x][y-1] == '#') {
              break out;
            }
            y -= 1;
            break;
          case 'D':
            if (x+1 >= grid.length || grid[x+1][y] == ' ') {
              int prev_x = x;
              for (x = 0; grid[x][y] == ' '; x++) {}
              if (grid[x][y] == '#') {
                x = prev_x;
                break out;
              }
              continue out;
            }
            if (grid[x+1][y] == '#') {
              break out;
            }
            x += 1;
            break;
          case 'U':
            if (x-1 < 0 || grid[x-1][y] == ' ') {
              int prev_x = x;
              for (x = grid.length-1; grid[x][y] == ' '; x--) {}
              if (grid[x][y] == '#') {
                x = prev_x;
                break out;
              }
              continue out;
            }
            if (grid[x-1][y] == '#') {
              break out;
            }
            x -= 1;
            break;
        }
      }
    }
  }

  int dir_score = dir == "R" ? 0 : dir == "D" ? 1 : dir == "L" ? 2 : 3;
  print("Part 1 : ${1000 * (x+1) + 4 * (y+1) + dir_score}");
}

right_of(x, y, side, len, test_input) {
  if (test_input) {
    switch(side) {
      case 1:
        return [ len-x-1, len-1, 'L', 6 ];
      case 2:
        return [ x, 0, 'R', 3 ];
      case 3:
        return [ x, 0, 'R', 4 ];
      case 4:
        return [ 0, len-x-1, 'D', 6 ];
      case 5:
        return [ x, 0, 'R', 5 ];
      case 6:
        return [ len-x-1, len-1, 'L', 1 ];
    }
  } else {
    switch(side) {
      case 1:
        return [ x, 0, 'R', 2 ];
      case 2:
        return [ len-x-1, len-1, 'L', 5 ];
      case 3:
        return [ len-1, x, 'U', 2 ];
      case 4:
        return [ x, 0, 'R', 5 ];
      case 5:
        return [ len-x-1, len-1, 'L', 2 ];
      case 6:
        return [ len-1, x, 'U', 5 ];
    }
  }
}

left_of(x, y, side, len, test_input) {
  if (test_input) {
    switch(side) {
      case 1:
        return [ 0, x, 'D', 3 ];
      case 2:
        return [ len-1, len-x-1, 'U', 6 ];
      case 3:
        return [ x, len-1, 'L', 2 ];
      case 4:
        return [ x, len-1, 'L', 3 ];
      case 5:
        return [ len-1, len-x-1, 'U', 3 ];
      case 6:
        return [ x, len-1, 'L', 5 ];
    }
  } else {
    switch(side) {
      case 1:
        return [ len-x-1, 0, 'R', 4 ];
      case 2:
        return [ x, len-1, 'L', 1 ];
      case 3:
        return [ 0, x, 'D', 4 ];
      case 4:
        return [ len-x-1, 0, 'R', 1 ];
      case 5:
        return [ x, len-1, 'L', 4 ];
      case 6:
        return [ 0, x, 'D', 1 ];
    }
  }
}

top_of(x, y, side, len, test_input) {
  if (test_input) {
    switch(side) {
      case 1:
        return [ 0, len-y-1, 'D', 2 ];
      case 2:
        return [ 0, len-y-1, 'D', 1 ];
      case 3:
        return [ y, 0, 'R', 1 ];
      case 4:
        return [ len-1, y, 'U', 1 ];
      case 5:
        return [ len-1, y, 'U', 4 ];
      case 6:
        return [ len-x-1, len-1, 'L', 4 ];
    }
  } else {
    switch(side) {
      case 1:
        return [ y, 0, 'R', 6 ];
      case 2:
        return [ len-1, y, 'U', 6 ];
      case 3:
        return [ len-1, y, 'U', 1 ];
      case 4:
        return [ y, 0, 'R', 3 ];
      case 5:
        return [ len-1, y, 'U', 3 ];
      case 6:
        return [ len-1, y, 'U', 4 ];
    }
  }
}

bottom_of(x, y, side, len, test_input) {
  if (test_input) {
    switch(side) {
      case 1:
        return [ 0, y, 'D', 4 ];
      case 2:
        return [ len-1, len-y-1, 'U', 5 ];
      case 3:
        return [ len-y-1, 0, 'R', 5 ];
      case 4:
        return [ 0, y, 'D', 5 ];
      case 5:
        return [ len-1, len-y-1, 'U', 2 ];
      case 6:
        return [ len-y-1, 0, 'R', 2 ];
    }
  } else {
    switch(side) {
      case 1:
        return [ 0, y, 'D', 3 ];
      case 2:
        return [ y, len-1, 'L', 3 ];
      case 3:
        return [ 0, y, 'D', 5 ];
      case 4:
        return [ 0, y, 'D', 6 ];
      case 5:
        return [ y, len-1, 'L', 6 ];
      case 6:
        return [ 0, y, 'D', 2 ];
    }
  }
}

part2(input, test_input) {
  // If called with "input_ex.txt" as input, then "test_input" should be
  // "true". If called with the real input, then "test_input" should be
  // "false". The cube nets of the example input and my actual input are
  // different, and I've hardcoded the transitions for both (rather than
  // dynamically discovering the transitions, which sounds like something that
  // would lead to massive headaches).

  int side_size = test_input ? 4 : 50;
  List<List<String>> side1 = List.generate(side_size, (_) => List.filled(side_size, ""));
  List<List<String>> side2 = List.generate(side_size, (_) => List.filled(side_size, ""));
  List<List<String>> side3 = List.generate(side_size, (_) => List.filled(side_size, ""));
  List<List<String>> side4 = List.generate(side_size, (_) => List.filled(side_size, ""));
  List<List<String>> side5 = List.generate(side_size, (_) => List.filled(side_size, ""));
  List<List<String>> side6 = List.generate(side_size, (_) => List.filled(side_size, ""));

  if (test_input) {
    // Side 1
    for (int i = 0; i < side_size; i++) {
      for (int j = 0; j < side_size; j++) {
        side1[i][j] = input.grid[i][side_size*2+j];
        side2[i][j] = input.grid[side_size+i][j];
        side3[i][j] = input.grid[side_size+i][side_size+j];
        side4[i][j] = input.grid[side_size+i][side_size*2+j];
        side5[i][j] = input.grid[side_size*2+i][side_size*2+j];
        side6[i][j] = input.grid[side_size*2+i][side_size*3+j];
      }
    }
  } else {
    for (int i = 0; i < side_size; i++) {
      for (int j = 0; j < side_size; j++) {
        side1[i][j] = input.grid[i][side_size+j];
        side2[i][j] = input.grid[i][side_size*2+j];
        side3[i][j] = input.grid[side_size+i][side_size+j];
        side4[i][j] = input.grid[side_size*2+i][j];
        side5[i][j] = input.grid[side_size*2+i][side_size+j];
        side6[i][j] = input.grid[side_size*3+i][j];
      }
    }
  }

  List<List<List<String>>> sides = [ side1, side2, side3, side4, side5, side6 ];

  int x = 0, y = 0, side = 0;
  String dir = 'R';
  int len = side1.length;

  var grid = sides[side];

  for (Move move in input.moves) {
    //print("side=$side -- x=$x - y=$y - dir=$dir");
    if (move.dir != null) {
      dir = rotate_dir(dir, move.dir!);
    } else {
      out:
      for (int i = 0; i < move.amount!; i++) {
        switch (dir) {
          case 'R':
            if (y+1 >= grid[x].length) {
              var dst = right_of(x, y, side+1, len, test_input);
              int next_x = dst[0], next_y = dst[1], next_side = dst[3]-1;
              String next_dir = dst[2];
              if (sides[next_side][next_x][next_y] == '#') {
                break out;
              }
              x = next_x;
              y = next_y;
              dir = next_dir;
              side = next_side;
              grid = sides[side];
              continue out;
            }
            if (grid[x][y+1] == '#') {
              break out;
            }
            y += 1;
            break;
          case 'L':
            if (y-1 < 0) {
              var dst = left_of(x, y, side+1, len, test_input);
              int next_x = dst[0], next_y = dst[1], next_side = dst[3]-1;
              String next_dir = dst[2];
              if (sides[next_side][next_x][next_y] == '#') {
                break out;
              }
              x = next_x;
              y = next_y;
              dir = next_dir;
              side = next_side;
              grid = sides[side];
              continue out;
            }
            if (grid[x][y-1] == '#') {
              break out;
            }
            y -= 1;
            break;
          case 'D':
            if (x+1 >= grid.length) {
              var dst = bottom_of(x, y, side+1, len, test_input);
              int next_x = dst[0], next_y = dst[1], next_side = dst[3]-1;
              String next_dir = dst[2];
              if (sides[next_side][next_x][next_y] == '#') {
                break out;
              }
              x = next_x;
              y = next_y;
              dir = next_dir;
              side = next_side;
              grid = sides[side];
              continue out;
            }
            if (grid[x+1][y] == '#') {
              break out;
            }
            x += 1;
            break;
          case 'U':
            if (x-1 < 0) {
              var dst = top_of(x, y, side+1, len, test_input);
              int next_x = dst[0], next_y = dst[1], next_side = dst[3]-1;
              String next_dir = dst[2];
              if (sides[next_side][next_x][next_y] == '#') {
                break out;
              }
              x = next_x;
              y = next_y;
              dir = next_dir;
              side = next_side;
              grid = sides[side];
              continue out;
            }
            if (grid[x-1][y] == '#') {
              break out;
            }
            x -= 1;
            break;
        }
      }
    }
  }

  // Computing score
  int x_offset = 0, y_offset = 0;
  if (test_input) {
    switch (side) {
      case 0: x_offset = 0; break;
      case 1:
      case 2:
      case 3: x_offset = side_size; break;
      case 4:
      case 5: x_offset = side_size*2; break;
    }
    switch (side) {
      case 1: y_offset = 0; break;
      case 2: y_offset = side_size; break;
      case 0:
      case 3:
      case 4: y_offset = side_size*2; break;
      case 5: y_offset = side_size*3; break;
    }
  } else {
    switch (side) {
      case 0:
      case 1: x_offset = 0; break;
      case 2: x_offset = side_size; break;
      case 3:
      case 4: x_offset = side_size*2; break;
      case 5: x_offset = side_size*3; break;
    }
    switch (side) {
      case 3:
      case 5: y_offset = 0; break;
      case 0:
      case 2:
      case 4: y_offset = side_size; break;
      case 1: y_offset = side_size*2; break;
    }
  }
  int dir_score = dir == "R" ? 0 : dir == "D" ? 1 : dir == "L" ? 2 : 3;

  print("Part 2 : ${(x+x_offset+1)*1000 + (y+y_offset+1)*4 + dir_score}");
}

main() {
  var input = read_input('input.txt');
  part1(input);
  part2(input, false);
}
