import 'dart:io';
import 'dart:collection';

List<List<List<String>>> read_input(filename) {
  List<List<List<String>>> grid = [];
  var lines = File(filename).readAsLinesSync();

  for (var line in lines.sublist(1, lines.length-1)) {
    grid.add(line.split('')
                 .sublist(1, line.length-1)
                 .map((c) => c == '.' ? <String>[] : <String>[c])
                 .toList());
  }

  return grid;
}

List<List<List<String>>> move_blizzards(List<List<List<String>>> old_grid) {
  List<List<List<String>>> new_grid =
    List.generate(old_grid.length, (_) => List.generate(old_grid[0].length, (_) => <String>[]));

  for (int i = 0; i < old_grid.length; i++) {
    for (int j = 0; j < old_grid[0].length; j++) {
      for (String bliz in old_grid[i][j]) {
        switch (bliz) {
          case '>':
            if (j == old_grid[0].length-1) {
              new_grid[i][0].add('>');
            } else {
              new_grid[i][j+1].add('>');
            }
            break;
          case '<':
            if (j == 0) {
              new_grid[i][old_grid[0].length-1].add('<');
            } else {
              new_grid[i][j-1].add('<');
            }
            break;
          case '^':
            if (i == 0) {
              new_grid[old_grid.length-1][j].add('^');
            } else {
              new_grid[i-1][j].add('^');
            }
            break;
          case 'v':
            if (i == old_grid.length-1) {
              new_grid[0][j].add('v');
            } else {
              new_grid[i+1][j].add('v');
            }
            break;
        }
      }
    }
  }

  return new_grid;
}

print_grid(grid, x, y) {
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[0].length; j++) {
      if (i == x && j == y) {
        if (!grid[i][j].isEmpty) {
          print("Whups, in a blizzard!");
          exit(1);
        }
        stdout.write("E");
      } else {
        if (grid[i][j].isEmpty) {
          stdout.write(".");
        } else if (grid[i][j].length == 1) {
          stdout.write(grid[i][j][0]);
        } else {
          stdout.write(grid[i][j].length);
        }
      }
    }
    print("");
  }
}


part1(init_grid) {
  var grids = [init_grid];
  var seen = <String>{};

  var queue = ListQueue<List<dynamic>>();
  queue.add([-1, 0, 0]);

  while (!queue.isEmpty) {
    var curr = queue.removeFirst();
    int x = curr[0], y = curr[1], cycle = curr[2];
    String sig = "$x-$y-$cycle";
    if (seen.contains(sig)) continue;
    seen.add(sig);
    if (cycle == grids.length-1) {
      grids.add(move_blizzards(grids.last));
    }
    var grid = grids[cycle+1];

    for (var move in [ [0, 0], [-1, 0], [1, 0], [0, -1], [0, 1] ]) {
      var dx = move[0], dy = move[1];
      if (x+dx == grid.length && y == grid[0].length-1) {
        print("Part 1 : ${cycle+1}");
        return;
      }
      if (x+dx < 0 || x+dx >= grid.length || y+dy < 0 || y+dy >= grid[0].length) continue;
      if (grid[x+dx][y+dy].isEmpty) {
        queue.add([x+dx, y+dy, cycle+1]);
      }
    }
  }

  print("Part 1 : couldn't find a valid path...");
}


part2(init_grid) {
  var grids = [init_grid];
  var seen = <String>{};

  var queue = ListQueue<List<dynamic>>();
  queue.add([-1, 0, 0, 0]);

  while (!queue.isEmpty) {
    var curr = queue.removeFirst();
    int x = curr[0], y = curr[1], cycle = curr[2], status = curr[3];
    // Status:
    //  0 before reaching end
    //  1 when going back to the begining
    //  2 when going back to the end
    String sig = "$x-$y-$cycle-$status";
    if (seen.contains(sig)) continue;
    seen.add(sig);
    if (cycle == grids.length-1) {
      grids.add(move_blizzards(grids.last));
    }
    var grid = grids[cycle+1];

    for (var move in [ [0, 0], [-1, 0], [1, 0], [0, -1], [0, 1] ]) {
      var dx = move[0], dy = move[1];
      if (x+dx == grid.length && y == grid[0].length-1) {
        if (status == 2) {
          print("Part 2 : ${cycle+1}");
          return;
        } else if (status == 0) {
          queue.add([x+dx, y+dy, cycle+1, 1]);
        }
        // Doing nothing for status 1
        continue;
      }
      if (x+dx == -1 && y+dy == 0) {
        if (status == 1) {
          queue.add([-1, 0, cycle+1, 2]);
        }
        // Doing nothing for status 0 and 2
        continue;
      }
      if (x+dx < 0 || x+dx >= grid.length || y+dy < 0 || y+dy >= grid[0].length) continue;
      if (grid[x+dx][y+dy].isEmpty) {
        queue.add([x+dx, y+dy, cycle+1, status]);
      }
    }
  }

  print("Part 2 : couldn't find a valid path...");
}


main() {
  var input = read_input('input.txt');
  part1(input);
  part2(input);
}
