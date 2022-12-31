import 'dart:io';

// The "clean" version is obviously my other version ("main.dart"), but I was
// wondering 1) if the problem would be solved with BigInt or if BigInts would
// be too slow, and 2) how BigInts worked in Dart. So here we go with BigInts.

// After writing and testing this code:
//   1) BigInts are way to slow. Each iteration is basically twice slower as
//      the previous one, and the 35th iteration takes 1 second. So, the 50th
//      would take 9 hours, and the even just the 100th is way out of reach.
//   2) BigInts are OKish in Dart, except that you have to remember to add
//      BigInt.from() around all of your constant, otherwise you might get
//      wrong results without any warnings (eg, `BigInt.from(2) == 2` returns
//      false without any warnings...).

class Monkey {
  List<BigInt> items;
  var operation;
  BigInt div_by;
  int dest_if_true;
  int dest_if_false;
  int inspected = 0;
  Monkey(this.items, this.operation, this.div_by,
         this.dest_if_true, this.dest_if_false);
}

parse_fun(String str) {
  var is_add_num = RegExp(r'\+ (\d+)').firstMatch(str);
  if (is_add_num != null) {
    BigInt n = BigInt.parse(is_add_num.group(1)!);
    return (x) => x + n;
  }
  var is_mul_num = RegExp(r'\* (\d+)').firstMatch(str);
  if (is_mul_num != null) {
    BigInt n = BigInt.parse(is_mul_num.group(1)!);
    return (x) => x * n;
  }
  return (x) => x * x;
}

read_input() {
  List<Monkey> monkeys = [];

  var lines = File('input.txt').readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    i++; // ignoring monkey number line
    List<BigInt> items = RegExp(r'items: (.*)')
                            .firstMatch(lines[i++])
                            ?.group(1)
                            ?.split(', ')
                            .map((e) => BigInt.parse(e))
                            .toList() ?? [];
    var fn = parse_fun(lines[i++]);
    var div_by = BigInt.parse(RegExp(r'by (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    var dest_if_true = int.parse(RegExp(r'monkey (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    var dest_if_false = int.parse(RegExp(r'monkey (\d+)').firstMatch(lines[i++])?.group(1)! ?? "");
    monkeys.add(Monkey(items, fn, div_by, dest_if_true, dest_if_false));
  }

  return monkeys;
}

round(List<Monkey> monkeys, bool reduce_worry) {
  for (int i = 0; i < monkeys.length; i++) {
    Monkey monkey = monkeys[i];
    var items = monkey.items;
    monkey.items = [];
    monkey.inspected += items.length;
    for (BigInt item in items) {
      item = monkey.operation(item);
      if (reduce_worry) {
        item = item ~/ BigInt.from(3);
      }
      if (item % monkey.div_by == BigInt.from(0)) {
        monkeys[monkey.dest_if_true].items.add(item);
      } else {
        monkeys[monkey.dest_if_false].items.add(item);
      }
    }
  }
}

part1(List<Monkey> monkeys) {
  for (int i = 0; i < 20; i++) {
    round(monkeys, true);
  }

  monkeys.sort((a,b) => b.inspected.compareTo(a.inspected));

  print("Part 1 : ${monkeys[0].inspected * monkeys[1].inspected}");
}

part2(List<Monkey> monkeys) {
  print("I hope you're running this on a quantum computer ;)");
  for (int i = 0; i < 10000; i++) {
    var start = DateTime.now().millisecondsSinceEpoch;
    round(monkeys, false);
    var total = DateTime.now().millisecondsSinceEpoch - start;

    print("Iteration $i: ${total/1000}sec");
  }

  monkeys.sort((a,b) => b.inspected.compareTo(a.inspected));

  print("Part 2 : ${monkeys[0].inspected * monkeys[1].inspected}");
}

main() {
  part1(read_input());
  part2(read_input());
}
