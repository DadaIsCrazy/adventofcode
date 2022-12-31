// For each cell C of line 2000000:
//     For each sensor S:
//         B = closest beacon to S
//         If C is closer to S than B:
//             Goto next Cell (outer loop "continue")
//     // If we reached that point, then all of the sensors have a closer beacon,
//     // which means that S is a potential candidate.
//     total++;

import 'dart:io';
import 'dart:math';

int manhattan(int x1, int y1, int x2, int y2) {
  return (x2-x1).abs() + (y2-y1).abs();
}

class Line {
  int x1;
  int y1;
  int x2;
  int y2;
  int m;
  int b = 0;
  Line(this.x1, this.y1, this.x2, this.y2) :
    m = ((y2-y1)/(x2-x1)).round() {
      assert(((y2-y1)/(x2-x1)) == m);
      b = y2-m*x2;
    }

  String toString() { return "${m}x + $b"; }
}

class Sensor {
  int x; // self
  int y; // self
  int bx; // beacon
  int by; // beacon
  int beacon_dst;
  Sensor(this.x, this.y, this.bx, this.by) :
    beacon_dst = manhattan(x, y, bx, by) {}

  Line getLine(int side) {
    if (side == 0) {
      return Line(x-beacon_dst,y,x,y-beacon_dst);
    } else if (side == 1) {
      return Line(x,y-beacon_dst,x+beacon_dst,y);
    } else if (side == 2) {
      return Line(x+beacon_dst,y,x,y+beacon_dst);
    } else if (side == 3) {
      return Line(x,y+beacon_dst,x-beacon_dst,y);
    }
    assert(false);
    return Line(0,0,0,0);
  }

  toString() {
    return "Sensor at [$x, $y]: seeing beacon at [$bx,$by]";
  }
}

List<Sensor> read_input(filename) {
  List<Sensor> sensors = [];

  var lines = File(filename).readAsLinesSync();
  for (var line in lines) {
    var data = RegExp(r'x=(-?\d+), y=(-?\d+).+x=(-?\d+), y=(-?\d+)').firstMatch(line);
    sensors.add(Sensor(int.parse(data?.group(1) ?? "x"),
                       int.parse(data?.group(2) ?? "x"),
                       int.parse(data?.group(3) ?? "x"),
                       int.parse(data?.group(4) ?? "x")));
  }

  return sensors;
}

part1(List<Sensor> sensors, target_row) {
  var max_x = sensors[0].x, max_y = sensors[0].y,
      min_x = sensors[0].x, min_y = sensors[0].y;
  for (var sensor in sensors) {
    max_x = [sensor.x, sensor.bx, max_x].reduce(max);
    min_x = [sensor.x, sensor.bx, min_x].reduce(min);
    max_y = [sensor.y, sensor.by, max_y].reduce(max);
    min_y = [sensor.y, sensor.by, min_y].reduce(min);
  }

  int total = 0;
  // TODO: this thing for the bounds is veryyyyy dirty... Would be nicer to
  // figure out the proper bounds to use!
  outer: for (int x = min_x - 1000000; x < max_x + 1000000; x++) {
    for (var sensor in sensors) {
      if (sensor.beacon_dst >= manhattan(sensor.x, sensor.y, x, target_row)) {
        total++;
        continue outer;
      }
    }
  }

  // Removing beacons that are on the line
  var beacons_counted = <String>{};
  for (var sensor in sensors) {
    var sig = "${sensor.bx} ${sensor.by}";
    if (!beacons_counted.contains(sig) && sensor.by == target_row) {
      beacons_counted.add(sig);
      total--;
    }
  }

  print("Part 1 : $total");
}

part2(List<Sensor> sensors) {
  // Compute squares intersections? Next to the intersection of 2 squares, there
  // is going to be an empty cell.... Hard to tell how to make this work exactly.

  var lines = [];
  for (var i = 0; i < sensors.length-1; i++) {
    var sensor = sensors[i];
    for (var j = i+1; j < sensors.length; j++) {
      var other = sensors[j];
      if (other == sensor) continue;
      for (int side in [0, 1, 2, 3]) {
        Line line1 = sensor.getLine(side);
        Line line2 = other.getLine((side+2)%4);
        if ((line1.b - line2.b).abs() == 2) {
          lines.add([line1,line2]);
        }
      }
    }
  }

  // Experimentally, there is only one possible candidate, so we are lucky. If
  // there had been several candidates, some of them would have been inside some
  // other squares, so we could have easily eliminated them and only one should
  // have remained. (note that on the example there is more than one candidate,
  // so my code won't work :x)
  // Also, something that could have happened is that 2 lines could have 2 cells
  // apart (as we want), but not actually side-by-side (since those are line
  // segments rather than lines). Once again, easy to handle, but fortunately we
  // didn't have to handle that.

  var line1 = lines[0][0];
  var line2 = lines[0][1];
  var line3 = lines[1][0];
  var line4 = lines[1][1];

  List<int> inter(l1, l2) {
    var x = (l2.b - l1.b) ~/ (l1.m - l2.m);
    var y = l1.m * x + l1.b;
    assert(y == l2.m * x + l2.b);
    return [x, y];
  }

  var intersections = [inter(line1, line3),
                       inter(line1, line4),
                       inter(line2, line3),
                       inter(line2, line4)];

  var x = intersections.map((p) => p[0]).reduce((a,b) => a + b) ~/ intersections.length;
  var y = intersections.map((p) => p[1]).reduce((a,b) => a + b) ~/ intersections.length;

  print("Part 2 : ${x * 4000000 + y}");
}

main() {
  var input = read_input('input.txt');
  part1(input, 2000000);
  part2(input);
}
