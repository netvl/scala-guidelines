# Naming

## Length of names

Follow the rule "longer names for larger scopes, shorter names for smaller scopes". One-letter names for numeric loops indices are acceptable, same names for most of local variables and pattern variables are not.

## Apostrophes

Avoid using \`s to overload reserved names, except when there is a need to integrate with Java API or when the alternative reads significantly worse. Use of apostrophes in pattern matching for equality checking, on the other hand, is acceptable:

```scala
val name = "hello"

x match {
  case SomeClass(`name`) => ...
}
```

## Constant names

Constants must always follow the `PascalCase` naming rule, according to the default style used in Scala community. Do not use `CAPITAL_SNAKE_CASE` or `camelCase` for constant names.

Constants must always be defined in objects. If a constant is only used in one class, then it should be defined in its companion object. If a constant is used in multiple classes, it should be defined in some common object.

Constants must not be defined in package objects, with potential exception of type class instances declarations.

## Getters and setters

Do not prefix getters with `get`, just name the getter after the thing it retrieves:

```scala
trait Nameable {
  def name: String
}
```

In those (rare) cases when you need to declare a setter, use the standard Scala convention:

```scala
trait Nameable {
  def name: String
  def name_=(n: String): Unit
```

This syntax allows using the assignment syntax to change the property:

```scala
val obj: Nameable = ...
obj.name = "whatever"
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

Names shadowing can be resolved by the IDEs through syntax highlighting, but nevertheless is a bad idea because it is very easy to mistake one variable for another. Use more appropriate names for each variable and pattern.
