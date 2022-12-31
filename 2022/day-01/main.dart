import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class Elf {
  List<int> calories;
  int total;
  Elf(this.calories, this.total);
}

read_file() {
  List<Elf> calories = [];

  List<int> current_list = [];
  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    if (line.isEmpty) {
      var sum = current_list.fold(0, (a,b) => a + b);
      calories.add(Elf(current_list, sum));
      current_list = [];
    } else {
      current_list.add(int.parse(line));
    }
  }
  var sum = current_list.fold(0, (a,b) => a + b);
  calories.add(Elf(current_list, sum));

  return calories;
}

part1(List<Elf> elves) {
  var largest = 0;
  for (var elf in elves) {
    largest = max(largest, elf.total);
  }

  print("part1: $largest");
}

part2(List<Elf> elves) {
  elves.sort((a,b) => b.total.compareTo(a.total));
  print("part2: ${elves[0].total+elves[1].total+elves[2].total}");
}

main() {
  var elves = read_file();

  part1(elves);
  part2(elves);
}
