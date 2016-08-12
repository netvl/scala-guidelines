# Imports

## Imports order

Use the IDEA imports optimizer to sort imports. The following IDEA configuration snippet displays the optimal sort order:

```
java
_______ blank line _______
scala
_______ blank line _______
all other imports
_______ blank line _______
your.app.root.package
```

Source code files should not contain unused imports. Use IDEA imports optimizer to fix this, but remember that sometimes IDEA may remove imports which are actually used (this happens mostly with importing of implicits).

## Relative imports

Always use absolute imports; IDEA code style configuration should enforce this. Relative imports almost always decrease the readability.

## Imports location

Always put imports at the top of the file instead of nested scopes. In other words, imports must always be grouped together in one place. The only exception is when you need to use some kind of [DSL](../patterns-and-architecture/domain-specific-languages.html) which provides many identifiers which you don't want to pollute the file namespace. Examples of such DSLs are Cassandra's `QueryBuilder` and akka-streams `GraphDSL`.

## Wildcard imports

Avoid using wildcard imports, unless you're importing more than 6 items from the same package. This behavior is also enforced by IDEA.
