## Comments

Use Scaladoc to provide API documentation. Use the following style:

```scala
/**
 * ServiceBuilder builds services 
 * ...
 */
```

but not the standard Scaladoc style:

```scala
/** ServiceBuilder builds services
  * ...
  */
```

Public API must always be documented with Scaladoc. This includes public methods, classes/objects and constants. Make sure to keep the documentation up-to-date with code changes.

Write comments to clarify parts of logic which are not obvious, but *only* when it is absolutely impossible to rewrite the logic to be obvious in the first place. In general, try follow the rule "readable code comments itself".

`TODO:`-like comments are acceptable when they are really necessary but should not be overused.
