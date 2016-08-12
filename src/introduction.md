# Introduction

Scala language has lots of features over the baseline Java, and many of them provide a quite significant boost in readability and correctness of the code, as well as productivity of a developer. However, many of these features, and many libraries which are or are not based on these features require considerable experience to be used correctly and actually hinder readability of the code, especially for people who are unfamiliar with the concepts used in these libraries, with the code base, or with the whole JVM/Java/Scala ecosystem in general.

The intention of this document is to provide a general overview of Scala usage practices which should be employed to keep the code base approachable, understandable and maintainable, while not hindering the developers productivity. These practices are also intended to allow new developers to get accustomed with the existing code more easily, and to make sure that they do not need to have significant background in mathematics or functional programming languages in order to start to hack on the code quickly.

Some of these practices are enforced automatically with the code style analyzers and linters, and therefore their violation will result in a failed build. Most, however, are enforced through the code review process. Therefore, it is absolutely necessary for the reviewers to understand this document by heart and apply it rigorously. To help with this task, a dedicated section at the end of the document serves as a handbook for reviewers, providing a list of most important things to look for during the code review.

This document is heavily based on the following existing Scala guidelines:

* [Twitter's Effective Scala](https://twitter.github.io/effectivescala/)
* [Databricks Scala Guide](https://github.com/databricks/scala-style-guide)
* [Scala Best Practices](https://github.com/alexandru/scala-best-practices)

as well as our own experience in writing Scala code.

This document will be updated in the future to include things we will encounter when dealing with new code contributions.

