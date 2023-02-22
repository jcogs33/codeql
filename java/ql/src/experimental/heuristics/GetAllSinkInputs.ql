import java
import semmle.code.java.dataflow.ExternalFlow

from Callable c
where
  sinkModel(c.getDeclaringType().getPackage().toString(),
    c.getDeclaringType().getSourceDeclaration().toString(), _, c.getName(), _, _,
    ["", "ReturnValue"], _, _)
select c
