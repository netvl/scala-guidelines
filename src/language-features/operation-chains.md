# Operation chains

Many of the standard and non-standard Scala types contain so-called monadic operators, most notable of them being `map`, `flatMap` and `filter`. Scala collections provide many more operations which can also be chained in the same way.

This is a very powerful tool which allows expressing complex patterns very concisely. However, precisely for this reason - because such chains allow the code to be very dense in terms of meaning per line of code - chaining should be used sparingly.

In general, follow these rules:

1. Avoid chaining more than a few operations. The actual number will vary depending on the situation, but it usually should not be more than 5-7 operations at max. Split longer chains by creating temporary variables.

2. As a follow-up to the previous rule, the maximum number of chained operations heavily depends on the size of the code which is passed to the combinator functions. In other words, you should chain less operations if the lambdas you used are relatively large. The opposite does not hold, however: you shouldn't chain more operations just because your lambdas are small; while this may make sense depending on the situation, splitting chains and saving parts of expressions in separate variables is almost always a good thing.

3. As a rule of thumb, if understanding what a particular sequence of operations does takes more than 5-10 seconds, you should try to rewrite it in a simpler way.

Here is an example copied from the Twitter's Effective Scala:

```scala
val votes = Seq(("scala", 1), ("java", 4), ("scala", 10), ("scala", 1), ("python", 10))
val orderedVotes = votes
  .groupBy(_._1)
  .map { case (which, counts) => 
    (which, counts.foldLeft(0)(_ + _._2))
  }.toSeq
  .sortBy(_._2)
  .reverse
```

This piece of code is incomprehensible to anyone except its original author, and even they will forget what they meant in a very short time. Splitting the chain in logical parts and avoiding tuple accessors in favor of using named parameters allows to make the code much clearer:

```scala
val votesByLang = votes groupBy { case (lang, _) => lang }
val sumByLang = votesByLang map {
  case (lang, counts) =>
    val countsOnly = counts map { case (_, count) => count }
    (lang, countsOnly.sum)
}
val orderedVotes = sumByLang.toSeq
  .sortBy { case (_, count) => count }
  .reverse
```

