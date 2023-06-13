import java
private import semmle.code.java.dataflow.ExternalFlow

private class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

// pulled from CaptureModelsSpecific.qll
// ! should PublicCallable handle these already?, are the "com.sun..." ones that I'm seeing actually of interest after all?
private predicate isJdkInternal(Package p) {
  p.getName().matches("org.graalvm%") or
  p.getName().matches("com.sun%") or
  p.getName().matches("javax.swing%") or // remove GUI packages from this list?
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
  p.getName() = "" or
  p.getName().matches("%internal%") // ! I think it would make sense to add this exclusion (e.g. org.hibernate.engine.jdbc.internal, etc.)
}

private predicate sqlHeuristic(Parameter p) {
  //p.getName().matches(["sql%", "query%"]) and
  p.getName().regexpMatch("(?i)[a-z]*(sql|query)+[a-z]*") and // ! goes too far without a type constraint as well
  //p.getName().regexpMatch("(?i)(sql|query)?") and
  not p.getName().matches(["sqlType", "sqlState", "SQLState", "queryClass"]) and
  p.getType() instanceof TypeString and // ! may need to add CriteriaDelete, CriteriaQuery, and CriteriaUpdate, Subquery?,as types as well (for org.hibernate sinks)
  not p.getCallable()
      .getDeclaringType()
      .getSourceDeclaration()
      .toString()
      .regexpMatch("(?i)[a-z]*(exception)+[a-z]*") // exclude Exceptions for now
}

private predicate pathInjectionHeuristic(Parameter p) {
  // * less strict with names and types: (253 results)
  p.getName()
      .matches(["file", "fd", "fdObj", "out", "dir", "link", "path", "fileName", "target", "sink"]) and // ! left out "name" and "prefix" for now.
  (
    p.getType() instanceof TypeFile or
    p.getType() instanceof TypePath or
    p.getType().(Class).hasQualifiedName("java.io", "FileDescriptor") or // ! need to add this as a type in JDK.qll
    p.getType() instanceof TypeString or
    p.getType().(Class).hasQualifiedName("java.io", "OutputStream") // ! need to add this as a type in JDK.qll
  )
  // * pair names and types more strictly: (205 results)
  // * the below probly excludes too much, e.g. ["java.nio.channels", "AsynchronousFileChannel", True, "open", "(Path,OpenOption[])", "", "Argument[0]", "create-file", "manual"] looks like a TP but excluded because paramType=Path and paramName=file
  // * start with the 253 above, then maybe restrict more to something in-between the above and below
  // p.getName()
  //     .matches(["file", "fd", "fdObj", "out", "dir", "link", "path", "fileName", "target", "sink"]) and // ! left out "name" and "prefix" for now; this will prbably be FP-prone as-is.
  // (
  //   p.getType() instanceof TypeFile and p.getName() = "file"
  //   or
  //   p.getType().(Class).hasQualifiedName("java.io", "FileDescriptor") and
  //   p.getName() = ["fd", "fdObj"] // ! need to add this as a type in JDK.qll
  //   or
  //   p.getType().(Class).hasQualifiedName("java.io", "OutputStream") and
  //   p.getName() = ["out", "sink"] // ! need to add this as a type in JDK.qll
  //   or
  //   p.getType() instanceof TypePath and
  //   p.getName() = ["dir", "link", "path", "target"]
  //   or
  //   p.getType() instanceof TypeString and p.getName() = ["fileName", "name", "prefix"]
  // )
}

private predicate xPathInjectionHeuristic(Parameter p) {
  p.getName().matches(["expression"]) // ! refine
  // ! possibly add p.getType(), etc. to heuristic
}

private predicate regexInjectionHeuristic(Parameter p) {
  p.getName().matches(["regex"])
  // ! possibly add p.getType(), etc. to heuristic
}

private predicate ssrfHeuristic(Parameter p) {
  p.getName().matches(["url"]) // ! add "uri", etc.?
  // ! possibly add p.getType(), etc. to heuristic
}

private class CryptoKeyType extends Type {
  CryptoKeyType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte"
  }
}

private class SecurityPackage extends Package {
  SecurityPackage() {
    getName().matches("java.security%") or
    getName().matches("javax.security%") or
    getName().matches("javax.crypto%") or
    getName().matches("sun.security%") or
    getName().matches("com.sun.crypto%")
  }
}

private predicate cryptoKeyHeuristic(Parameter p) {
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName()
      .regexpMatch("(?i)(raw|secret|session|wrapped|protected|other|encoded|base)?key(bytes|value|pass)?") and
  p.getType() instanceof CryptoKeyType and
  p.getCallable().getDeclaringType().getPackage() instanceof SecurityPackage
}

private class PasswordType extends Type {
  PasswordType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte" or
    this instanceof TypeString
  }
}

private predicate passwordHeuristic(Parameter p) {
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName().regexpMatch("(?i)(encrypted|old|new)?pass(wd|word|code|phrase)(chars|value)?") and
  p.getType() instanceof PasswordType
}

private class UsernameType extends Type {
  UsernameType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte" or
    this instanceof TypeString
  }
}

private predicate usernameHeuristic(Parameter p) {
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName().regexpMatch("(?i)(user|username)") and
  p.getType() instanceof UsernameType
}

// should rename this and other predicates
private Callable getAVulnerableParameterNameBasedGuess(int paramIdx, string sinkKind) {
  exists(Parameter p |
    not isJdkInternal(result.getDeclaringType().getPackage()) and // exclude JDK internals for now
    p = result.getParameter(paramIdx) and
    // select heuristic to use based on sinkKind
    (
      sinkKind = "sql" and
      sqlHeuristic(p)
      or
      sinkKind = "create-file" and
      pathInjectionHeuristic(p)
      or
      sinkKind = "xpath" and
      xPathInjectionHeuristic(p)
      or
      sinkKind = "%-url" and // ! need to look at package-name, etc. to determine if jdbc-url versus others
      ssrfHeuristic(p)
      or
      sinkKind = "regex" and
      regexInjectionHeuristic(p)
      or
      sinkKind = "cryptoKey" and
      cryptoKeyHeuristic(p)
      or
      sinkKind = "password" and
      passwordHeuristic(p)
      or
      sinkKind = "username" and
      usernameHeuristic(p)
    )
  )
}

// below isn't really necessary, but keeping for now in case want to expand to use `reason`
private Callable getAVulnerableParameter(int paramIdx, string sinkKind, string reason) {
  result = getAVulnerableParameterNameBasedGuess(paramIdx, sinkKind) and
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

string getAVulnerableParameterSpecification(Callable c, string existingSink, string sinkKind) {
  exists(int paramIdx |
    c = getAVulnerableParameter(paramIdx, sinkKind, _) and
    result =
      "[\"" + c.getDeclaringType().getPackage() + "\", \"" + c.getDeclaringType().getName() + "\", "
        + "True, \"" + c.getName() + "\", \"" + signatureIfNeeded(c) + "\", \"\", \"" + "Argument[" +
        paramIdx + "]\", \"" + sinkKind + "\", \"manual\"]" and
    existingSink = hasExistingSink(c, paramIdx)
  )
}
