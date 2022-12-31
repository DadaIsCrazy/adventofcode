import 'dart:io';

parse(String line) {
  var output = [];
  var lists = [output];

  var i = 0;
  while (i != line.length) {
    if (line[i] == ',') {
      i++;
    } else if (line[i] == '[') {
      lists.add([]);
      i++;
    } else if (line[i] == ']') {
      var list = lists.removeLast();
      lists.last.add(list);
      i++;
    } else {
      var num_len = 0;
      while (line.codeUnitAt(i+num_len) >= '0'.codeUnitAt(0) &&
             line.codeUnitAt(i+num_len) <= '9'.codeUnitAt(0)) {
             num_len++;
      }
      lists.last.add(int.parse(line.substring(i, i+num_len)));
      i += num_len;
    }
  }

  return output[0];
}

read_input() {
  var output = [];

  var lines = File('input.txt').readAsLinesSync();
  for (var i = 0; i < lines.length; i+=3) {
    output.add([parse(lines[i]), parse(lines[i+1])]);
  }

  return output;
}

// -1 --> not ordered
// 0  --> unknown
// 1  --> ordered
int is_ordered(List<dynamic> l1, List<dynamic> l2) {
  int i = 0;
  for (; i < l1.length && i < l2.length; i++) {
    if (l1[i] is int && l2[i] is int) {
      if (l1[i] < l2[i]) return 1;
      else if (l1[i] > l2[i]) return -1;
    } else {
      var li1 = l1[i] is List ? l1[i] : [l1[i]];
      var li2 = l2[i] is List ? l2[i] : [l2[i]];
      var ordered = is_ordered(li1, li2);
      if (ordered != 0) return ordered;
    }
  }
  if (i == l1.length && i == l2.length) return 0;
  if (i == l1.length) return 1;
  return -1;
}

part1(input) {
  int total = 0;
  for (int i = 0; i < input.length; i++) {
    var pair = input[i];
    var ordered = is_ordered(pair[0], pair[1]);
    if (ordered == 1) {
      total += i + 1;
    }
  }
  print("Part 1 : $total");
}

part2(pair_input) {
  var input = [];
  for (var pair in pair_input) {
    input.add(pair[0]);
    input.add(pair[1]);
  }
  var m1 = [[2]];
  var m2 = [[6]];
  input.addAll([m1, m2]);

  input.sort((a,b) => is_ordered(b,a));

  int total = (input.indexOf(m1)+1) * (input.indexOf(m2)+1);

  print("Part 2 : $total");
}

main() {
  part1(read_input());
  part2(read_input());
}
