import java
private import semmle.code.java.dataflow.ExternalFlow

private class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

// ! need to be able to refine this *for each* sink type.
private Callable getAVulnerableParameterNameBasedGuess(int paramIdx, string paramName) {
  exists(Parameter p |
    p.getName() = paramName and
    p = result.getParameter(paramIdx)
  )
}

// ! maybe expand this for refining?
private query Callable getAVulnerableParameter(int paramIdx, string paramName, string reason) {
  result = getAVulnerableParameterNameBasedGuess(paramIdx, paramName) and
  reason = "nameBasedGuess"
}

private predicate hasOverloads(PublicCallable c) {
  exists(PublicCallable other |
    other.getDeclaringType() = c.getDeclaringType() and
    other.getName() = c.getName() and
    other != c
  )
}

private string signatureIfNeeded(PublicCallable c) {
  if hasOverloads(c) then result = paramsString(c) else result = ""
}

// ! pulled from CaptureModelsSpecific.qll
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

query string getAVulnerableParameterSpecification() {
  exists(Callable c, int paramIdx |
    c = getAVulnerableParameter(paramIdx, "sql", _) and
    result =
      "[\"" + c.getDeclaringType().getPackage() + "\", \"" + c.getDeclaringType().getName() + "\", "
        + "True, \"" + c.getName() + "\", \"" + signatureIfNeeded(c) + "\", \"\", \"" + "Argument[" +
        paramIdx + "]\", \"" + "sql" + "\", \"manual\"]" and
    not isJdkInternal(c.getDeclaringType().getPackage())
  )
}
// TODO:
// 1) label existing sinks in heuristic output so can focus on just new ones (make easy to exclude from output instead as well) // ! complicated for ones that aren't as simple as "sql" (e.g. regex% and jdbc/open-url)
// DONE 2) Include callable in output so can easily view the source code for the API and have a MaDMan-esque experience.
// DONE 3) Make models YML-formatted so can copy-paste what you need more easily.
// 4) (Add more accurate True/False subtype label?)
// 5) (Can *maybe* make a Python script that inserts models into proper place in yml files after collecting a bunch instead of copy-pasting individually)
// 6) After major refactor, make each query more precise if necessary (more complicated heuristics, etc.)
//    a) need to make sure easy to make more precise *for each* query after refactor
//    b) and test more strategically on different frameworks. In approximate order of: path-inj, xpath-inj, sql-inj, ssrf, sensitive apis, regex inj.
