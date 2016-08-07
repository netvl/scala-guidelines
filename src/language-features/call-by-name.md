# Call by name

Call by name is a way to "defer" the computation of a value passed into a function as an argument. It is a counterpart to the regular "call by value", when the argument to a function is computed entirely before the function is called:

```scala
def square(x: Int) = x * x

def squareByName(x: => Int) = x * x

def x: Int = { println("Computing x"); 8 }

square(x)        // prints "Computing x" once
squareByName(x)  // prints "Computing x" twice
```

Call by name allows the called function to determine when to compute its argument. This allows building incredibly powerful custom control structures, but it may also be a great source of confusion for the developer reading the code which uses such control structures.

Therefore, using call by name arguments is forbidden, unless its usage significantly increases readability. In general, if you need to get the semantics of a deferred computation, use a no-arguments function explicitly:

```scala
def squareDeferred(x: () => Int) = x() * x()

squareDeferred(() => x)
```

This syntax makes the fact that the value is computes multiple times clearly visible, both in the call site and in the called function.

