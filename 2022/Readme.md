Advent of code 2022
===

You can find in this repository my solutions to the 
[Advent of Code 2022](https://adventofcode.com/2022) by Eric Wastl.

I didn't know any Dart before starting this fun project, and took this
opportunity to learn this language. As a result, my code is probably
not idiomatic, and no one should use it as a good example of how to
write Dart code.

Still, the algorithms I used should be reasonably efficient (or, at
least, efficient enough to solve all the problems), and you can draw
inspiration from them.

Regarding my takeaways from learning Dart:

 - The type inference is incredibly disappointing. A lot of times,
   I've had the typer complain that `num` and `int` aren't compatible,
   or typing somewhat obvious lists to `List<dynamic>` instead of
   something more precise. It was annoying.
   
 - Some modern-ish simple features are omitted in the language, which
   I find a bit disappointing as well. A few examples:
   * There is no simple way to iterate over a range of number with
     something like `for (var x in 1 .. 10)`. Instead, one has to
     either use a C-style for loop (which looks a bit ugly/overly
     complex/archaic), or iterate over a List built with
     `List.generate` (which sounds bad for performance).
   * Tuples are not builtin are require using an external
     modules. This means that one can't easily have function return
     multiple values with explicit types (and because type inference
     isn't so great, this can become an issue).
   * Dart doesn't support destructuring assignment (like `var (x, y) =
     f()`). 
 
   This makes the code unnecessarily verbose.  I didn't take notes
   while coding, so those are just the examples I can think of right
   now, but I'm pretty sure that there other useful missing features.

 - null-safety is reasonably nice (sadly one of the few things I liked
   about the language). The fact that the compiler is able to
   recognize null-checks and not require `!` or `??` after them, while
   requiring those operators when null-checks are omitted is nice, and
   probably useful to catch bugs.

Overall, I probably won't be using Dart again anytime soon...

