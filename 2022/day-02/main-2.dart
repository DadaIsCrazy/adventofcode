import 'dart:io';


enum Move { R, P, S }
enum Outcome { Lose, Draw, Win }

ABC_to_Move(String move) {
  switch (move) {
    case 'A': return Move.R;
    case 'B': return Move.P;
    case 'C': return Move.S;
  }
  throw "Invalid input for ABC_to_Move: " + move;
}

XYZ_to_Outcome(String outcome) {
  switch (outcome) {
    case 'X': return Outcome.Lose;
    case 'Y': return Outcome.Draw;
    case 'Z': return Outcome.Win;
  }
}

class Round {
  Move opponent;
  Outcome outcome;
  Round(this.opponent, this.outcome);
}

read_input() {
  List<Round> rounds = [];

  List<String> lines = new File('input.txt').readAsLinesSync();
  for (var line in lines) {
    var str_moves = line.split(' ');
    rounds.add(Round(ABC_to_Move(str_moves[0]), XYZ_to_Outcome(str_moves[1])));
  }

  return rounds;
}

Move get_move_for_outcome(Move opponent_move, Outcome outcome) {
  if (outcome == Outcome.Draw) return opponent_move;
  if (outcome == Outcome.Win) return Move.values[(opponent_move.index + 1)%3];
  return Move.values[(opponent_move.index - 1) % 3];
}

int score_move(Move move) {
  switch (move) {
    case Move.R: return 1;
    case Move.P: return 2;
    case Move.S: return 3;
  }
}

int score_round(Round round) {
  var move = get_move_for_outcome(round.opponent, round.outcome);
  return score_move(move) + round.outcome.index * 3;
}

part2(input) {
  var total = 0;
  for (Round round in input) {
    var score = score_round(round);
    total += score;
  }

  print("part2: $total");
}

main() {
  var input = read_input();

  part2(input);
}
