import 'dart:io';
import 'dart:math';

enum GridCell { Air, Rock, Sand }

read_input() {
  var grid = List.generate(500, (_) => List.generate(1000, (_) => GridCell.Air));
  var max_x = 0;

  var lines = File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var coords = line.split(' -> ').map((e) => e.split(',')).map((l) => [ int.parse(l[0]), int.parse(l[1]) ]).toList() ;
    var x = coords[0][1], y = coords[0][0];
    max_x = max(x, max_x);

    for (int i = 1; i < coords.length; i++) {
      while (x < coords[i][1]) grid[x++][y] = GridCell.Rock;
      while (x > coords[i][1]) grid[x--][y] = GridCell.Rock;
      while (y < coords[i][0]) grid[x][y++] = GridCell.Rock;
      while (y > coords[i][0]) grid[x][y--] = GridCell.Rock;
      max_x = max(x, max_x);
    }

    grid[x][y] = GridCell.Rock;
  }

  return [grid, max_x];
}

simulate_fall(grid, max_x) {
  var x = 0, y = 500;
  while (true) {
    if (x > max_x) return false;
    if (grid[x+1][y] == GridCell.Air) {
      x = x+1;
    } else if (grid[x+1][y-1] == GridCell.Air) {
      x = x+1;
      y = y-1;
    } else if (grid[x+1][y+1] == GridCell.Air) {
      x = x+1;
      y = y+1;
    } else {
      grid[x][y] = GridCell.Sand;
      return true;
    }
  }
}

part1() {
  var input = read_input();
  var grid = input[0], max_x = input[1];
  var total = 0;

  while (true) {
    if (simulate_fall(grid, max_x)) {
      total++;
    } else {
      break;
    }
  }

  print("Part 1: $total");
}

part2() {
  var input = read_input();
  var grid = input[0], max_x = input[1];
  // Adding bottom layer
  for (int j = 0; j < 1000; j++) {
    grid[max_x+2][j] = GridCell.Rock;
  }

  var total = 0;
  while (grid[0][500] != GridCell.Sand) {
    if (simulate_fall(grid, max_x + 2)) {
      total++;
    } else {
      print("Error, could not fit any more grain...");
    }
  }

  print("Part 2: $total");
}

main() {
  part1();
  part2();
}
