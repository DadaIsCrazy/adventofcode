import 'dart:io';
import 'dart:collection';

enum Dir { L, R }
enum Matter { Air, Rock }

List<Dir> read_input(filename) {
  var line = File(filename).readAsLinesSync()[0];
  return line.split('').map((c) => c == '>' ? Dir.R : Dir.L).toList();
}

print_pit(pit) {
  for (var row in pit.reversed) {
    for (var cell in row) {
      if (cell == Matter.Air) stdout.write(".");
      else stdout.write("#");
    }
    print("");
  }
}

int get_first_line_with_rock(pit) {
  int first_line_with_rock = pit.length-1;
  while (true) {
    var row = pit[first_line_with_rock];
    for (int i = 1; i < row.length-1; i++) {
      if (row[i] == Matter.Rock) {
        return first_line_with_rock;
      }
    }
    first_line_with_rock--;
  }
  print("get_first_line_with_rock error.");
  exit(1);
}

new_row() {
  var row = List.generate(9, (_) => Matter.Air);
  row[0] = Matter.Rock;
  row.last = Matter.Rock;
  return row;
}


int drop_square(pit, winds, wind_count, low_x) {
  // x-y are the coordinates of the bottom-right corner of the cube
  int x = low_x;
  int y = 4;
  while (true) {
    // wind push
    bool push = true;
    var wind = winds[wind_count++ % winds.length];
    if (wind == Dir.L) {
      if (pit[x][y-2] == Matter.Rock ||
          pit[x+1][y-2] == Matter.Rock) push = false;
    } else {
      if (pit[x][y+1] == Matter.Rock ||
          pit[x+1][y+1] == Matter.Rock) push = false;
    }
    if (push) y += wind == Dir.L ? -1 : 1;

    // fall
    bool fall = true;
    if (pit[x-1][y] == Matter.Rock ||
        pit[x-1][y-1] == Matter.Rock) {
        fall = false;
    }
    if (fall) {
      x--;
    } else {
      pit[x][y] = Matter.Rock;
      pit[x][y-1] = Matter.Rock;
      pit[x+1][y] = Matter.Rock;
      pit[x+1][y-1] = Matter.Rock;
      //print("After dropping square:");
      //print_pit(pit);
      return wind_count;
    }

  }
}

int drop_l(pit, winds, wind_count, low_x) {
  // x-y are the coordinates of the corner of the inverted L
  int x = low_x;
  int y = 5;
  while (true) {
    // wind push
    bool push = true;
    var wind = winds[wind_count++ % winds.length];
    if (wind == Dir.L) {
      if (pit[x][y-3] == Matter.Rock ||
          pit[x+1][y-1] == Matter.Rock ||
          pit[x+1][y-1] == Matter.Rock) push = false;
    } else {
      if (pit[x][y+1] == Matter.Rock ||
          pit[x+1][y+1] == Matter.Rock ||
          pit[x+2][y+1] == Matter.Rock) push = false;
    }
    if (push) y += wind == Dir.L ? -1 : 1;

    // fall
    bool fall = true;
    if (pit[x-1][y] == Matter.Rock ||
        pit[x-1][y-1] == Matter.Rock ||
        pit[x-1][y-2] == Matter.Rock) {
        fall = false;
    }
    if (fall) {
      x--;
    } else {
      pit[x][y] = Matter.Rock;
      pit[x][y-1] = Matter.Rock;
      pit[x][y-2] = Matter.Rock;
      pit[x+1][y] = Matter.Rock;
      pit[x+2][y] = Matter.Rock;
      //print("After dropping L:");
      //print_pit(pit);
      return wind_count;
    }

  }
}

int drop_plus(pit, winds, wind_count, low_x) {
  int x = low_x + 1;
  int y = 4;
  while (true) {
    // wind push
    bool push = true;
    var wind = winds[wind_count++ % winds.length];
    if (wind == Dir.L) {
      if (pit[x+1][y-1] == Matter.Rock ||
          pit[x][y-2] == Matter.Rock ||
          pit[x-1][y-1] == Matter.Rock) push = false;
    } else {
      if (pit[x+1][y+1] == Matter.Rock ||
          pit[x][y+2] == Matter.Rock ||
          pit[x-1][y+1] == Matter.Rock) push = false;
    }
    if (push) y += wind == Dir.L ? -1 : 1;

    // fall
    bool fall = true;
    if (pit[x-1][y-1] == Matter.Rock ||
        pit[x-2][y] == Matter.Rock ||
        pit[x-1][y+1] == Matter.Rock) {
        fall = false;
    }
    if (fall) {
      x--;
    } else {
      pit[x][y] = Matter.Rock;
      pit[x-1][y] = Matter.Rock;
      pit[x+1][y] = Matter.Rock;
      pit[x][y-1] = Matter.Rock;
      pit[x][y+1] = Matter.Rock;
      //print("After dropping plus:");
      //print_pit(pit);
      return wind_count;
    }

  }
}

int drop_hor_line(pit, winds, wind_count, low_x) {
  int ys = 3, ye = 6;
  int x = low_x;
  while (true) {
    // wind push
    bool push = true;
    var wind = winds[wind_count++ % winds.length];
    if ((wind == Dir.L && pit[x][ys-1] == Matter.Rock) ||
        (wind == Dir.R && pit[x][ye+1] == Matter.Rock)) {
      push = false;
    }
    if (push) {
      ys += wind == Dir.L ? -1 : 1;
      ye += wind == Dir.L ? -1 : 1;
    }

    // fall
    bool fall = true;
    for (int y = ys; y <= ye; y++) {
      if (pit[x-1][y] == Matter.Rock) {
        fall = false;
        break;
      }
    }
    if (fall) {
      x--;
    } else {
      for (int y = ys; y <= ye; y++) pit[x][y] = Matter.Rock;
      //print("After dropping line:");
      //print_pit(pit);
      return wind_count;
    }
  }
}

int drop_ver_line(pit, winds, wind_count, low_x) {
  int y = 3;
  int xs = low_x+3, xe = low_x;
  while (true) {
    // wind push
    bool push = true;
    var wind = winds[wind_count++ % winds.length];
    for (int x = xs; x >= xe; x--) {
      if (wind == Dir.L && pit[x][y-1] == Matter.Rock) {
        push = false;
        break;
      } else if (wind == Dir.R && pit[x][y+1] == Matter.Rock) {
        push = false;
        break;
      }
    }
    if (push) y += wind == Dir.L ? -1 : 1;

    // fall
    if (pit[xe-1][y] == Matter.Rock) {
      for (int x = xs; x >= xe; x--) pit[x][y] = Matter.Rock;
      //print("After dropping vert line:");
      //print_pit(pit);
      return wind_count;
    } else {
      xe--;
      xs--;
    }
  }
}

int drop_shape(pit, shape, winds, wind_count) {
  final heights = [1, 3, 3, 4, 2];
  final widths  = [4, 3, 3, 1, 2];
  int x = pit.length-1;
  int y = 2; // y coordinate of left edge

  // Figuring out how many rows need to be inserted
  int first_line_with_rock = get_first_line_with_rock(pit);

  int height = heights[shape];
  int number_of_lines_to_add = 4 + height - (pit.length - first_line_with_rock) as int;
  for (int i = 0; i < number_of_lines_to_add; i++) {
    pit.add(new_row());
  }

  // TODO: the start line that we're computing is wrong.

  var low_x = first_line_with_rock + 4;
  switch (shape) {
    case 0: return drop_hor_line(pit, winds, wind_count, low_x);
    case 1: return drop_plus(pit, winds, wind_count, low_x);
    case 2: return drop_l(pit, winds, wind_count, low_x);
    case 3: return drop_ver_line(pit, winds, wind_count, low_x);
    case 4: return drop_square(pit, winds, wind_count, low_x);
    default:
      print("Not implemented: fall for $shape");
      exit(1);
  }

  return 0;
}

part1(List<Dir> wind) {
  final target = 2022;
  final different_shape_count = 5;

  var pit = [ List.filled(9, Matter.Rock) ];

  int wind_count = 0;
  for (int i = 0; i < target; i++) {
    wind_count = drop_shape(pit, i % different_shape_count, wind, wind_count);
  }

  int first_line_with_rock = get_first_line_with_rock(pit);

  print("Part 1 : ${first_line_with_rock}");
}

record_cache_entry(List<List<Map<String,List<List<int>>>>> cache,
                       pit, shape, wind_index, curr_cycle) {
  int first_line_with_rock = get_first_line_with_rock(pit);
  final prev_sig_len = 50;
  if (first_line_with_rock <= prev_sig_len) {
    // Not enough previous lines to compute the "pit_sig";
    return null;
  }

  StringBuffer pit_sig_buf = new StringBuffer();
  for (int i = 0; i < prev_sig_len; i++) {
    for (int j = 1; j < 8; j++) {
      if (pit[first_line_with_rock-i][j] == Matter.Rock) {
        pit_sig_buf.write("1");
      } else {
        pit_sig_buf.write("0");
      }
    }
  }
  String pit_sig = pit_sig_buf.toString();

  if (cache[wind_index][shape].containsKey(pit_sig)
      && cache[wind_index][shape][pit_sig]!.length > 3) {
    var repeat_cycles = cache[wind_index][shape][pit_sig]!;
    int cycle_len = repeat_cycles[1][0] - repeat_cycles[0][0];
    int cycle_height = repeat_cycles[1][1] - repeat_cycles[0][1];
    for (int i = 2; i < repeat_cycles.length; i++) {
      if (repeat_cycles[i][0] - repeat_cycles[i-1][0] != cycle_len ||
          repeat_cycles[i][1] - repeat_cycles[i-1][1] != cycle_height) {
        print("Bad cycle, doesn't repeat at fixed intervals");
        exit(1);
      }
    }

    return [cycle_len, cycle_height];
  } else {
    if (!cache[wind_index][shape].containsKey(pit_sig)) {
      cache[wind_index][shape][pit_sig] = [];
    }
    cache[wind_index][shape][pit_sig]!.add([curr_cycle,first_line_with_rock]);
  }

  return null;
}

part2(List<Dir> winds) {
  final target_count = 1000000000000;
  final different_shape_count = 5;

  var pit = [ List.filled(9, Matter.Rock) ];

  List<List<Map<String,List<List<int>>>>> cache =
     List.generate(winds.length, (_) => List.generate(different_shape_count, (_) => {}));

  int len_to_add = 0;
  int wind_count = 0;
  int curr_cycle = 0;
  bool do_cache = true;
  while (curr_cycle < target_count) {
    var cycle = do_cache ? record_cache_entry(cache, pit, curr_cycle % different_shape_count,
                                              wind_count, curr_cycle) :
                           null;
    if (cycle == null) {
      wind_count = drop_shape(pit, curr_cycle % different_shape_count, winds, wind_count)
                   % winds.length;
      curr_cycle++;
    } else {
      // Be smart
      int cycle_len = cycle[0];
      int cycle_height = cycle[1];
      int curr_height = get_first_line_with_rock(pit);
      int remaining = target_count - curr_cycle;
      int remaining_cycles = remaining ~/ cycle_len;
      do_cache = false;
      len_to_add = remaining_cycles * cycle_height;
      curr_cycle = target_count - (remaining % cycle_len);
    }
  }

  int total = get_first_line_with_rock(pit) + len_to_add;
  print("Part 2 : $total");
}

main() {
  var input = read_input("input.txt");
  part1(input);
  part2(input);
}

// got:      1514285714287
// expected: 1514285714288
