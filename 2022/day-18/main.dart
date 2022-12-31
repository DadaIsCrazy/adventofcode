import 'dart:io';
import 'dart:math';

List<List<List<int>>> read_input(filename) {
  List<List<int>> cubes = [];

  for (var line in File(filename).readAsLinesSync()) {
    cubes.add(line.split(',').map((s) => int.parse(s)).toList());
  }

  int max_len = 0;
  for (var cube in cubes) {
    max_len = max(max_len, cube.reduce(max));
  }

  var grid = List.generate(max_len+1, (_) =>
               List.generate(max_len+1, (_) =>
                 List.filled(max_len+1, 0)));

  for (var cube in cubes) {
    grid[cube[0]][cube[1]][cube[2]] = 1;
  }


  return grid;
}

int count_sides(grid, x, y, z, [air = 0]) {
  if (grid[x][y][z] != 1) return 0;
  int tot = 0;
  for (var d in [-1, 1]) {
    if (x+d < 0 || x+d >= grid.length) tot++;
    if (y+d < 0 || y+d >= grid.length) tot++;
    if (z+d < 0 || z+d >= grid.length) tot++;

    if (x+d >= 0 && x+d < grid.length && grid[x+d][y][z] == air) tot++;
    if (y+d >= 0 && y+d < grid.length && grid[x][y+d][z] == air) tot++;
    if (z+d >= 0 && z+d < grid.length && grid[x][y][z+d] == air) tot++;
  }
  return tot;
}

part1(List<List<List<int>>> grid) {
  int tot = 0;
  for (int x = 0; x < grid.length; x++) {
    for (int y = 0; y < grid[0].length; y++) {
      for (int z = 0; z < grid[0][0].length; z++) {
        tot += count_sides(grid, x, y, z);
      }
    }
  }

  print("Part 1 : $tot");
}

update_cell(grid, x, y, z) {
  if (grid[x][y][z] != 0) return;

  var seen = <String>{};
  var queue = [[x,y,z]];
  var connected_to_exit = false;
  while (!queue.isEmpty) {
    var curr = queue.removeLast();
    int x = curr[0], y = curr[1], z = curr[2];
    if (grid[x][y][z] != 0) continue;
    String sig = "$x-$y-$z";
    if (seen.contains(sig)) continue;
    seen.add(sig);

    for (var d in [-1, 1]) {
      if (x+d < 0 || x+d >= grid.length) connected_to_exit = true;
      if (y+d < 0 || y+d >= grid.length) connected_to_exit = true;
      if (z+d < 0 || z+d >= grid.length) connected_to_exit = true;

      if (x+d >= 0 && x+d < grid.length && grid[x+d][y][z] == 0) queue.add([x+d,y,z]);
      if (y+d >= 0 && y+d < grid.length && grid[x][y+d][z] == 0) queue.add([x,y+d,z]);
      if (z+d >= 0 && z+d < grid.length && grid[x][y][z+d] == 0) queue.add([x,y,z+d]);
    }
  }

  var new_val = connected_to_exit ? 2 : 3;
  for (var sig in seen) {
    var coords = sig.split('-').map((s) => int.parse(s)).toList();
    grid[coords[0]][coords[1]][coords[2]] = new_val;
  }
}

part2(List<List<List<int>>> grid) {
  for (int x = 0; x < grid.length; x++) {
    for (int y = 0; y < grid[0].length; y++) {
      for (int z = 0; z < grid[0][0].length; z++) {
        update_cell(grid, x, y, z);
      }
    }
  }

  int tot = 0;
  for (int x = 0; x < grid.length; x++) {
    for (int y = 0; y < grid[0].length; y++) {
      for (int z = 0; z < grid[0][0].length; z++) {
        if (grid[x][y][z] == 1) {
          tot += count_sides(grid, x, y, z, 2);
        }
      }
    }
  }

  print("Part 2 : $tot");
}

main() {
  var input = read_input('input.txt');
  part1(input);
  part2(input);
}
