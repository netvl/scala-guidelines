# General code style

As a general rule, constantly monitor warnings and other notices which your IDE shows you. IntelliJ IDEA in particular has clever analysis features which are very helpful to avoid many mistakes in the code style. If you use IDEA to make commits, enable "Before commit / Perform code analysis" option in its commit window - it will display all errors and warnings it sees in the code you're about to commit.

Sometime it is necessary to disable Scalastyle checks for a particular piece of code. To do so, you have to wrap the section of code with the following comments:

```scala
// scalastyle:off public.methods.have.type
...
// scalastyle:on public.methods.have.type
```

An example of when this would be necessary are null-heavy pieces of code (when interacting with Java libraries) or Play controllers in which public methods do not actually need return types.
