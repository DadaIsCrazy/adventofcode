import 'dart:io';
import 'dart:math';

final int ore = 0;
final int clay = 1;
final int obsidian = 2;
final int geode = 3;

int str_type_to_int(str) {
  switch (str) {
    case 'ore': return ore;
    case 'clay': return clay;
    case 'obsidian': return obsidian;
    case 'geode': return geode;
  }
  print("Invalid str_type_to_int input: $str");
  exit(1);
}

List<List<List<int>>> read_input(filename) {
  List<List<List<int>>> blueprints = [];

  for (var line in File(filename).readAsLinesSync()) {
    List<List<int>> blueprint = List.generate(4, (_) => List.filled(4, 0));
    for (var subpart in line.split('.').where((s) => s != "")) {
      var match = RegExp(r'Each (\w+) .* costs (.*)').firstMatch(subpart)!;
      int robot_type = str_type_to_int(match.group(1)!);
      for (var resource in match.group(2)!.split(' and ')) {
        var resource_match = RegExp(r'(\d+) (\w+)').firstMatch(resource)!;
        int resource_int = str_type_to_int(resource_match.group(2)!);
        blueprint[robot_type][resource_int] = int.parse(resource_match.group(1)!);
      }
    }
    blueprints.add(blueprint);
  }

  print(blueprints);

  return blueprints;
}


// The following commented code are my attempts to do something efficient for
// the version of this problem where multiple robots can be built each cycle. I
// initially missed the restriction and tried to solve this, which is somewhat
// harder and computationally more expensive; and I don't want to delete this
// code just now, so I'll leave it here commented.


// String get_sig(minerals, robots, time_left) {
//   StringBuffer res = StringBuffer();
//   res.write("$time_left;");
//   for (int i = 0; i < 4; i++) res.write("${minerals[i]}-");
//   res.write(";");
//   for (int i = 0; i < 4; i++) res.write("${robots[i]}-");
//   return res.toString();
// }

// int rec_count = 0;
// var cache = <String>{};
// int glob_best = 0;
// int compute_max(List<List<int>> blueprint, List<int> minerals,
//                 List<int> robots, List<int> to_add, int time_left) {
//   rec_count++;
//   // if (rec_count++ > 2000000) {
//   //   print("Exiting because rec_count > 1000000");
//   //   return 0;
//   // }

//   // stdout.write(" " * (24-time_left));
//   // stdout.write("time:$time_left [ robots: ");
//   // robots.forEach((k,v) => stdout.write("$k:$v "));
//   // stdout.write("] [ minerals: ");
//   // minerals.forEach((k,v) => stdout.write("$k:$v "));
//   // stdout.write("] [ to_add: ");
//   // to_add.forEach((k,v) => stdout.write("$k: $v "));
//   // print("]");

//   if (time_left == 0) {
//     int res = minerals[geode];
//     if (res > glob_best) {
//       print("res = $res");
//       glob_best = res;
//     }
//     return res;
//   }

//   int this_max = 0;
//   for (var robot_type in [geode, obsidian, clay, ore]) {
//     if (robot_type == ore && robots[ore] >= 3) continue;
//     if (robot_type == clay && robots[clay]  >= 4) continue;
//     // If there is already a clay robot, let's not try to build an ore robot.
//     //if (robot_type == 'ore' && (robots['clay']??0) >= 1) continue;
//     // Checking if we can build one such robot
//     bool can_build = true;
//     for (int i = 0; i < 4; i++)
//       if (blueprint[robot_type][i] > minerals[i]) can_build = false;
//     if (can_build) {
//       for (int i = 0; i < 4; i++) minerals[i] -= blueprint[robot_type][i];
//       to_add[robot_type] += 1;
//       this_max = max(this_max, compute_max(blueprint, minerals, robots,
//                                            to_add, time_left));
//       to_add[robot_type] -= 1;
//       for (int i = 0; i < 4; i++) minerals[i] += blueprint[robot_type][i];
//       // If we can build a geode robot, we want to do it
//       if (robot_type == geode) return this_max;
//       // If we can build an obsidian, we don't want to try the clay or ore instead.
//       if (robot_type == obsidian) break;
//     }
//   }

//   // Collecting resources
//   for (int i = 0; i < 4; i++) minerals[i] += robots[i];
//   // Adding new robots
//   for (int i = 0; i < 4; i++) robots[i] += to_add[i];

//   String sig = get_sig(minerals, robots, time_left-1);
//   if (!cache.contains(sig)) {
//     this_max = max(this_max, compute_max(blueprint, minerals, robots,
//                                          [0, 0, 0, 0], time_left-1));
//     cache.add(sig);
//   }

//   // Removing new robots
//   for (int i = 0; i < 4; i++) robots[i] -= to_add[i];
//   // Removing collected resources
//   for (int i = 0; i < 4; i++) minerals[i] -= robots[i];

//   return this_max;
// }


// var cache = <String>{};
// String get_sig(minerals, robots, time_left) {
//   StringBuffer res = StringBuffer();
//   res.write("$time_left;");
//   for (int i = 0; i < 4; i++) res.write("${minerals[i]}-");
//   res.write(";");
//   for (int i = 0; i < 4; i++) res.write("${robots[i]}-");
//   return res.toString();
// }

// int rec_count = 0;
// int best = 0;
// compute_rec(List<List<int>> blueprint, List<int> robots, List<int> resources, int time_left) {
//   String space = " " * (24-time_left);
//   print("$space${24-time_left}: robots=$robots  resources=$resources");
//   rec_count++;

//   String sig = get_sig(resources, robots, time_left);
//   if (cache.contains(sig)) return;
//   cache.add(sig);

//   if (time_left <= 0) {
//     stdout.write(" " * 24);
//     print("end: ${resources[geode]}");
//     if (resources[geode] > best) {
//       print("New best : ${resources[geode]}");
//       print("  robots=$robots   resources=$resources");
//       print("\n");
//     }
//     best = max(best, resources[geode]);
//     return;
//   }

//   bool try_add_robot_before(int type, int max_cycle, int needed_ore, [bool early = false]) {
//     // Tries to add a {type} robot at before {max_cycle}, and leaving at least
//     // {needed_ore} for {max_cycle}. {type} is guaranteed to be one of "ore",
//     // "clay" or "obsidian" (ie, it's not "geode").
//     if (time_left <= 4 && type <= 1) return false;
//     if (type == ore && resources[ore] > 10) return false;
//     int max_ore_robots = early ? 4 : 6;
//     int max_clay_robots = early ? 5 : 7;
//     if (type == ore && robots[ore] >= max_ore_robots) return false;
//     if (type == clay && robots[clay] >= max_clay_robots) return false;
//     int cycles_for_ore = ((blueprint[type][ore] - resources[ore] + needed_ore)
//                           / robots[ore]).ceil();
//     if (cycles_for_ore >= max_cycle) return false;

//     int cycles_for_clay = ((blueprint[type][clay] - resources[clay]) / robots[clay]).ceil();
//     if (cycles_for_clay >= max_cycle) return false;

//     // We can build this robots.

//     // When computing the actual number of cycles needed, we can ignore the
//     // "needed_ore" part.
//     int cycles = max(((blueprint[type][ore] - resources[ore]) / robots[ore]).ceil(),
//                      cycles_for_clay);

//     // Updating resources and robot count
//     List<int> new_resources = [0, 0, 0, 0];
//     new_resources[ore] = resources[ore] + (cycles+1) * robots[ore] - blueprint[type][ore];
//     new_resources[clay] = resources[clay] + (cycles+1) * robots[clay] - blueprint[type][clay];
//     new_resources[obsidian] = resources[obsidian] + (cycles+1) * robots[obsidian];
//     new_resources[geode] = resources[geode] + (cycles+1) * robots[geode];

//     robots[type]++;
//     print("$space  [${24-time_left}] Trying to add robot $type -> needs $cycles ($cycles_for_ore/$cycles_for_clay)");
//     compute_rec(blueprint, robots, new_resources, time_left - cycles - 1);
//     robots[type]--;

//     return true;
//   }

//   if (robots[obsidian] == 0) {
//     // No current obsidian robots, we need to add one
//     int clay_cycles = ((blueprint[obsidian][clay]-resources[clay]) / robots[clay]).ceil();
//     print("$space  [${24-time_left}] Need to build obsidian. Need at least $clay_cycles.");
//     int needed_ore = blueprint[obsidian][ore];
//     bool added_ore = try_add_robot_before(ore, clay_cycles, needed_ore, true);
//     bool added_clay = try_add_robot_before(clay, clay_cycles, needed_ore, true);
//     print("$space [${24-time_left}] Tried to add ore and clay: $added_ore - $added_clay");
//     if (added_ore && added_clay) {
//       // If we could add either a clay or an ore robot, no need to try without.
//       // (but if we can add only one of them, them we need to try without,
//       // because it could enableto add it right after).
//       return;
//     }

//     List<int> new_resources = [0, 0, 0, 0];
//     new_resources[ore] = resources[ore] + clay_cycles * robots[ore];
//     new_resources[clay] = resources[clay] + clay_cycles * robots[clay];
//     // No need to update obsidian and geode resources

//     // Deducting the resources needed for the obsidian robot
//     new_resources[ore] -= blueprint[obsidian][ore];
//     new_resources[clay] -= blueprint[obsidian][clay];

//     robots[obsidian] = 1;
//     print("$space  [${24-time_left}] Adding obsidian");

//     // Checking if there are enough resources to build another robot right now.
//     // We never want to add both an ore and a clay robot at the same time as an
//     // obsidian robot: we would have added it earlier.
//     bool can_add_ore = false, can_add_clay = false;
//     if (new_resources[ore] >= blueprint[ore][ore] && robots[ore] < 6) {
//       // Adding an ore robot as well
//       can_add_ore = true;
//       new_resources[ore] = new_resources[ore] - blueprint[ore][ore] + robots[ore];
//       new_resources[clay] += robots[clay];
//       robots[ore]++;
//       print("$space  [${24-time_left}] Adding an obisidan + an ore");
//       compute_rec(blueprint, robots, new_resources, time_left - clay_cycles - 1);
//       robots[ore]--;
//       new_resources[ore] = new_resources[ore] + blueprint[ore][ore] - robots[ore];
//       new_resources[clay] -= robots[clay];
//     }
//     if (new_resources[ore] >= blueprint[clay][ore] && robots[clay] < 7) {
//       // Adding a clay robot as well
//       can_add_clay = true;
//       new_resources[ore] = new_resources[ore] - blueprint[clay][ore] + robots[ore];
//       new_resources[clay] += robots[clay];
//       robots[clay]++;
//       print("$space  [${24-time_left}] Adding an obisidan + a clay");
//       compute_rec(blueprint, robots, new_resources, time_left - clay_cycles - 1);
//       robots[clay]--;
//       new_resources[ore] = new_resources[ore] + blueprint[clay][ore] - robots[ore];
//       new_resources[clay] -= robots[clay];
//     }
//     if (can_add_ore && can_add_clay) {
//       robots[obsidian] = 0;
//       return;
//     }

//     new_resources[ore] += robots[ore];
//     new_resources[clay] += robots[clay];
//     print("$space  [${24-time_left}] Adding just obsidian");
//     compute_rec(blueprint, robots, new_resources, time_left - clay_cycles - 1);
//     robots[obsidian] = 0;
//     return;
//   } else {
//     // We want to add more geode robots
//     int obsidian_cycles = ((blueprint[geode][obsidian]-resources[obsidian]) / robots[obsidian]).ceil();
//     print("$space  [${24-time_left}] Want to add geode. Need at least $obsidian_cycles.");
//     int needed_ore = blueprint[geode][ore];

//     if (obsidian_cycles/2 >= time_left) {
//       // There is not enough time left to add a geode robot and have it mine a geode.
//       print("$space  [${24-time_left}] No more time to add geode");
//       resources[geode] += time_left * robots[geode];
//       compute_rec(blueprint, robots, resources, 0);
//       resources[geode] -= time_left * robots[geode];
//       return;
//     }

//     bool try_add_ore_and_clay = true;
//     if (obsidian_cycles + 1 >= time_left) try_add_ore_and_clay = false;

//     // if (try_add_robot_before(obsidian, obsidian_cycles, needed_ore)) {
//     //   // If we can add an obsidian robot without delaying this geode robot,
//     //   // there is no reason not to do it.
//     //   return;
//     // }

//     // Adding a clay or an ore robot could prevent us from adding an obsidian
//     // robot, so we are less aggressive there. We could optimize this by
//     // detecting that we are missing too much clay and that adding this ore/clay
//     // robot would not delay the obsidian robot.
//     try_add_robot_before(obsidian, obsidian_cycles, needed_ore);
//     try_add_robot_before(clay, obsidian_cycles, needed_ore);
//     try_add_robot_before(ore, obsidian_cycles, needed_ore);

//     if (!try_add_ore_and_clay) {
//       // This path can't work. Hopefuly, adding an obsidian robot worked, and the obsidian
//       // path worked.
//       resources[geode] += time_left * robots[geode];
//       compute_rec(blueprint, robots, resources, 0);
//       resources[geode] -= time_left * robots[geode];
//       return;
//     }

//     // Adding the geode robot

//     // Updating resources and robot count
//     List<int> new_resources = [0, 0, 0, 0];
//     for (int i = 0; i < 4; i++) {
//       new_resources[i] = resources[i] + obsidian_cycles * robots[i] - blueprint[geode][i];
//     }
//     robots[geode]++;

//     // Trying to add another robot as well. We assume that we can't add multiple
//     // robots at once here, which is probably a reasonable assumption...
//     if (new_resources[ore] >= blueprint[ore][ore] && robots[ore] <= 6 && time_left > 4) {
//       // Adding an ore robot as well
//       new_resources[ore] = new_resources[ore] - blueprint[ore][ore] + robots[ore];
//       new_resources[clay] += robots[clay];
//       new_resources[obsidian] += robots[obsidian];
//       new_resources[geode] += robots[geode] - 1;
//       robots[ore]++;
//       print("$space  [${24-time_left}] Adding a geode + an ore");
//       compute_rec(blueprint, robots, new_resources, time_left - obsidian_cycles - 1);
//       robots[ore]--;
//       new_resources[geode] -= robots[geode] - 1;
//       new_resources[obsidian] -= robots[obsidian];
//       new_resources[clay] -= robots[clay];
//       new_resources[ore] = new_resources[ore] + blueprint[ore][ore] - robots[ore];
//     }
//     if (new_resources[ore] >= blueprint[clay][ore] && robots[clay] <= 7 && time_left > 4) {
//       // Adding a clay robot as well
//       new_resources[ore] = new_resources[ore] - blueprint[clay][ore] + robots[ore];
//       new_resources[clay] += robots[clay];
//       new_resources[obsidian] += robots[obsidian];
//       new_resources[geode] += robots[geode] - 1;
//       robots[clay]++;
//       print("$space  [${24-time_left}] Adding a geode + an clay");
//       compute_rec(blueprint, robots, new_resources, time_left - obsidian_cycles - 1);
//       robots[clay]--;
//       new_resources[geode] -= robots[geode] - 1;
//       new_resources[obsidian] -= robots[obsidian];
//       new_resources[clay] -= robots[clay];
//       new_resources[ore] = new_resources[ore] + blueprint[clay][ore] - robots[ore];
//     }
//     if (new_resources[ore] >= blueprint[obsidian][ore] &&
//         new_resources[clay] >= blueprint[obsidian][clay] && time_left > 2) {
//       // Adding an obsidian robot as well
//       new_resources[ore] = new_resources[ore] - blueprint[obsidian][ore] + robots[ore];
//       new_resources[clay] = new_resources[clay] - blueprint[obsidian][clay] + robots[clay];
//       new_resources[obsidian] += robots[obsidian];
//       new_resources[geode] += robots[geode] - 1;
//       robots[obsidian]++;
//       print("$space  [${24-time_left}] Adding a geode + an obsidian");
//       compute_rec(blueprint, robots, new_resources, time_left - obsidian_cycles - 1);
//       robots[obsidian]--;
//       new_resources[geode] -= robots[geode] - 1;
//       new_resources[obsidian] -= robots[obsidian];
//       new_resources[clay] = new_resources[clay] + blueprint[obsidian][clay] - robots[clay];
//       new_resources[ore] = new_resources[ore] + blueprint[obsidian][ore] - robots[ore];
//     }

//     for (int i = 0; i < 4; i++) new_resources[i] += robots[i];
//     new_resources[geode]--;
//     print("$space  [${24-time_left}] Adding just a geode. It'll take $obsidian_cycles");
//     compute_rec(blueprint, robots, new_resources, time_left - obsidian_cycles - 1);

//     // Restoring robot count
//     robots[geode]--;
//   }

// }

// compute_max(List<List<int>> blueprint) {
//   // We start by moving forward a bit: we start when we already have built a
//   // clay robot and it has mined for 1 round.

//   int time_left = 24;
//   // Adding the clay robot
//   time_left -= blueprint[clay][ore] + 1 + 1; // -1 for the time to build it,
//                                              // and -1 for the time to mine once.

//   List<int> resources = [ 2, 1, 0, 0 ];
//   List<int> robots = [ 1, 1, 0, 0 ];

//   compute_rec(blueprint, robots, resources, time_left);
// }





String get_sig(minerals, robots, time_left) {
  StringBuffer res = StringBuffer();
  res.write("$time_left;");
  for (int i = 0; i < 4; i++) res.write("${minerals[i]}-");
  res.write(";");
  for (int i = 0; i < 4; i++) res.write("${robots[i]}-");
  return res.toString();
}

bool part1 = true;
int glob_best = 0;
int rec_count = 0;
var cache = <String>{};
List<int> stop_at = [ 5, 5, 3, 1 ];
void compute_max(List<List<int>> blueprint, List<int> minerals,
                 List<int> robots, int time_left) {
  rec_count++;
  if (time_left == 0) {
    int res = minerals[geode];
    if (res > glob_best) {
      glob_best = res;
    }
    return;
  }

  // Trying to add some robots
  for (var robot_type in [ore, clay, obsidian, geode]) {
    if (time_left <= stop_at[robot_type]) continue;
    // Heuristic to reduce the search space are super important for this
    // problem. Still, they are a bit hacky for part 1, and the heuristics for
    // part 2 are slightly wrong in the general case, so they don't work on part
    // 2, so I have 2 sets of heuristics for part 1 and part 2...
    if (part1) {
      if (robot_type == ore && robots[ore] == 10) continue;
      if (robot_type == clay && robots[clay] == 10) continue;
    } else {
      if (robot_type == ore && robots[ore] == blueprint[obsidian][ore] + blueprint[geode][ore] + 2)
        continue;
      if (robot_type <= obsidian && robots[obsidian] == blueprint[geode][obsidian]) continue;
      if (robot_type == clay && robots[clay] == blueprint[obsidian][clay] - 2) continue;
  }

    bool can_build = true;
    for (int i = 0; i < 4; i++) {
      if (blueprint[robot_type][i] > minerals[i]) can_build = false;
    }

    if (can_build) {
      for (int i = 0; i < 4; i++) minerals[i] += robots[i];
      for (int i = 0; i < 4; i++) minerals[i] -= blueprint[robot_type][i];
      robots[robot_type] += 1;
      compute_max(blueprint, minerals, robots, time_left-1);
      robots[robot_type] -= 1;
      for (int i = 0; i < 4; i++) minerals[i] += blueprint[robot_type][i];
      for (int i = 0; i < 4; i++) minerals[i] -= robots[i];
      // If we can build a geode robot, we don't want to try without it
      if (robot_type == geode) return;
    }
  }

  for (int i = 0; i < 4; i++) minerals[i] += robots[i];

  String sig = get_sig(minerals, robots, time_left-1);
  if (!cache.contains(sig)) {
    compute_max(blueprint, minerals, robots, time_left-1);
    cache.add(sig);
  }

  for (int i = 0; i < 4; i++) minerals[i] -= robots[i];
}

part1(blueprints) {
  // 3 min 30; a bit slow, but I don't have the courage to optimize :x
  int tot = 0;
  int i = 1;
  for (var blueprint in blueprints) {
    glob_best = 0;
    cache = <String>{};
    rec_count = 0;
    compute_max(blueprint, [0,0,0,0], [1,0,0,0], 24);
    print("$i: best=$glob_best  --  rec_count=$rec_count");
    tot += i++ * glob_best;
  }
  print("Part 1 : $tot");
}

part2(blueprints) {
  // Took 3 hours to run, but whatever :D
  part1 = false;
  int tot = 1;
  int i = 0;
  for (var blueprint in blueprints) {
    if (i++ == 3) break;
    glob_best = 0;
    cache = <String>{};
    rec_count = 0;
    compute_max(blueprint, [0,0,0,0], [1,0,0,0], 32);
    print("$i: best=$glob_best  --  rec_count=$rec_count");
    tot *= glob_best;
  }
  print("Part 2 : $tot");
}



main() {
  var input = read_input('input.txt');
  part1(input);
  part2(input);
}
