import 'dart:io';

compute_sizes() {
  List<String> lines = new File('input.txt').readAsLinesSync();

  List<String> curr_dirs = [];
  final Map<String,int> sizes = {};
  for (var line in lines) {
    final cd_match = RegExp(r'^\$ cd (.*)').firstMatch(line);
    if (cd_match != null) {
      final dir = cd_match.group(1) ?? "";
      if (dir == "/") curr_dirs.clear();
      if (dir == "..") {
        curr_dirs.removeLast();
      } else {
        curr_dirs.add(curr_dirs.join("@@") + dir);
      }
    }

    final file_match = RegExp(r'^(\d+) ').firstMatch(line);
    if (file_match != null) {
      final size = int.parse(file_match.group(1) ?? "error");
      for (var dir in curr_dirs) {
        sizes.update(dir, (v) => v + size, ifAbsent: () => size);
      }
    }
  }

  return sizes;
}

part1(Map<String,int> sizes) {

  int sum = 0;
  sizes.forEach((dir, value) {
      if (value <= 100000) {
        sum += value;
      }
  });

  print("Part 1 : $sum");
}

part2(sizes) {
  var total_size = sizes["/"];
  var smallest = "/";
  var target  = 40000000;

  sizes.forEach((dir, value) {
      if (total_size - value <= target) {
        if (value < sizes[smallest]) {
          smallest = dir;
        }
      }
  });

  print("Part 2 : ${sizes[smallest]}");
}

main() {
  var sizes = compute_sizes();

  part1(sizes);
  part2(sizes);
}
