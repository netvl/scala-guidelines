# Braces

## Definitions

Avoid using braces for simple expressions; write this:

```scala
def square(x: Int) = x * x
```

but not this:

```scala
def square(x: Int) = {
  x * x
}
```

even though it may be tempting to distinguish the method body syntactically. The first alternative has less clutter and is easier to read. Avoid syntactical ceremony unless it clarifies.

## Scoping and blocks

It is acceptable to use braces in order to limit the namespace pollution, but this should almost always be used only when the result of the block is assigned to another variable:

```scala
val someValue = {
  val localVariable = ...
  ...
}
```

Moreover, using blocks to put complex expressions in other expressions, most notable function calls, hinders readability in a really bad way and should be avoided:

```scala
// bad
someFunction(arg1, arg2, {
  ...more code...
}, arg4)

// good
val arg3 = {
  ...more code...
}
someFunction(arg1, arg2, arg3, arg4)
```

