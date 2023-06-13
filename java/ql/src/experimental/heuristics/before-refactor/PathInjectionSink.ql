import java
import semmle.code.java.dataflow.ExternalFlow

// my attempt without dataflow (to see if it's even necessary: most results can be found without dataflow it seems)
class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

Callable getAPathInjectionVulnerableParameterNameBasedGuess(int paramIdx) {
  exists(Parameter p |
    p.getName() in ["file", "fd", "fdObj", "out", "dir", "link", "path", "fileName"] and // ! left out "sink", "name", "target", and "prefix" for now; this will prbably be FP-prone as-is.
    p = result.getParameter(paramIdx)
  )
}

query Callable getAPathInjectionVulnerableParameter(int paramIdx, string reason) {
  result = getAPathInjectionVulnerableParameterNameBasedGuess(paramIdx) and
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

query string getAPathInjectionVulnerableParameterSpecification() {
  exists(Callable c, int paramIdx |
    c = getAPathInjectionVulnerableParameter(paramIdx, _) and
    result =
      c.getDeclaringType().getPackage() + ";" + c.getDeclaringType().getName() + ";" + "false;" +
        c.getName() + ";" + signatureIfNeeded(c) + ";;" + "Argument[" + paramIdx + "];" +
        "create-file" and
    not isJdkInternal(c.getDeclaringType().getPackage())
  )
}

// ! Notes:
// TODO:
from Callable c
where
  c.getDeclaringType().getPackage().toString() = "java.nio.file" and
  c.getDeclaringType().getName() = "Files" and
  c.getName() = "createTempDirectory"
select c.getDeclaringType().getPackage(), c.getDeclaringType().getName(), c.getName(),
  c.getDeclaringType().getSourceDeclaration(), c.getDeclaringType()
