# `abstract override` modifier

Scala allows to "incrementally" extend a root trait, delegating to linear supertypes in a sequential manner. One of the most common usages of such feature is to create a collection of some items provided by separate trait implementations. This can be used, for example, to implement some kind of module system:

```scala
trait Modules {
  def modules: Vector[Module]
}

trait EmptyModules extends Modules {
  override def modules: Vector[Module] =
    Vector.empty
}

trait PluginAModules extends Modules {
  abstract override def modules: Vector[Module] =
    super.modules :+ pluginAModule
}

trait PluginBModules extends Modules {
  abstract override def modules: Vector[Module] =
    super.modules ++ Vector(pluginBFirstModule, pluginBSecondModule)
}

class FinalModules
  extends EmptyModules
  with PluginAModules
  with PluginBModules

println(new FinalModules().modules)  // prints Vector(pluginAModule, pluginBFirstModule, pluginBSecondModule)
```

Another use of `abstract override` is to implement static chain of responsibility pattern, when all chain elements are compiled statically.

`abstract override` is difficult to get right, and it is extremely confusing because it is often very hard to understand in which order traits methods are called. For this reason using `abstract override` is forbidden. There are almost always better ways to do the same thing.

