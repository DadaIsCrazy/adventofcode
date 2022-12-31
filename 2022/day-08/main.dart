import 'dart:io';
import 'dart:math';

read_input() {
  List<List<int>> grid = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    grid.add(line.split("").map(int.parse).toList());
  }

  return grid;
}

// My solution is in O(n^3) time and O(1) space. This can be done in O(n^2) time
// & space by building 4 arrays with each cell being the max in a given
// direction, etc etc.
part1(input) {
  int total = input.length * input[0].length;

  for (int i = 1; i < input.length-1; i++) {
    for (int j = 1; j < input[0].length-1; j++) {
      int curr = input[i][j];
      bool hidden = false;

      // above
      for (int di = 0; di < i; di++) {
        if (input[di][j] >= curr) {
          hidden = true;
          break;
        }
      }
      if (!hidden) {
        continue;
      }

      // below
      hidden = false;
      for (int di = i+1; di < input.length; di++) {
        if (input[di][j] >= curr) {
          hidden = true;
          break;
        }
      }
      if (!hidden) {
        continue;
      }

      // left
      hidden = false;
      for (int dj = 0; dj < j; dj++) {
        if (input[i][dj] >= curr) {
          hidden = true;
          break;
        }
      }
      if (!hidden) {
        continue;
      }

      // right
      hidden = false;
      for (int dj = j+1; dj < input[0].length; dj++) {
        if (input[i][dj] >= curr) {
          hidden = true;
          break;
        }
      }


      if (hidden) {
        total--;
        continue;
      }
    }
  }

  print("part 1 : $total");

}

part2(input) {
  int max_score = 0;

  for (int i = 1; i < input.length-1; i++) {
    for (int j = 1; j < input[0].length-1; j++) {
      int curr = input[i][j];

      // above
      var part1_score = 0;
      for (int di = i-1; di >= 0; di--) {
        part1_score++;
        if (input[di][j] >= curr) break;
      }

      // below
      var part2_score = 0;
      for (int di = i+1; di < input.length; di++) {
        part2_score++;
        if (input[di][j] >= curr) break;
      }

      // left
      var part3_score = 0;
      for (int dj = j-1; dj >= 0; dj--) {
        part3_score++;
        if (input[i][dj] >= curr) break;
      }

      // right
      var part4_score = 0;
      for (int dj = j+1; dj < input[0].length; dj++) {
        part4_score++;
        if (input[i][dj] >= curr) break;
      }

      var score = part1_score * part2_score * part3_score * part4_score;
      max_score = max(max_score, score);
    }
  }

  print("part 2 : $max_score");
}

main() {
  var input = read_input();
  part1(input);
  part2(input);
}
