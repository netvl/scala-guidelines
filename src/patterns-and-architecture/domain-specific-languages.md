# Domain-specific languages (DSLs)

Scala is a very DSL-friendly language, because of certain features which make writing embedded DSLs easy:

* by-name arguments;
* symbolic method names;
* infix method calls;
* implicits.

DSLs may be immensely expressive and compress huge amounts of meaning into a few lines of code. And precisely because of this reason they tend to be impenetrable for a reader who does not know these DSLs in advance.

Therefore, it is strictly forbidden to create custom domain-specific languages, even if they do increase readability locally. Domain-specific language implementations are hard to maintain, and they make difficult for new developers to dive into the code base. Prefer less fancy solutions for the problems at hand.

Moreover, using DSLs provided by third-party libraries should also be avoided, unless these libraries are very important to make the work done (e.g. if they are a transitive dependency of some framework) or are the only ones which provide the necessary functionality. First, try to avoid using the DSL, if the library provides the same functionality without it. If it is not possible, and using a DSL is unavoidable, explain everything which is not clear at the first glance thoroughly in comments.

