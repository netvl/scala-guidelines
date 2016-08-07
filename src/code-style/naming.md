# Naming

## Length of names

Follow the rule "longer names for larger scopes, shorter names for smaller scopes". One-letter names for numeric loops indices are acceptable, same names for most of local variables and pattern variables are not.

## Apostrophes

Avoid using \`s to overload reserved names. Use of apostrophes in pattern matching for equality checking, on the other hand, is acceptable:

```scala
val name = "hello"

x match {
  case SomeClass(`name`) => ...
}
```

## Constant names

Constants must always follow the `PascalCase` naming rule, according to the default style used in Scala community. Do not use `CAPITAL_SNAKE_CASE` or `camelCase` for constant names.

Constants must always be defined in objects. If a constant is only used in one class, then it should be defined in its companion object. If a constant is used in multiple classes, it should be defined in some common object.

Constants must not be defined in package objects.

## Getters

Do not prefix getters with `get`, just name the getter after the thing it retrieves:

```scala
trait Nameable {
  def name: String
}
```

## Names shadowing

Avoid clashes of the names with pattern matching, e.g. don't do this:

```scala
case class User(...)
case class Organization(owner: User)

val user = User(...)
...
organization match {
  case Organization(user) => ...  // user clashes with the above val
}
```

do e.g. this:

```scala
organization match {
  case Organization(owner) => ...
}
```

Names shadowing can be resolved by the IDEs, but nevertheless is a bad idea because it is very easy to mistake one variable for another. Use more appropriate names for each variable and pattern.
