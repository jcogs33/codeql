import java
private import semmle.code.java.dataflow.ExternalFlow

string getApiName(Callable c) {
  result =
    c.getDeclaringType().getPackage() + "." + c.getDeclaringType().getSourceDeclaration() + "#" +
      c.getName() + paramsString(c)
}

from Callable c, string apiName
where
  c.getDeclaringType().getPackage().toString() = "java.lang" and
  c.getDeclaringType().getSourceDeclaration().toString() = "String" and
  c.getName() = "format" and
  apiName = getApiName(c)
//c.getParameterType(0).getErasure().toString() = "ObjectString"
//   or
//   c.getDeclaringType().getPackage().toString() = "java.lang" and
//   c.getDeclaringType().getSourceDeclaration().toString() = "String" and
//   c.getName() = "format"
select apiName order by apiName
