import 'dart:io';


enum Move { R, P, S }

ABCXYZ_to_RPS(String move) {
  switch (move) {
    case 'A': return Move.R;
    case 'B': return Move.P;
    case 'C': return Move.S;

    case 'X': return Move.R;
    case 'Y': return Move.P;
    case 'Z': return Move.S;
  }
  throw "Invalid input for ABCXYZ_to_RPS: " + move;
}

class Round {
  Move opponent;
  Move me;
  Round(this.opponent, this.me);
}

read_input() {
  List<Round> rounds = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var str_moves = line.split(' ');
    rounds.add(Round(ABCXYZ_to_RPS(str_moves[0]), ABCXYZ_to_RPS(str_moves[1])));
  }

  return rounds;
}

int score_move(Move move) {
  switch (move) {
    case Move.R: return 1;
    case Move.P: return 2;
    case Move.S: return 3;
  }
}

int score_round(Round round) {
  var base = score_move(round.me);
  if (round.opponent == round.me) return 3 + base;
  if (round.opponent.index == (round.me.index + 1) % 3) return 0 + base;
  // If we reach this point, {me} is neither {opponent}+1, nor {opponent}, so it
  // has to be {opponent}-1 (which wins).
  return 6 + base;
}

part1(input) {
  var total = 0;
  for (Round round in input) {
    var score = score_round(round);
    total += score;
  }

  print("part1: $total");
}

main() {
  var input = read_input();

  part1(input);
}
