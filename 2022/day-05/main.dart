import 'dart:io';

class Move {
  int amount;
  int from;
  int to;
  Move(this.amount, this.from, this.to);

  toString() {
    return "Move $amount from $from to $to";
  }
}

read_input() {
  List<List<String>> initial_layout = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  int linum = 0;
  var line = lines[linum];

  // Parsing initial state
  while (!line.isEmpty) {
    int col_idx = 0;
    while (col_idx < line.length) {
      // Extending {initial_layout} if needed.
      if (col_idx~/4 >= initial_layout.length) {
        initial_layout.add([]);
      }

      // Adding the letter to the right column.
      if (line[col_idx] == "[") {
        var letter = line[col_idx+1];
        initial_layout[col_idx~/4].add(letter);
      }

      col_idx += 4;
    }
    line = lines[++linum];
  }
  // Reversing each column.
  for (int i = 0; i < initial_layout.length; i++) {
    initial_layout[i] = initial_layout[i].reversed.toList();
  }

  // Parsing moves
  List<Move> moves = [];
  ++linum;
  while (linum != lines.length) {
    line = lines[linum++];
    final parse_re = RegExp(r'move (\d+) from (\d+) to (\d+)');
    final match = parse_re.firstMatch(line);
    if (match != null) {
    moves.add(Move(int.parse(match[1]!),
                   int.parse(match[2]!)-1,
                   int.parse(match[3]!)-1));
    }
  }

  return [initial_layout, moves];
}

do_move(state, move, keep_order) {
  var src = state[move.from];
  var dst = state[move.to];

  if (keep_order) {
    dst.addAll(src.sublist(src.length-move.amount));
  }

  for (int i = 0; i < move.amount; i++) {
    var v = src.removeLast();
    if (!keep_order) {
      dst.add(v);
    }
  }
}

solve(part_num, keep_order) {
  // We re-read the input for each part because we update it in-place.
  var input = read_input();
  var state = input[0];
  var moves = input[1];

  for (var move in moves) {
    do_move(state, move, keep_order);
  }

  var result = new StringBuffer();
  for (var col in state) {
    if (col.length > 0) {
      result.write(col.last);
    }
  }

  print("part $part_num: $result");
}


main() {
  solve(1, false);
  solve(2, true);
}
