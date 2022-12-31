import 'dart:io';

class Monkey {
  String name;
  int? val;
  String? left;
  String? right;
  String? op;
  Monkey(this.name, this.val, this.left, this.right, this.op);
}

read_input(filename) {
  Map<String,Monkey> input = {};
  for (var line in File(filename).readAsLinesSync()) {
    var num_match = RegExp(r'(\w+): (\d+)').firstMatch(line);
    if (num_match != null) {
      var name = num_match.group(1)!;
      var val = int.parse(num_match.group(2)!);
      input[name] = Monkey(name, val, null, null, null);
    } else {
      var op_match = RegExp(r'(\w+): (\w+) (.) (\w+)').firstMatch(line);
      var name = op_match!.group(1)!;
      var left = op_match.group(2)!;
      var op = op_match.group(3)!;
      var right = op_match.group(4)!;
      input[name] = Monkey(name, null, left, right, op);
    }
  }

  return input;
}

int eval_op(String op, int left, int right) {
  switch (op) {
    case '+': return left + right;
    case '-': return left - right;
    case '*': return left * right;
    case '/': return left ~/ right;
  }
  print("Invalid op '$op'");
  exit(1);
}

int get_val(Map<String,Monkey> monkeys, String name) {
  Monkey monkey = monkeys[name]!;
  if (monkey.val == null) {
    monkey.val = eval_op(monkey.op!,
                         get_val(monkeys, monkey.left!),
                         get_val(monkeys, monkey.right!));
  }
  return monkey.val!;
}

part1(Map<String,Monkey> input) {
  int tot = get_val(input, 'root');
  print("Part 1 : $tot");
}

part2(Map<String,Monkey> monkeys) {

  int eval_op_inv(String op, int target, int other_side, bool guess_left) {
    switch (op) {
      case '+': return target - other_side;
      case '*': return target ~/ other_side;
      case '-':
        if (guess_left) {
          return target + other_side;
        } else {
          return other_side - target;
        }
      case '/':
        if (guess_left) {
          return target * other_side;
        } else {
          return other_side ~/ target;
        }
    }
    print("Invalid op '$op'");
    exit(1);
  }

  int? get_val(name) {
    if (name == 'humn') return null;
     Monkey monkey = monkeys[name]!;
     if (monkey.val == null) {
       int? left = get_val(monkey.left!);
       int? right = get_val(monkey.right!);
       if (left == null || right == null) return null;
       monkey.val = eval_op(monkey.op!, left, right);
     }
     return monkey.val;
  }

  recurse(name, target_val) {
    Monkey monkey = monkeys[name]!;
    int? left = get_val(monkey.left!);
    int? right = get_val(monkey.right!);
    if (left == null) {
      int new_target = eval_op_inv(monkey.op!, target_val, right!, true);
      if (monkey.left == 'humn') {
        print("Part 2 : $new_target");
        exit(1);
      }
      recurse(monkey.left!, new_target);
    } else if (right == null) {
      int new_target = eval_op_inv(monkey.op!, target_val, left, false);
      recurse(monkey.right!, new_target);
      if (monkey.right == 'humn') {
        print("Part 2 : $new_target");
        exit(1);
      }
    } else {
      assert(false);
    }
  }
  String curr = 'root';
  Monkey monkey = monkeys[curr]!;
  int? left = get_val(monkey.left!);
  int? right = get_val(monkey.right!);
  if (left == null) {
    recurse(monkey.left!, right!);
  } else {
    assert(right != null);
    recurse(monkey.right!, left);
  }
}

main() {
  part1(read_input('input.txt'));
  part2(read_input('input.txt'));
}
