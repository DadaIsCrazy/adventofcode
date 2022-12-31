import 'dart:io';
import 'dart:math';

read_input(filename) {
  // The clean way to solve this problem is to use a hash rather than an array
  // to store the grid, so that 1) we don't have to wast memory for empty cells
  // and 2) we have no issues with bounds and no need to resize the grid.
  //
  // Still, for the first part, the size of the grid is bound by the number of
  // rounds which is fixed to 10, so one can simply add padding to the sides (10
  // on each side (left, top, right, bottom); 11 is better to not worry about
  // bounds).
  //
  // This is what I did for the 1st part, but I then realized that it doesn't
  // quite work for the 2nd part, because the amount of padding needed is not so
  // statically bounded. Still, I tried some larger padding, and luckily the
  // numbers below work for the part 2; +1 for lazyness :D
  var padding = 192;
  var half = 96;

  var lines = File(filename).readAsLinesSync();

  List<List<bool>> grid = List.generate(half, (_) => List.filled(lines[0].length+padding, false));

  for (var line in lines) {
    var row = List.filled(half, false) +
              line.split('').map((s) => s == '#').toList() +
              List.filled(half, false);
    grid.add(row);
  }

  grid.addAll(List.generate(half, (_) => List.filled(lines[0].length+padding, false)));

  return grid;
}

print_grid(grid) {
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
      if (grid[i][j]) {
        stdout.write('#');
      } else {
        stdout.write('.');
      }
    }
    print("");
  }
}

get_dst(List<List<bool>> old_grid, int x, int y, int pri) {
  // Checking if there are no other elves nearby
  bool elves_north = old_grid[x-1][y-1] || old_grid[x-1][y] || old_grid[x-1][y+1];
  bool elves_south = old_grid[x+1][y-1] || old_grid[x+1][y] || old_grid[x+1][y+1];
  bool elves_west  = old_grid[x-1][y-1] || old_grid[x][y-1] || old_grid[x+1][y-1];
  bool elves_east  = old_grid[x-1][y+1] || old_grid[x][y+1] || old_grid[x+1][y+1];

  var choices = [ [elves_north, x-1, y], [elves_south, x+1, y],
                  [elves_west, x, y-1], [elves_east, x, y+1] ];

  if (!(elves_north || elves_south || elves_west || elves_east)) {
    return [x, y];
  }

  for (int i = 0; i < 4; i++) {
    if (choices[(i+pri)%4][0] == false) {
      return [ choices[(i+pri)%4][1], choices[(i+pri)%4][2] ];
    }
  }

  return [x, y];
}

part1(grid) {
  List<List<bool>> round(grid, round_num) {
    List<List<int>> propositions = List.generate(grid.length, (_) => List.filled(grid[0].length, 0));

    for (int i = 1; i < grid.length-1; i++) {
      for (int j = 1; j < grid[0].length; j++) {
        if (grid[i][j]) {
          var move = get_dst(grid, i, j, round_num % 4);
          propositions[move[0]][move[1]] += 1;
        }
      }
    }

    List<List<bool>> new_grid = List.generate(grid.length, (_) => List.filled(grid[0].length, false));
    for (int i = 1; i < grid.length-1; i++) {
      for (int j = 1; j < grid[0].length; j++) {
        if (grid[i][j]) {
          var move = get_dst(grid, i, j, round_num % 4);
          if (propositions[move[0]][move[1]] == 1) {
            new_grid[move[0]][move[1]] = true;
          } else {
            new_grid[i][j] = true;
          }
        }
      }
    }

    return new_grid;
  }

  for (int i = 0; i < 10; i++) {
    grid = round(grid, i);
  }

  // Determining min and max x and y
  int min_x = 100, min_y = 100, max_x = -1, max_y = -1;
  for (int x = 0; x < grid.length; x++) {
    for (int y = 0; y < grid[0].length; y++) {
      if (grid[x][y]) {
        min_x = min(x, min_x);
        max_x = max(x, max_x);
        min_y = min(y, min_y);
        max_y = max(y, max_y);
      }
    }
  }

  int tot = 0;
  for (int x = min_x; x <= max_x; x++) {
    for (int y = min_y; y <= max_y; y++) {
      if (!grid[x][y]) tot += 1;
    }
  }

  print("Part 1 : $tot");
}


part2(grid) {
  List<List<bool>> round(grid, round_num) {
    List<List<int>> propositions = List.generate(grid.length, (_) => List.filled(grid[0].length, 0));

    for (int i = 1; i < grid.length-1; i++) {
      for (int j = 1; j < grid[0].length; j++) {
        if (grid[i][j]) {
          var move = get_dst(grid, i, j, round_num % 4);
          propositions[move[0]][move[1]] += 1;
        }
      }
    }

    int move_count = 0;
    List<List<bool>> new_grid = List.generate(grid.length, (_) => List.filled(grid[0].length, false));
    for (int i = 1; i < grid.length-1; i++) {
      for (int j = 1; j < grid[0].length; j++) {
        if (grid[i][j]) {
          var move = get_dst(grid, i, j, round_num % 4);
          if (propositions[move[0]][move[1]] == 1) {
            if (move[0] != i || move[1] != j) move_count++;
            new_grid[move[0]][move[1]] = true;
          } else {
            new_grid[i][j] = true;
          }
        }
      }
    }

    if (move_count == 0) {
      print("Part 2 : ${round_num+1}");
      exit(1);
    }

    return new_grid;
  }


  for (int i = 0; ; i++) {
    grid = round(grid, i);
  }
}


main() {
  var input = read_input('input.txt');
  part1(input);
  part2(input);
}
