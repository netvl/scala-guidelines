# Tuples

Tuples are ubiquitous in Scala; they are used very often to carry around values of several different types together. Maps in Scala use tuples to represent their entries. However, tuples have a big drawback: they do not assign semantic meaning to the structure they represent.

It is acceptable for use cases when they are used extremely frequently, and the lack of such meaning is not harmful: map entries is a prominent example of this. However, avoid storing them in data structures as fields or as values of a collection, because it only makes things obscure. Compare:

```scala
val actions: Map[(String, String), (Cancellable, Deadline, String)] = ...

// vs

case class PropertyId(interface: String, key: String)
case class ScheduledAction(timer: Cancellable,
                           finalDeadline: Deadline,
                           payload: String)
val actions: Map[PropertyId, ScheduledAction] = ...
```

Case classes essentially are named tuples, and it is very easy to define them in Scala, so don't hesitate to do it.

This gets even more prominent when there is a need to access individual fields, for example, when iterating. Do not ever write this:

```scala
val joinedPayloadByInterface = actions.iterator
  .map(kv => kv._1._1 -> kv._2._3).toVector
  .groupBy(_._1)
  .map(kv => kv._1 -> kv._2.mkString)
```

This is much better:

```scala
val joinedPayloadByInterface = actions.iterator
  .map { case (propId, action) => propId.interface -> action.payload }
  .toVector
  .groupBy { case (interface, _) => interface }
  .map { case (interface, payloads) => interface -> payloads.mkString }
```

And even this is rather complex; split the chained operations into several variable bindings:

```scala
val singlePayloadByInterface = actions.iterator
  .map { case (propId, action) => propId.interface -> action.payload }
  .toVector

val allPayloadsByInterface = singlePayloadByInterface
  .groupBy { case (interface, _) => interface }

val joinedPayloadByInterface = allPayloadsByInterface
  .map { case (interface, payloads) => interface -> payloads.mkString }
```

This way the intention of the code is very clear even to a relatively casual reader.


