import 'dart:io';

class Monkey {
  List<int> items;
  var operation;
  int div_by;
  int dest_if_true;
  int dest_if_false;
  int inspected = 0;
  Monkey(this.items, this.operation, this.div_by,
         this.dest_if_true, this.dest_if_false);
}

class Input {
  int mod;
  List<Monkey> monkeys;
  Input(this.mod, this.monkeys);
}

parse_fun(String str) {
  var is_add_num = RegExp(r'\+ (\d+)').firstMatch(str);
  if (is_add_num != null) {
    int n = int.parse(is_add_num.group(1)!);
    return (x) => x + n;
  }
  var is_mul_num = RegExp(r'\* (\d+)').firstMatch(str);
  if (is_mul_num != null) {
    int n = int.parse(is_mul_num.group(1)!);
    return (x) => x * n;
  }
  return (x) => x * x;
}

read_input() {
  List<Monkey> monkeys = [];
  int mod = 1;

  var lines = File('input.txt').readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    i++; // ignoring monkey number line
    List<int> items = RegExp(r'items: (.*)')
                        .firstMatch(lines[i++])
                        ?.group(1)
                        ?.split(', ')
                        .map((e) => int.parse(e))
                        .toList() ?? [];
    var fn = parse_fun(lines[i++]);
    var div_by = int.parse(RegExp(r'by (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    var dest_if_true = int.parse(RegExp(r'monkey (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    var dest_if_false = int.parse(RegExp(r'monkey (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    mod *= div_by;
    monkeys.add(Monkey(items, fn, div_by, dest_if_true, dest_if_false));
  }

  return Input(mod, monkeys);
}

round(Input input, bool reduce_worry) {
  List<Monkey> monkeys = input.monkeys;
  for (Monkey monkey in monkeys) {
    var items = monkey.items;
    monkey.items = [];
    monkey.inspected += items.length;
    for (int item in items) {
      item = monkey.operation(item) % input.mod;
      if (reduce_worry) {
        item = item ~/ 3;
      }
      if (item % monkey.div_by == 0) {
        monkeys[monkey.dest_if_true].items.add(item);
      } else {
        monkeys[monkey.dest_if_false].items.add(item);
      }
    }
  }
}

part1(Input input) {
  for (int i = 0; i < 20; i++) {
    round(input, true);
  }

  List<Monkey> monkeys = input.monkeys;
  monkeys.sort((a,b) => b.inspected.compareTo(a.inspected));

  print("Part 1 : ${monkeys[0].inspected * monkeys[1].inspected}");
}

part2(Input input) {
  for (int i = 0; i < 10000; i++) {
    round(input, false);
  }

  List<Monkey> monkeys = input.monkeys;
  monkeys.sort((a,b) => b.inspected.compareTo(a.inspected));

  print("Part 2 : ${monkeys[0].inspected * monkeys[1].inspected}");
}

main() {
  part1(read_input());
  part2(read_input());
}
