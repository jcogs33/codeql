import java
import semmle.code.java.dataflow.ExternalFlow

private predicate isJdkInternal(Package p) {
  p.getName().matches("org.graalvm%") or
  p.getName().matches("com.sun%") or
  p.getName().matches("javax.swing%") or
  p.getName().matches("java.awt%") or
  p.getName().matches("sun%") or
  p.getName().matches("jdk%") or
  p.getName().matches("java2d%") or
  p.getName().matches("build.tools%") or
  p.getName().matches("propertiesparser%") or
  p.getName().matches("org.jcp%") or
  p.getName().matches("org.w3c%") or
  p.getName().matches("org.ietf.jgss%") or
  p.getName().matches("org.xml.sax%") or
  p.getName().matches("com.oracle%") or
  p.getName().matches("org.omg%") or
  p.getName().matches("org.relaxng%") or
  p.getName() = "compileproperties" or
  p.getName() = "transparentruler" or
  p.getName() = "genstubs" or
  p.getName() = "netscape.javascript" or
  p.getName() = ""
}

string getApiName(Callable c) {
  result =
    c.getDeclaringType().getPackage() + "." + c.getDeclaringType().getSourceDeclaration() + "#" +
      c.getName() + paramsString(c)
}

from
  Callable callable, string paramsString, string paramIdx, string paramLoc, string paramType,
  string paramName, string kind, string apiName
where
  paramsString = paramsString(callable) and
  paramLoc = "Argument[" + paramIdx + "]" and
  paramType = callable.getParameterType(paramIdx.toInt()).getErasure().toString() and
  paramName = callable.getParameter(paramIdx.toInt()).getName() and
  //kind = "create-file" and // * update sink kind looking for here
  (kind = "jdbc-url" or kind = "open-url") and
  sinkModel(callable.getDeclaringType().getPackage().toString(),
    callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
    [paramsString(callable), ""], _, paramLoc, kind, _) and
  // sinkModel(_, callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
  //   [paramsString(callable), ""], _, paramLoc, kind, _) and
  not isJdkInternal(callable.getDeclaringType().getPackage()) and
  apiName = getApiName(callable)
select paramType, paramName, apiName, paramLoc, paramsString, callable order by
    paramType, paramName, apiName
// from Callable callable, string apiName
// where
//   sinkModel(callable.getDeclaringType().getPackage().toString(),
//     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//     [paramsString(callable), ""], _, _, "create-file", _) and
//   not isJdkInternal(callable.getDeclaringType().getPackage()) and
//   apiName = getApiName(callable)
// select apiName, callable order by apiName
// from Callable callable
// where callable.getDeclaringType().getPackage().toString().matches("org.apache.http%")
// select callable, callable.getDeclaringType().getPackage().toString()
