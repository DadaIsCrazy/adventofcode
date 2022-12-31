import 'dart:io';
import 'dart:math';

int snafu_to_decimal(String snafu) {
  num out = 0;
  int len = snafu.length;
  out: for (int i = 0; i < snafu.length; i++) {
    switch (snafu[i]) {
      case '0': continue out;
      case '1': out += pow(5,len-i-1); break;
      case '2': out += 2 * pow(5, len-i-1); break;
      case '-': out -= pow(5,len-i-1); break;
      case '=': out -= 2 * pow(5,len-i-1); break;
    }
  }
  return out.round();
}

String decimal_to_snafu(int n) {
  String out = "";

  int carry = 0;
  while (n != 0) {
    n += carry;
    int rem = n % 5;
    switch (rem) {
      case 0: out = '0' + out; carry = 0; break;
      case 1: out = '1' + out; carry = 0; break;
      case 2: out = '2' + out; carry = 0; break;
      case 3: out = '=' + out; carry = 1; break;
      case 4: out = '-' + out; carry = 1; break;
    }
    n -= rem;
    n = n ~/ 5;
  }
  if (carry != 0) {
    out = '1' + out;
  }

  return out.toString();
}

test_snafu_convs() {
  for (int n in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 2022, 12345, 314159265]) {
    String snafu = decimal_to_snafu(n);
    if (snafu_to_decimal(snafu) != n) {
      print("Bad conversion\n");
      exit(1);
    }
  }
}

main() {
  print(decimal_to_snafu(
          File('input.txt')
            .readAsLinesSync()
            .map((snafu) => snafu_to_decimal(snafu))
            .reduce((a,b) => a+b)));
}
