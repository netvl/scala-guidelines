# Operations nesting and `for` comprehensions

`for` comprehensions are a very nice syntactic sugar in Scala which allows expressing certain patterns in a very clean way. Of course, just like any other feature, it is crucial not to overuse it.

As a rule of thumb, prefer `for` comprehensions to nested `flatMap`s and `map`s, for example, when you need to flatten several collections. `for` comprehensions are rewritten internally into a nested sequence of method calls, so be careful for using `for`s in performance-critical code.

Be aware of implications of using `for` comprehensions for futures. See the section on concurrency for more on that.

## Using `for` comprehensions for different types

`for` comprehensions may be used with types which have `flatMap`, `map` and `withFilter` methods, and they do not guard you from using different types for each binding clause if it is allowed by typing:

```scala
val ints = Vector(1, 2, 4, 5)
val m = Map(1 -> "a", 3 -> "c")

for {
  n <- ints
  s <- m.get(n)
} yield s
```

This compiles, even though `ints` is of type `Vector[Int]` and `m.get(n)` is of type `Option[String]`. This is compiled into

```scala
ints.flatMap(n => m.get(n))
```

`flatMap` on Scala collections allows its argument function to return anything convertible to an iterable, and `Option[T]` satisfies this requirement. This makes the code harder to understand and, in some subtle cases, may lead to unexpected behavior, in particular, when collections with uniqueness semantics of keys or values (like maps or sets) are used. Therefore, in most cases when you need to iterate over multiple collections in a nested fashion, convert them to a common type. Usually it makes sense to use `.iterator` for that:

```scala
val resultsIterator = for {
  (interface, peers) <- signals.iterator
  (peer, values) <- peers.iterator
  value <- values.iterator
} yield interface -> value

val results = resultsIterator.toMap
```

