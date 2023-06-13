import java
private import semmle.code.java.dataflow.ExternalFlow

private class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

// pulled from CaptureModelsSpecific.qll
// ! shouldn't PublicCallable handle these already?, are the "com.sun..." ones that I'm seeing actualy of interest after all?
private predicate isJdkInternal(Package p) {
  p.getName().matches("org.graalvm%") or
  p.getName().matches("com.sun%") or
  //p.getName().matches("javax.swing%") or // remooving GUI packages for now
  //p.getName().matches("java.awt%") or
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

private Callable getAVulnerableParameterNameBasedGuess(int paramIdx, string sinkKind) {
  /*, string paramName, string paramType*/
  exists(Parameter p |
    // sql heuristic (move this to other predicate)
    sinkKind = "sql" and
    p.getName().matches(["sql%", "query%"]) and
    p.getType() instanceof TypeString and // add parameter type to the heuristic
    p = result.getParameter(paramIdx) and
    not isJdkInternal(result.getDeclaringType().getPackage()) // exclude JDK internals for now
    // OR other heuristics below (move these to other predicates)
  )
}

// below isn't really necessary, but keeping for now in case want to expand to use `reason`
private query Callable getAVulnerableParameter(
  int paramIdx, string sinkKind, /*string paramName, string paramType,*/ string reason
) {
  result = getAVulnerableParameterNameBasedGuess(paramIdx, sinkKind) and
  /*, paramName, paramType*/ reason = "nameBasedGuess"
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

bindingset[paramIdx]
private string hasExistingSink(Callable callable, int paramIdx) {
  if
    sinkModel(callable.getDeclaringType().getPackage().toString(),
      callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
      [paramsString(callable), ""], _, "Argument[" + paramIdx + "]", _, "manual") // ! may want to allow for finding "generated" as well; also "Name" may be affected for existing queries?.
  then
    exists(string existingKind |
      existingKind =
        // ! `sinkModelKindResult` needs to be refactored; should be a simpler way to get this info, hopefully combined with the above
        sinkModelKindResult(callable.getDeclaringType().getPackage().toString(),
          callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
          [paramsString(callable), ""], _, "Argument[" + paramIdx + "]", _, "manual") and
      result = "yes, for sink kind \"" + existingKind + "\""
    )
  else result = "no"
}

bindingset[sinkKind]
string getAVulnerableParameterSpecification(
  Callable c, /*string paramName, string paramType,*/ string existingSink, string sinkKind
) {
  exists(int paramIdx |
    c = getAVulnerableParameter(paramIdx, sinkKind, /*paramName, paramType,*/ _) and
    // yml-formatted result
    result =
      "[\"" + c.getDeclaringType().getPackage() + "\", \"" + c.getDeclaringType().getName() + "\", "
        + "True, \"" + c.getName() + "\", \"" + signatureIfNeeded(c) + "\", \"\", \"" + "Argument[" +
        paramIdx + "]\", \"" + sinkKind + "\", \"manual\"]" and
    existingSink = hasExistingSink(c, paramIdx)
  )
}
