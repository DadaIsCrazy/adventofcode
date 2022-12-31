import 'dart:io';

solve(String input, int part_num, int target_size) {
  var past_n = {};
  for (int i = 0; i < input.length && i < target_size; i++) {
    past_n.update(input[i], (v) => v + 1, ifAbsent: () => 1);
  }

  for (int i = target_size; i < input.length; i++) {
    if (past_n.length == target_size) {
      print("Part $part_num : $i");
      return;
    } else {
      if (past_n[input[i-target_size]] == 1) {
        past_n.remove(input[i-target_size]);
      } else {
        past_n.update(input[i-target_size], (v) => v - 1);
      }
      past_n.update(input[i], (v) => v + 1, ifAbsent: () => 1);
    }
  }

  print("Part $part_num : not found");
}

main() {
  File('input.txt').readAsString().then((String input) {
      // solve("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 1, 4);
      // solve("bvwbjplbgvbhsrlpgdmjqwftvncz", 1, 4);
      // solve("nppdvjthqldpwncqszvftbrmjlhg", 1, 4);
      // solve("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 1, 4);
      // solve("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 1, 4);

      // solve("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 2, 14);
      // solve("bvwbjplbgvbhsrlpgdmjqwftvncz", 2, 14);
      // solve("nppdvjthqldpwncqszvftbrmjlhg", 2, 14);
      // solve("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 2, 14);
      // solve("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 2, 14);

      solve(input, 1, 4);
      solve(input, 2, 14);
    });
}
