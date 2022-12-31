import 'dart:io';


part1() {
  int cycle = 1, rax = 1, total = 0;
  tick() => total += (cycle++-20) % 40 == 0 ? (cycle-1)*rax : 0;
  for (var line in File('input_ex.txt').readAsLinesSync()) {
    var match = RegExp(r'addx (-?\d+)').firstMatch(line);
    tick();
    if (match != null) {
      tick();
      rax += int.parse(match.group(1)!);
    }
  }
  print("Part 1 : $total");
}

part2() {
  int cycle = 0, rax = 1, total = 0;
  var str = "";
  tick() {
    stdout.write((rax-cycle).abs() <= 1 ? "#" : ".");
    cycle++;
    if (cycle % 40 == 0 && cycle != 0) {
      print("");
      cycle = 0;
    }
  }
  for (var line in File('input.txt').readAsLinesSync()) {
    var match = RegExp(r'addx (-?\d+)').firstMatch(line);
    tick();
    if (match != null) {
      tick();
      rax += int.parse(match.group(1)!);
    }
  }
}


main() {
  part1();
  part2();
}
