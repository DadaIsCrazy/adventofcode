import 'dart:io';

enum Dir { Up, Right, Down, Left }


Dir DirFromString(String str) {
  switch (str) {
    case 'U': return Dir.Up;
    case 'R': return Dir.Right;
    case 'D': return Dir.Down;
    case 'L': return Dir.Left;
  }
  stderr.write("Invalid String for Dir.fromString: '$str'.");
  exit(1);
}

class Move {
  Dir dir;
  int count;
  Move(this.dir, this.count);
  toString() { return "Move[$dir,$count]"; }
}

read_input() {
  List<Move> moves = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var l = line.split(' ');
    moves.add(Move(DirFromString(l[0]), int.parse(l[1])));
  }

  return moves;
}

class Pos {
  int x;
  int y;
  Pos([this.x = 0, this.y = 0]);
  toString() { return "Pos[$x, $y]"; }
}

// Grid layout:
//                     ^ (x = +inf)
//                     |
//                     |
//                     |
// (y = -inf) <--------0--------> (y = +inf)
//                     |
//                     |
//                     |
//                     v (x = -inf)
//
simulateMove(Dir dir, Pos head, List<Pos> tail) {
  // Moving {head}
  switch (dir) {
    case Dir.Up:
    head.x++;
    break;
    case Dir.Right:
    head.y++;
    break;
    case Dir.Down:
    head.x--;
    break;
    case Dir.Left:
    head.y--;
    break;
  }
  // Catching up to {head} with {tail}
  var prev = head;
  for (int i = 0; i < tail.length; i++) {
    var curr = tail[i];
    if ((prev.x-curr.x).abs() <= 1 && (prev.y-curr.y).abs() <= 1) {
      // {prev} and {curr} next to each other (vertical, horizontal or diagonal).
    } else if (prev.x == curr.x) {
      assert((prev.y-curr.y).abs() == 2);
      // {curr} just needs to move horizontally.
      curr.y = curr.y > prev.y ? prev.y + 1 : prev.y - 1;
    } else if (prev.y == curr.y) {
      assert((prev.x-curr.x).abs() == 2);
      // {curr} just needs to move vertically.
      curr.x = curr.x > prev.x ? prev.x + 1 : prev.x - 1;
    } else {
      // {curr} needs to move diagonally.
      if ((prev.x - curr.x).abs() == 2 && (prev.y-curr.y).abs() == 2) {
        curr.x = curr.x > prev.x ? prev.x + 1 : prev.x - 1;
        curr.y = curr.y > prev.y ? prev.y + 1 : prev.y - 1;
      } else if ((prev.x - curr.x).abs() == 2) {
        curr.x = curr.x > prev.x ? prev.x + 1 : prev.x - 1;
        curr.y = prev.y;
      } else {
        assert((prev.y-curr.y).abs() == 2);
        curr.y = curr.y > prev.y ? prev.y + 1 : prev.y - 1;
        curr.x = prev.x;
      }
    }
    prev = curr;
  }
}

printPos(max_x, max_y, offset, head, tail) {
  List<Pos> l = [];
  l.add(head);
  l.addAll(tail);
  for (int i = 0; i < max_x; i++) {
    for (int j = 0; j < max_y; j++) {
      bool written = false;
      for (int pn = 0; pn < l.length; pn++) {
        Pos pos = l[pn];
        if (pos.x+offset == max_x-i-1 && pos.y+offset == j) {
          stdout.write(pn);
          written = true;
          break;
        }
      }
      if (!written) {
        stdout.write(".");
      }
    }
    print("");
  }
  print("");
}

solve(input, part_num, [tail_size=1]) {
  var seenTail = <String>{};
  Pos head = Pos();
  List<Pos> tail = List.generate(tail_size, (_) => Pos());

  for (Move move in input) {
    for (int i = 0; i < move.count; i++) {
      simulateMove(move.dir, head, tail);
      seenTail.add(tail.last.toString());
    }
  }

  print("Part $part_num: ${seenTail.length}");
}

main() {
  var input = read_input();
  solve(input, 1);
  solve(input, 2, 9);
}
