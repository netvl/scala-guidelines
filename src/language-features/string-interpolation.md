# String interpolation

Scala allows writing references to other variables in scope inside strings using a special syntax:

```scala
val n = 10
println(s"The value is $n, for your information")
```

This syntax should be used instead of string formatting:

```scala
// bad
println("The value is %s, for your information".format(n))
```

and instead of explicit concatenation:

```scala
// also bad
println("The value is " + n + ", for your information")
```

String interpolation is both more concise and more performant than its alternatives, and it makes the code more readable.

Avoid using long expressions inside the string, though; if computation is long, store it in a lazy variable or a `def`:

```scala
val results: Map[String, Either[Vector[Error], Unit]] = ...

// bad
logger.error(s"Errors happened: ${errors.valuesIterator.flatMap(_.left.toOption).flatten.mkString(", ")}")

// good
def errorsIterator = for {
  result <- results.valuesIterator
  errors <- result.left.toOption.iterator
  error <- errors.iterator
} yield error

def errorsString = errorsIterator.mkString(", ")

logger.error(s"Errors happened: $errorsString")
```

The good variant is longer, but its intention is clearer for an unaccustomed reader. As a general rule, avoid nested braces inside the interpolated string. For example, nested field access is fine:

```scala
val message = "Owner name: ${organization.owner.name}"
```

But method calls should better be extracted to a separate `def`:

```scala
// bad
val message = "Owner email: ${organization.owner.email.getOrElse("<unknown>")}";

// better
def ownerEmail = organization.owner.email.getOrElse("<unknown>");
val message = "Owner email: $ownerEmail"
```

