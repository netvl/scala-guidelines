# Return type annotations

Scala allows one to omit return type annotations on `def`s. However, these annotations increase readability and help to avoid many issues with the type system, therefore all public-facing methods must have return types:

```scala
trait PublicInterface {
  def computeValue(input: String): AnotherEntity
}
```

This includes overrides in the classes extending the supertype:

```scala
class PublicInterfaceImpl extends PublicInterface {
  override def computeValue(input: String): AnotherEntity = {
    ...
  }
}
```

It is acceptable to omit return types for *short* local functions or private methods, but only when it is very clear what the return type is, for example:

```scala
def updatedUser(user: User) = user.copy(parameter = anotherValue)
```

Here it is clear that the returned value is `User`, and the function itself is short, so it is okay to omit the return type.

