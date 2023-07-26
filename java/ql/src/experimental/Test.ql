import java
import semmle.code.java.dataflow.ExternalFlow

from Callable c
where
  c.getDeclaringType().getCompilationUnit().getPackage().getName() = "java.util" and
  c.getDeclaringType().getSourceDeclaration().nestedName() = "List" and
  c.getName() = "add" and
  paramsString(c) = "(Object)" //and
// summaryModel(c.getDeclaringType().getCompilationUnit().getPackage().getName(),
//   c.getDeclaringType().getSourceDeclaration().nestedName(), _, c.getName(), paramsString(c), _, _,
//   _, _, _)
select c
