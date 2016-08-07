# Apply method on classes

`apply()` method allows to use an object with the function call syntax. With the exception of functions, this may lead to very obscure code; additionally, it may be hard to go to the definition of such method in an IDE.

For these reasons defining `apply()` method on classes is forbidden, unless these classes extend one of the standard functional traits. Defining an `apply()` method on `object`s is fine, however: this is a pretty well-known idiom for creating constructor functions:

```scala
class SomeContainer private () { ... }

// This is okay
object SomeContainer {
  def apply(name: String): SomeContainer = {
    val result = new SomeContainer()
    ...
    result
  }
}

// This is not
class CustomFunction {
  def apply(x: Int): String = "'$x'"
}

val f = new CustomFunction
f(10)
```


