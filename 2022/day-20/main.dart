import 'dart:io';

class InputNum {
  int val;
  int pos;
  InputNum(this.val, this.pos);

  String toString() { return "$val"; }
}

read_input(filename) {
  List<InputNum> nums = [];
  int pos = 0;
  for (var line in File(filename).readAsLinesSync()) {
    nums.add(InputNum(int.parse(line), pos++));
  }
  return nums;
}

swap(l, a, b) {
  var tmp = l[a % l.length];
  l[a % l.length] = l[b % l.length];
  l[b % l.length] = tmp;
}

part1(List<InputNum> nums) {
  for (int i = 0; i < nums.length; i++) {
    // Searching where the input {i} is. This part is in O(n), which is a bit
    // slow, but given the size of the input, it should be more than fast
    // enough.
    int pos = 0;
    while (nums[pos].pos != i) { pos++; }

    // Displacing input {i}.
    int move_left = nums[pos].val;
    int dir = move_left > 0 ? 1 : -1;
    move_left = move_left.abs();
    while (move_left != 0) {
      swap(nums, pos, pos + dir);
      pos += dir;
      move_left--;
    }
  }

  // Finding index of "0"
  int zero_idx = 0;
  while (nums[zero_idx].val != 0) zero_idx++;

  int tot = nums[(zero_idx + 1000)%nums.length].val + nums[(zero_idx + 2000)%nums.length].val
            + nums[(zero_idx + 3000)%nums.length].val;

  print("Part 1 : $tot");
}


part2(List<InputNum> nums) {
  // Multiplying each input by the decryption key
  final int decryption_key = 811589153;
  for (int i = 0; i < nums.length; i++) nums[i].val *= decryption_key;

  for (int mix = 0; mix < 10; mix++) {
    for (int i = 0; i < nums.length; i++) {
      // Searching where the input {i} is. This part is in O(n), which is a bit
      // slow, but given the size of the input, it should be more than fast
      // enough.
      int pos = 0;
      while (nums[pos].pos != i) { pos++; }

      InputNum n = nums[pos];
      nums.removeAt(pos);
      int dst = (pos + n.val) % nums.length;
      nums.insert(dst, n);
    }
  }

  // Finding index of "0"
  int zero_idx = 0;
  while (nums[zero_idx].val != 0) zero_idx++;

  int tot = nums[(zero_idx + 1000)%nums.length].val + nums[(zero_idx + 2000)%nums.length].val
            + nums[(zero_idx + 3000)%nums.length].val;

  print("Part 2 : $tot");
}


main() {
  part1(read_input('input.txt'));
  part2(read_input('input.txt'));
}
