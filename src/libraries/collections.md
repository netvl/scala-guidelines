# Collections

Scala has a very powerful collections library, which contains immutable, mutable and parallel collections for virtually any purpose. While its implementation is quite complex, and extending it may be hard and would require using complex language features like higher-kinded types and implicits, in the everyday work it is very easy to use. To use the collections library efficiently, it is highly recommended to read [the official overview](http://docs.scala-lang.org/overviews/collections/introduction.html) of the collections library first.

## Overview

Here is a diagram of the basic collection types, both mutable and immutable:

**TODO (traversable, iterable, seq, set, map)**

The base trait, `Traversable[T]`, represents something which can be internally iterated - it provides a `foreach(f: T => Unit)` method which calls its argument for every item contained in the collection. This trait is very general and it can describe not only regular collections like lists or sets, but also e.g. ephemeral streams of data.

`Iterable[T]` is something which can be externally iterated - being quite similar to Java's `Iterable<T>`, it has one method, `def iterator: Iterator[T]`, which returns an iterator which can be used to walk over the collection. `foreach()` implementation for an `Iterable` is trivial, therefore it extends `Traversable`.

`Seq`, `Set` and `Map` are base types for the respective "kinds" of collections. `Seq`s are collections whose items are laid out sequentially and therefore can be accessed using zero-based index. `Set`s are collections which cannot contain duplicate elements, and usually have effective membership check. `Map`s are collections of key-value pairs where keys are unique, and they usually have effective lookup by key.

There is one weird quirk of the standard Scala library which should always be taken into account. `Map` and `Set`, when used in the regular code without any special imports, come from `scala.Predef` object (whose internals are imported into every Scala file automatically), and there they are declared as aliases to `scala.collection.immutable.*` types:

```scala
type Map = scala.collection.immutable.Map
type Set = scala.collection.immutable.Set
```

On the other hand, the alias for `Seq` is declared in `scala` package object, and it points to the root `scala.collection.Seq` type:

```scala
type Seq = scala.collection.Seq
```

Therefore, without any extra imports, variables with `Seq` type can hold both mutable and immutable collections, while `Map` and `Set` can hold immutable collections only. This inconsistency is quite jarring, but there is no simple way around it, and one must only remember how things are. The consequence is that using `Seq` is discouraged, but using `Map` and `Set` is fine.

## Usage

### Collection constructors

When creating new instances of collections, use the default constructor for collection types, unless you do need a specific collection type for some purpose (e.g. `TreeSet` for ordered iteration):

```scala
val set = Set(1, 2, 3)
val map = Map("a" -> 1, "b" -> 2)
```

There is one exception from this rule: use `Vector` where possible to create instances of `Seq` type instead of the default `Seq` constructor:

```scala
val seq = Vector(1, 2, 3)
```

The rationale for this rule is that `Vector` collection is almost always preferable to `List`, and the `Seq` default constructor delegates to the `List` constructor.

The reasons why `Vector` should be preferred are listed, for example, [here](http://stackoverflow.com/questions/6928327/when-should-i-choose-vector-in-scala). In short, `Vector` is faster than `List` for almost all operations and is more memory-efficient. Because it is a trie consisting of arrays, memory and cache locality are also better for `Vector`. Unless you're writing a "hot" algorithm which heavily depends on a list-like structure (prepending to a collection and accessing its head and tail), `Vector` would perform better than `List`, and therefore should always be used. It is also harder to accidentally index a sequence in an inefficient way whey `Vector`s are used instead of `List`s.

And another reason for using concrete method is that the overall usage of `Seq` is discouraged (see the previous section).

Use `Collection.empty` to create empty instances of collections instead of `Collection()`:

```scala
var cache: Map[String, Item] = Map.empty  // not Map()

var queue: Vector[Item] = Vector.empty  // not Vector()
```

Using the explicit `.empty` method helps readability, since with it you're stating that you need an empty collection explicitly.

### Collection types

Use `Map`, `Set` and `Vector` as default types for returning values from functions, for storing values in ADTs and for variables and fields:

```scala
def createUsers(params: Whatever): Vector[User] = ...

case class Application(parameters: Map[String, String])

class SomethingDoer(parameters: Parameters) {
  private val itemsCache: Set[Item] = computeItemsCache(parameters)
  ...
}
```

Of course, that is unless some specific collection type is necessary for its operations and/or semantics.

Use the most general type available for parameters of a method:

```scala
def processItems(items: Traversable[Item]): Unit = ...

def transformItems(items: Iterable[Item]): Vector[Item] =
  items.iterator.filter(_.someCondition).map(transform).toVector

def needsAMap(map: Map[String, Int]): Int = map.getOrElse("x", 0)
```

### Mutable collections

Always prefer immutable collections to mutable ones. Being immutable, they make it easier to reason about their usage, and they are also thread-safe by default. Mutable collections should be used only for performance reasons (if they are mutated frequently, they may be faster than immutable collections stored in a `var`) and for certain classes of algorithms which are clearer when are based on a mutable collection.

If you decided to use a mutable collection, the `mutable` package name must always be imported and used instead of importing the collection name directly:

```scala
import scala.colleciton.mutable

val items: mutable.Map[String, Int] = mutable.Map.empty
```

If you use IntelliJ IDEA, it enforces this style for mutable collections.

### Interacting with Java collections

Avoid using Java collections, unless they are needed for interfacing with Java code. In order to transform Scala collections to Java collections and back, use the implicit `asJava*` and `asScala*` methods imported from `scala.collection.convert.{decorateAs*}` objects:

```scala
import scala.collection.convert.decorateAsJava._

someJavaMethodAcceptingList(Vector(1, 2, 3).asJava)
```

Never use `scala.collection.convert.wrapAs*` objects, as well as `scala.collection.JavaConversions`, which provide implicit conversions to Java classes, as opposed to decorators. `scala.collection.JavaConverters` is functionally equivalent to `scala.collection.convert.decorateAll`, but objects defined in `scala.collection.convert` package are more granular and convey the intention better, therefore avoid using `JavaConverters` in favor of `decorate*` objects.

### Transformations and iterators

When you're chaining more than one collection operation, or when you're transforming an original collection type (e.g. a set of identifiers) to another collection type (e.g. a map of identifiers to the things they identify), it is recommended to transform the collection to an iterator first and then do all transformations on the iterator instead of the original collection, and then collect the resulting iterator to the final collection:

```scala
val itemIds: Set[String] = ...

val itemsIterator = itemIds.iterator.flatMap(itemsDao.findById)
val itemsByName = items.map(item => item.name -> item).toMap
```

The reason for this recommendation is that all transformations on collections create intermediate collections as their results:

```scala
val items = itemsIds.flatMap(itemsDao.findById)  // items: Set[Item]
val itemsByName = items
  .map(item => item.name -> item)  // <temporary>: Set[(String, Item)]
  .toMap
```

When transformations are done on iterators, no intermediate collections are created, and the chain of transformations of iterators is done lazily. Operations like `toMap/toSet/toVector` or `fold/reduce` eagerly consume the iterator, creating the final collection in one go.

Note that not all operations are available on iterators, like `groupBy`. Also, if you need to reuse the intermediate result multiple times, be sure to collect it to a concrete collection first, because iterators can only be used once:

```scala
val items = itemIds.iterator.flatMap(itemsDao.findById).toVector
val itemsByName = items.iterator.map(item => item.name -> item).toMap
val itemsById = items.iterator.map(item => item.id -> item).toMap
```

If you're using `for` comprehensions, you can convert various types, e.g. `Option`s, to iterators to make sure that all types are uniform and there is no funny behavior e.g. with maps or sets (where because of the uniqueness constraint of elements it is possible for mapped elements to be dropped silently). The above examples are actually better written as a `for` comprehension:

```scala
val itemsByNameIterator = for {
  itemId <- itemIds.iterator
  item <- itemsDao.findById(itemId).iterator
} yield item.name -> item
val itemsByName = itemsByNameIterator.toMap
```

When you assign iterators to variables, name the variables with `Iterator` suffix to distinguish them from regular collections.

An alternative to iterators would be using collection views, which are essentially reusable iterators. However, views in Scala implement the same interfaces as regular collections, and therefore it is easy to store e.g. `MapView` as a `Map`. This is bad, because transformations applied to views are not executed eagerly, they are delayed until elements of the view are accessed, just like with iterators. When such a view is stored in a frequently used variable, all these transformations will be recomputed each time when elements of the view are accessed.

Using views may sometimes be beneficial (e.g. when you want to keep the concrete type of a collection after a sequence of transformations), but it is very easy to forget to call `.force` on the view object to go back to a non-ephemeral collection, so they should be used with care. Never return views from functions, and never store views into other objects; they must be used only for temporary transformations. If you need to create a reusable part of a transformation chain, create a function which returns `Iterator` instead.

Another thing to be aware of with regard to views is that some of the convenient collection methods like `.mapValues` on a map actually return views instead of doing transformations, however, such views do not actually implement the view traits and therefore they do not have a `.force` method. **TODO: add a list of such methods here**

If you're doing only a single transformation operation, and you need to get a collection of the same type as the original collection, omit the iterator conversion because the necessary type will be constructed automatically:

```scala
val itemIds: Set[String] = ...
val items: Set[Item] = itemIds.flatMap(itemsDao.findById)
```


