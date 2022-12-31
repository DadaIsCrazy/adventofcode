import 'dart:io';
import 'package:collection/collection.dart';

// A DFS would have been enough since edges are not weighted. Still, my brain is
// weird to immediatly use Dijkstra's algorithm when it hears "shorted path", so
// I went with Dijkstra...

read_input() {
  var grid = [];
  var start;
  var end;

  var lines = File('input.txt').readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    var row = [];
    var chars = line.split('');
    for (var j = 0; j < chars.length; j++) {
      var c = chars[j];
      if (c == 'S') {
        start = [i, j];
        c = 'a';
      }
      if (c == 'E') {
        end = [i, j];
        c = 'z';
      }
      row.add(c.codeUnitAt(0) - 'a'.codeUnitAt(0));
    }
    grid.add(row);
  }

  return [grid, start, end];
}

const default_cost = 0x7ffffff;

class Cell {
  int x;
  int y;
  int cost;
  Cell(this.x, this.y, this.cost);
}

neighbors(cell, grid, costs, forward) {
  var x = cell.x;
  var y = cell.y;

  var out = [];
  for (var ij in [ [-1, 0], [0, -1], [1, 0], [0, 1] ]) {
    var i = ij[0];
    var j = ij[1];

    if (x+i < 0 || x+i >= grid.length || y+j < 0 || y+j >= grid[0].length) {
      continue;
    }

    if (costs[x+i][y+j] != default_cost) {
      continue;
    }

    if (forward && grid[x+i][y+j]-grid[x][y] > 1) {
      continue;
    }
    if (!forward && grid[x][y]-grid[x+i][y+j] > 1) {
      continue;
    }

    out.add(Cell(x+i, y+j, cell.cost+1));
  }

  return out;
}

part1(input) {
  var grid = input[0];
  var start = input[1];
  var end = input[2];

  var costs = List.generate(grid.length, (_) => List.filled(grid[0].length, default_cost));

  var queue = PriorityQueue<Cell>((a,b) => a.cost.compareTo(b.cost));
  queue.add(Cell(start[0], start[1], 0));

  while (queue.isNotEmpty) {
    var curr = queue.removeFirst();
    if (curr.x == end[0] && curr.y == end[1]) {
      print("Part 1 : ${curr.cost}");
      return;
    }
    if (costs[curr.x][curr.y] <= curr.cost) {
      continue;
    }

    costs[curr.x][curr.y] = curr.cost;

    for (var next in neighbors(curr, grid, costs, true)) {
      queue.add(next);
    }
  }

  print("Part 1: failed to reach destination");
}

part2(input) {
  var grid = input[0];
  var end = input[2];

  var costs = List.generate(grid.length, (_) => List.filled(grid[0].length, default_cost));

  var queue = PriorityQueue<Cell>((a,b) => a.cost.compareTo(b.cost));
  queue.add(Cell(end[0], end[1], 0));

  while (queue.isNotEmpty) {
    var curr = queue.removeFirst();
    if (grid[curr.x][curr.y] == 0) {
      print("Part 2 : ${curr.cost}");
      return;
    }
    if (costs[curr.x][curr.y] <= curr.cost) {
      continue;
    }

    costs[curr.x][curr.y] = curr.cost;

    for (var next in neighbors(curr, grid, costs, false)) {
      queue.add(next);
    }
  }

  print("Part 2: failed to find a start");
}

main() {
  var input = read_input();
  part1(input);
  part2(input);
}
