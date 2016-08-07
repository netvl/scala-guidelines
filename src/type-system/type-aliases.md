# Type aliases

Defining type aliases for complex types is encouraged. However, self-explanatory types need not to be aliased. The following is a bad example:

```scala
type IntMaker = () => Int
```

Type aliases should be used instead of subtyping, when this subclassing does not actually extend the original type.

```scala
// don't do this
trait SocketFactory extends (SocketAddress => Socket)

// do this
type SocketFactory = SocketAddress => Socket
```

Type aliases are best defined in the companion objects of the classes they are used in, but if a particular type alias is exposed as a part of an API or otherwise is used in common by many other modules, it makes sense to put it into the package object.

