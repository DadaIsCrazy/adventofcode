import 'dart:io';
import 'package:tuple/tuple.dart';

class Range {
  int start;
  int end;
  Range(this.start, this.end);
}

List<Tuple2<Range,Range>> read_input() {
  List<Tuple2<Range,Range>> pairs = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var ranges = line.split(',');
    var start = ranges[0].split('-');
    var end = ranges[1].split('-');
    pairs.add(Tuple2(Range(int.parse(start[0]), int.parse(start[1])),
                     Range(int.parse(end[0]),   int.parse(end[1]))));
  }

  return pairs;
}

solve(input, input_num, filter) {
  int total = input.where(filter).length;
  print("Part $input_num: $total");
}

main() {
  var input = read_input();

  var part1_filter = (pair) => (pair.item1.start >= pair.item2.start &&
                                pair.item1.end <= pair.item2.end) ||
                               (pair.item2.start >= pair.item1.start &&
                                pair.item2.end <= pair.item1.end);
  var part2_filter = (pair) => (pair.item1.start <= pair.item2.start &&
                                pair.item1.end >= pair.item2.start) ||
                               (pair.item2.start <= pair.item1.start &&
                                pair.item2.end >= pair.item1.start);

  solve(input, "1", part1_filter);
  solve(input, "2", part2_filter);
}
