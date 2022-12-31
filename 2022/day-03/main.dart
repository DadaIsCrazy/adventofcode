import 'dart:io';

int score(c) {
  if (c.toUpperCase() == c) {
    return c.codeUnitAt(0) - 'A'.codeUnitAt(0) + 27;
  } else {
    return c.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
  }
}

part1() {
  int total = 0;

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var len   = line.length;
    var start_chars = { ...line.substring(0, len~/2).split('') };
    for (var c in line.substring(len~/2, len).split('')) {
      if (start_chars.contains(c)) {
        total += score(c);
        break;
      }
    }
  }

  print("Part1: $total");
}

part2() {
  int total = 0;

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (int i = 0; i < lines.length; i += 3) {
    var map = {};
    lines[i].split('').forEach((e) => map[e] = 1);
    lines[i+1].split('').forEach((e) => map[e] = (map[e] ?? 0) >= 1 ? 2 : 0);
    lines[i+2].split('').forEach((e) => map[e] = (map[e] ?? 0) >= 2 ? 3 : 0);
    map.removeWhere((k,v) => v != 3);
    total += score(map.keys.first);
  }

  print("Part2 : $total");
}


main() {
  part1();
  part2();
}
