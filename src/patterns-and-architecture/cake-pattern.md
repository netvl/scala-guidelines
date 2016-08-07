# Cake pattern

See the full rule description [here][cake-pattern].

In short, while the cake pattern is nice in theory, it is hard to get it right and take all the necessary things like dependencies lifetime into account. It also makes testing more difficult as the number of dependencies of different cake components grow.

Therefore, the cake pattern must not be used to structure dependencies of different components. Other, more conventional tools like dependency injection libraries or even manual dependency passing should be used instead.

  [cake-pattern]: https://github.com/alexandru/scala-best-practices/blob/master/sections/3-architecture.md#31-should-not-use-the-cake-pattern
