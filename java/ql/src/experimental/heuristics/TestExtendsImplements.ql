import java
import experimental.heuristics.Heuristics

from Callable c
where
  c.getDeclaringType()
      .toString()
      .matches(["BasicClassicHttpRequest%", "BasicHttpRequest%", "HttpRequestWrapper%"]) and
  c.getDeclaringType().extendsOrImplements(_)
select c.getSourceDeclaration(), c.getDeclaringType(), c.getDeclaringType().getAnAncestor()
