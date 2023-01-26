import java
import semmle.code.java.dataflow.ExternalFlow
import semmle.code.java.dataflow.DataFlow

// my attempt without dataflow (to see if it's even necessary: most results can be found without dataflow it seems)
class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

Callable getASqlInjectionVulnerableParameterNameBasedGuess(int paramIdx) {
  exists(Parameter p |
    //p.getName() = "sql" and
    //p.getName().matches(["sql%", "query%"]) and // ! seems FP prone (sqlType, etc.) -- but sqlType is an int, so can maybe use parameter-type to restrict more...
    p.getName() in ["sql", "sqlString", "queryString"] and
    p = result.getParameter(paramIdx)
  )
}

query Callable getASqlInjectionVulnerableParameter(int paramIdx, string reason) {
  result = getASqlInjectionVulnerableParameterNameBasedGuess(paramIdx) and
  reason = "nameBasedGuess"
}

predicate hasOverloads(PublicCallable c) {
  exists(PublicCallable other |
    other.getDeclaringType() = c.getDeclaringType() and
    other.getName() = c.getName() and
    other != c
  )
}

string signatureIfNeeded(PublicCallable c) {
  if hasOverloads(c) then result = paramsString(c) else result = ""
}

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

query string getASqlInjectionVulnerableParameterSpecification() {
  exists(Callable c, int paramIdx |
    c = getASqlInjectionVulnerableParameter(paramIdx, _) and
    result =
      c.getDeclaringType().getPackage() + ";" + c.getDeclaringType().getName() + ";" + "false;" +
        c.getName() + ";" + signatureIfNeeded(c) + ";;" + "Argument[" + paramIdx + "];" + "sql" +
        ";PARAMS-INFO: " + c.getParameter(0).getName() and
    not isJdkInternal(c.getDeclaringType().getPackage())
  )
}

// ! Notes:
// TODO: look into `java.sql;Connection;false;nativeSQL;;;Argument[0];sql` more -- seems like this should at least be a summary if not a sink
// from existingSink
// where existingSink is of kind ____
// select "(" + existingSink.getParameter(input arg position).getName()
// from DataFlow::Node sink
// where sinkNode(sink, "sql")
// select sink.asExpr()
// from Callable c, string kind
// where
//   kind = "sql" and
//   sinkModel(c.getDeclaringType().getPackage().toString(),
//     c.getDeclaringType().getSourceDeclaration().toString(), _, c.getName(), paramsString(c), _, _,
//     kind, _)
// * final draft 1
// from Callable c, string paramIdx, string kind
// where
//   // c.getDeclaringType().getSourceDeclaration().toString() = "Connection" and
//   // c.getName() = "prepareCall" and
//   kind in ["create-file"] and
//   sinkModel(c.getDeclaringType().getPackage().toString(),
//     c.getDeclaringType().getSourceDeclaration().toString(), _, c.getName(), _, _,
//     "Argument[" + paramIdx + "]", kind, _) // ! can't do `paramsString(c)` since may have "" signature
// // select c, c.getParameter(paramIdx.toInt()).getName(), paramsString(c)
// select c, c.getParameter(paramIdx.toInt()).getName(), paramsString(c)
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
  //kind in ["pending-intent-sent"] and
  kind.matches("sql") and
  sinkModel(callable.getDeclaringType().getPackage().toString(),
    callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
    [paramsString(callable), ""], _, paramLoc, kind, _) and
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
