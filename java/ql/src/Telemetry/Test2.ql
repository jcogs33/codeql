import java
import semmle.code.java.dataflow.ExternalFlow
import Telemetry.ExternalApi

from ExternalApi extApi
where
  //   extApi.getDeclaringType().getPackage().toString() = "java.lang" and
  //   extApi.getDeclaringType().getSourceDeclaration().toString() = "StringBuilder" and
  //   extApi.getName() = "append" and
  extApi.getParameterType(0).getErasure().toString() = "ObjectString"
//   or
//   c.getDeclaringType().getPackage().toString() = "java.lang" and
//   c.getDeclaringType().getSourceDeclaration().toString() = "String" and
//   c.getName() = "format"
select extApi.getDeclaringType().getPackage() + "." +
    extApi.getDeclaringType().getSourceDeclaration() + "#" + extApi.getName() + paramsString(extApi)
