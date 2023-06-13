import java
import semmle.code.java.dataflow.ExternalFlow

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
