# Exception handling

See the section about error handling for more information about error handling in general. This section is dedicated to the exception handling specifically.

Always use braces with the `try-catch-finally` construct, even if the body of the `try` contains one expression:

```scala
// bad
try doSomething()
catch {
  ...
}

// good
try {
  doSomething()
} catch {
  ...
}
```

Do not catch `Throwable` or ignore exceptions inside `catch` clauses; never *ever* ignore the caught exceptions; at the very least you should log them:

```scala
try {
  ...
} catch {
  // this is wrong
  case e: Throwable => ...
}

try {
  ...
} catch {
  // this is VERY wrong
  case _ =>
}
```

Use `scala.util.control.NonFatal` in case you need to catch "all" exceptions:

```scala
try {
  ...
} catch {
  case NonFatal(e) => logger.error("Something bad happened", e)
}
```

Never write any non-local control flow instructions in the `finally` blocks. This includes `return`s, `throw`s and calling functions which may throw exceptions:

```scala
try {
  ...
} finally {
  // VERY bad
  throw AnotherException()
}
```

