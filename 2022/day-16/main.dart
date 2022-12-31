import 'dart:io';
import 'dart:collection';
import 'dart:math';

// This is a bit slow (0.5 sec for the 1st part and 6.5 sec for the 2nd part).
// My approach is quite trivial ("just do a DFS"), so I'm sure that I missed
// something to optimize this. I'm a bit short on time, so I won't optimize this
// now, but I might look into it later. Some optimization ideas:
//  - use memoization (because different paths may lead to the same state)
//  - precompute some things for some subgraphs. On my input, there is a cluster
//    of 6 nodes, which is connected to the rest of the graph by just 1 edge, so
//    we might be able precompute something for this.
//  - do a first greedy pass to have a fairly large lower bound for the solution
//    so that pruning eliminates more nodes.
//  - compute a more precise bound for pruning. So far, we do something like "if
//    by opening the max-flow valve every 3 minutes until the end, we won't catch
//    the best so far, then prune". But we could probably be more aggressive there.
//
// I'm somewhat confident that this could get me down to 1 sec or so on the 2nd part,
// but I would expect that there exists an approch that is SimplyBetter™ and that would
// be much faster.
//
// Well, at the same time, if there was such a great idea, I think that the 2nd
// part would have been "given that it takes 4 minutes to train one elephant,
// how elephants should you enroll for optimal solution", and since it wasn't,
// the 2nd part might be a little bit expensive even when optimal... (although
// that's probably just a lame excuse to try to justify to not having optimized :D)

class Edge {
  int cost;
  String dst;
  Edge(this.cost, this.dst);
  String toString() {
    return "$dst[$cost]";
  }
}

class Node {
  int int_id;
  String id;
  int flow;
  List<Edge> neighbors;
  Node(this.int_id, this.id, this.flow, this.neighbors);

  String toString() {
    return "$id flow=$flow  neighbors=$neighbors";
  }
}

read_input(filename) {
  var graph = {};

  var lines = File(filename).readAsLinesSync();
  // Note: there are less than 64 inputs, so it's OK to set int_id here rather than after
  // the graph's simplification.
  var int_id = 0;
  var max_flow = 0;
  for (var line in lines) {
    var matched = RegExp(r'Valve (\w+) .*rate=(\d+);.*valves? (.*)').firstMatch(line);
    var id   = matched?.group(1) ?? "error";
    var flow = int.parse(matched?.group(2) ?? "error");
    var neighbors = (matched?.group(3) ?? "").split(', ');
    graph[id] = Node(int_id++, id, flow, neighbors.map((e) => Edge(1, e)).toList());
    max_flow = max(max_flow, flow);
  }

  // Trying to simplify the graph. This makes the 1st part a bit faster, but not
  // by much, in particular because I'm preventing the search from going back
  // without progress. And this doesn't work well with part 2.

  // var to_remove = <String>{};
  // for (Node node in graph.values) {
  //   if (node.neighbors.length == 2 && node.flow == 0) {
  //     var n1 = graph[node.neighbors[0].dst];
  //     var n2 = graph[node.neighbors[1].dst];
  //     if (n1.neighbors.indexWhere((n) => n.dst == n2.id) == -1) {
  //       var cost = node.neighbors[0].cost + node.neighbors[1].cost;
  //       n1.neighbors.add(Edge(cost, n2.id));
  //       n2.neighbors.add(Edge(cost, n1.id));

  //       n1.neighbors.removeWhere((e) => e.dst == node.id);
  //       n2.neighbors.removeWhere((e) => e.dst == node.id);

  //       to_remove.add(node.id);
  //     }
  //   }
  // }
  // for (String id in to_remove) {
  //   graph.remove(id);
  // }

  return [graph, max_flow];
}

part1_bfs(graph, max_flow) {

  // Printing graph in DOT format. Redirect to a file and run:
  //     dot -Tpdf file.dot -o out.pdf
  // to generate the .pdf graph.
  // print('graph {');
  // var seen = <String>{};
  // for (Node node in graph.values) {
  //   for (var n in node.neighbors) {
  //     if (seen.contains(n.dst)) continue;
  //     var dst_flow = graph[n.dst].flow;
  //     print('  "${node.id}\\n${node.flow}" -- "${n.dst}\\n${dst_flow}" [label="${n.cost}"]');
  //   }
  //   seen.add(node.id);
  // }
  // print('}');

  // Trying to BFS to the solution
  var queue = ListQueue();
  queue.add(['AA', 1, 0, 0, 0, ""]);//, [['AA',0,0,1]]]);
  var best = 0, best_opened = 0, best_flow = 0;
  int visited = 0;
  while (!queue.isEmpty) {
    visited++;
    var curr = queue.removeFirst();
    String id = curr[0];
    int time = curr[1];
    int tot = curr[2];
    int flow = curr[3];
    int opened = curr[4];
    String prev = curr[5];
    if (time >= 30) {
      if (time == 30) tot += flow;
      if (tot > best) {
        best = tot;
        best_opened = opened;
        best_flow = flow;
        print("\nNew best: tot=$tot  flow=$flow  opened=${opened.toRadixString(2)}");
      }
      continue;
    }
    if ((tot + (31 - time) * flow + (31-time)*max_flow*(31-time)/3 < best)) {
      // This path will never beat the current best.
      continue;
    }

    var node = graph[id];
    if (node.flow != 0 && (opened & (1 << node.int_id)) == 0) {
      queue.add([node.id, time+1, tot+flow, flow+node.flow,
          opened | (1 << node.int_id), ""]);
    }

    for (var e in node.neighbors) {
      if (e.dst == prev) continue;
      int n_time = time, n_tot = tot;

      for (int j = 0; j < e.cost; j++) {
        if (n_time <= 30) {
          n_tot += flow;
          n_time += 1;
        }
      }
      queue.add([e.dst, n_time, n_tot, flow, opened, node.id]);
    }
  }

  print("Best: $best");

  return graph;
}

// DFS is probably better than BFS for this problem because:
//  - pruning is probably a bit better with DFS (because the faster we
//    reach the end of a path, the faster we can start pruning).
//  - my queue-based DFS was allocating an array for each state, which
//    is probably slow. By comparison with this recursive approach we
//    just have to use some stack instead, but this might be faster.
part1_dfs(graph, max_flow) {
  var best = 0;

  recurse(String id, int time, int tot, int flow, int opened, String prev) {
    if (time >= 30) {
      if (time == 30) tot += flow;
      best = max(best, tot);
      return;
    }
    if ((tot + (31 - time) * flow + (31-time)*max_flow*(31-time)/3 < best)) {
      // This path will never beat the current best.
      return;
    }


    var node = graph[id];
    if (node.flow != 0 && (opened & (1 << node.int_id)) == 0) {
      recurse(id, time+1, tot+flow, flow+node.flow as int, opened | (1 << node.int_id), "");
    }

    for (var e in node.neighbors) {
      if (e.dst == prev) continue;
      int n_time = time, n_tot = tot;

      for (int j = 0; j < e.cost; j++) {
        if (n_time <= 30) {
          n_tot += flow;
          n_time += 1;
        }
      }

      recurse(e.dst, n_time, n_tot, flow, opened, id);
    }
  }

  recurse('AA', 1, 0, 0, 0, '');

  print("Part 1 : $best");

  return graph;
}

part1(graph, max_flow) {
  part1_dfs(graph, max_flow);
}


part2_dfs(graph, max_flow) {
  var best = 0;
  const max_time = 26;

  recurse(id1, id2, time, tot, flow, opened, prev1, prev2) {
    if (time >= max_time) {
      if (time == max_time) tot += flow;
      best = max(best, tot);
      return;
    }
    if ((tot + (max_time+1 - time) * flow +
        (max_time+1-time)*max_flow*(max_time+1-time)/3 < best)) {
      // This path will never beat the current best.
      return;
    }

    var node1 = graph[id1];
    var node2 = graph[id2];
    var can_recurse_1 = node1.flow != 0 && (opened & (1 << node1.int_id)) == 0;
    var can_recurse_2 = node2.flow != 0 && (opened & (1 << node2.int_id)) == 0;

    if (can_recurse_1 && can_recurse_2 && id1 != id2) {
      recurse(id1, id2, time+1, tot+flow, flow+node1.flow+node2.flow,
              opened | (1 << node1.int_id) | (1 << node2.int_id), "", "");
    }

    for (var e1 in node1.neighbors) {
      if (e1.dst == prev1) continue;
      if (can_recurse_2) {
        recurse(e1.dst, id2, time+1, tot+flow, flow+node2.flow,
                opened | (1 << node2.int_id), id1, "");
      }
      for (var e2 in node2.neighbors) {
        if (e2.dst == prev2) continue;
        recurse(e1.dst, e2.dst, time+1, tot+flow, flow, opened, id1, id2);
      }
    }
    if (can_recurse_1) {
      for (var e2 in node2.neighbors) {
        if (e2.dst == prev2) continue;
        recurse(id1, e2.dst, time+1, tot+flow, flow+node1.flow,
                opened | (1 << node1.int_id), "", id2);
      }
    }
  }

  recurse('AA', 'AA', 1, 0, 0, 0, '', '');

  print("Part 2 : $best");

  return graph;
}

part2(input, max_flow) {
  part2_dfs(input, max_flow);
}

main() {
  var input = read_input('input.txt');
  part1(input[0], input[1]);
  part2(input[0], input[1]);
}
