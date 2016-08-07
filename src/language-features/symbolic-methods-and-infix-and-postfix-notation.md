# Symbolic methods and infix and postfix notation

Scala allows to define methods which consist of symbols instead of regular letters. Combined with the ability to call any method with the infix notation this allows one to define custom operators:

```scala
class Connectable {
  def =+~>(other: Connectable): Connectable = ...
}

val x = new Connectable
val y = new Connectable
x =+~> y
```

Symbolic method names do not convey what they do, and with the exception of regular well-known symbols (mathematical operations, `++`/`--` on collections, boolean operators, negation, etc.) tend to be obscure by themselves: `a =+~> x` could mean absolutely anything.

Therefore it is prohibited to define custom symbolic methods, while their use with the 3rd-party libraries should be as limited as possible. Naturally, using unicode characters, which is also allowed by the language, strictly prohibited as well.

Additionally, using the infix notation for calling regular, non-symbolic methods is discouraged and could be used only if it significantly increases readability. One example of a sufficiently motivated use of infix notation are matchers and other parts of the tests definition in ScalaTest.

Scala also allows calling methods using the postfix notation, when there is no dot present in the method call:

```scala
import scala.concurrent.duration._

val d = 10 minutes
```

Postfix method calls are forbidden in any form because they may lead to syntactic ambiguities. Dots should always be used instead:

```scala
val d = 10.minutes
```

