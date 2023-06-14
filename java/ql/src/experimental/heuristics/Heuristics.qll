import java
private import semmle.code.java.dataflow.ExternalFlow
private import semmle.code.java.dataflow.internal.ModelExclusions

// TODO:
// todo: p.getName().matches("%internal%") // ! I think it would make sense to add this exclusion as an "isInternal" exclusion similar to "isJdkInternal" (e.g. org.hibernate.engine.jdbc.internal, etc.)
// todo: Note that some "com.sun..." ones might be of interest after all for SensitiveAPIs. -- collect Yorck's note on that...
// todo: %.test%" and "assert" in `isTestPackage`
private predicate sqlHeuristic(Parameter p) {
  //p.getName().matches(["sql%", "query%"]) and
  //p.getName().regexpMatch("(?i)(sql|query)?") and
  p.getName().regexpMatch("(?i)[a-z]*(sql|query)+[a-z]*") and // goes too far without a type constraint as well
  not p.hasName([
      "sqlType", "SQLType", "sqlState", "SQLState", "queryClass", "queryName", "targetSqlType",
      "targetSQLType"
    ]) and // these paramNames don't eem to ever be actual qsql queries, may need more exclusions
  not p.getType().getErasure().(RefType).hasQualifiedName("java.time.temporal", "TemporalQuery") and
  not p.getType() instanceof PrimitiveType and
  not p.getType() instanceof BoxedType and
  //p.getType() instanceof TypeString and // ! may need to add CriteriaDelete, CriteriaQuery, and CriteriaUpdate, Subquery?,as types as well (for org.hibernate sinks)
  not p.getCallable()
      .getDeclaringType()
      .getSourceDeclaration()
      .toString()
      .regexpMatch("(?i)[a-z]*(exception)+[a-z]*") // exclude Exceptions for now (ask Tony about this)
}

private predicate pathInjectionHeuristic(Parameter p) {
  // * less strict with names and types: (253 results)
  p.getName()
      .matches([
          "file", "fd", "fdObj", "out", "dir", "link", "path%", "fileName", "target", "sink",
          "destDir", "destFile", "destination", "destinationDir", "files", "outputStream",
          "targetDirectory", "targetFile"
        ]) and // ! leaving "name" and "prefix" out for now since they seem to result in a lot of FPs (102 "prefix" results, 455 "name" results)
  (
    p.getType() instanceof TypeFile or
    p.getType() instanceof TypePath or
    p.getType().(Class).hasQualifiedName("java.io", "FileDescriptor") or // ! need to add this as a type in JDK.qll
    p.getType() instanceof TypeString or
    p.getType().(Class).hasQualifiedName("java.io", "OutputStream") or // ! need to add this as a type in JDK.qll
    p.getType().(Array).getComponentType() instanceof TypeFile
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
  // p.getName().matches(["url"]) // version 0.0, overly simplistic
  //p.getName().regexpMatch("(?i)[a-z]*(url|uri)+[a-z]*") // version 1.0, ran on openjdk, apache httpcomponents-core/client version 5 and 4, returns a good number of TP results, but also some clear FPs.
  // * Notes for heuristic adjustment based on first round of triage of results
  // *    from running version 1.0 against apache/httpcomponents-core and apache/httpcomponents-client (version 5)
  // EXPAND:
  // * 0) Add param name of "host" in some form to the heuristic (also "HttpHost target"; maybe restrict to have class name with "host" in it so not too broad) (keep an eye on results since may be FP-prone and may need further restriction to method-name, etc.)
  // * 1) Maybe also add param name of "request" in some form with same caveats as above.
  // * 2) Maybe add types of Uri, Url, HttpHost, etc.?
  // OTHER:
  // * NOT EXCLUDING FROM HEURISTIC SINCE STILL WANT THESE RESULTS: "methodology" discussed with Tony regarding when something should be sink versus step:
  // *    (affects at least the following apis: Builder.setUri, HttpHost.create, RequestLine, URIBuilder) - leave out of heuristic for now
  // RESTRICT:
  // * DONE in 1.3: exclude "uriPattern" and "uriPatternType" as param name and/or "register" as a method name.
  // * DONE in 1.2: exclude when paramType is boolean (maybe exclude all primitives)
  // * DONE in 1.5: remove cache ones, prbly best to remove any method names with "cache" in them (only affects client ones). (Is CacheKeyGenerator.resolve a step though? and HttpCacheSupport.normalize%?)
  // * DONE in 1.1: require "uri" at beginning or end of param name to avoid when part of other words.
  // TODO: look into the following ones more: either TPs or exclude from heuristic: URLEncodedUtils.parse, SSLContextBuilder.loadKey/TrustMaterial
  // TODO: also look into PublicSuffixMatcherLoader.load a tiny bit more - this one seems harder to exclude from heuristic iin a general way, need to exclude type with "matcher" in name?
  //p.getName().regexpMatch("(?i)[a-z]*(url|^uri|uri$)+[a-z]*") // version 1.1: uri only at beginning or end of string (maybe extend to url as well eventually)
  //
  // p.getName().regexpMatch("(?i)[a-z]*(url|^uri|uri$)+[a-z]*") and // version 1.2: exclude when paramType is boolean (maybe exclude all primitives)
  // not p.getType() instanceof PrimitiveType
  //
  // p.getName().regexpMatch("(?i)[a-z]*(url|^uri|uri$)+[a-z]*") and // version 1.3: exclude "uriPattern" and "uriPatternType" as param name
  // not p.getType() instanceof PrimitiveType and
  // not p.getName().regexpMatch("(?i)[a-z]*(pattern)+[a-z]*")
  //
  // p.getName().regexpMatch("(?i)[a-z]*(url|^uri|uri$)+[a-z]*") and // version 1.4: exclude TestLibrary from ALL heuristics, and "assert" methods (1.4.1) (see below code)
  // not p.getType() instanceof PrimitiveType and
  // not p.getName().regexpMatch("(?i)[a-z]*(pattern)+[a-z]*")
  //
  // p.getName().regexpMatch("(?i)[a-z]*(url|^uri|uri$)+[a-z]*") and // version 1.5: remove cache ones (might be erring on side of FNs with this exclusion)
  // not p.getType() instanceof PrimitiveType and
  // not p.getName().regexpMatch("(?i)[a-z]*(pattern)+[a-z]*") and
  // not p.getCallable().getDeclaringType().getPackage().getName().matches("%cache%")
  //
  p.getName().regexpMatch("(?i)[a-z]*(host)+[a-z]*") and // version 1.6: add "%host|request%" as a possible param name
  not p.getType() instanceof PrimitiveType and
  not p.getName().regexpMatch("(?i)[a-z]*(pattern)+[a-z]*") and
  not p.getCallable().getDeclaringType().getPackage().getName().matches("%cache%")
  //
  // p.getName().regexpMatch("(?i)[a-z]*(host|request)+[a-z]*") // version 1.
  // or
  // p.getType().toString().regexpMatch("(?i)[a-z]*(host)+[a-z]*")
}

private class CryptoKeyType extends Type {
  CryptoKeyType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte"
  }
}

private class SecurityPackage extends Package {
  SecurityPackage() {
    this.getName().matches("java.security%") or
    this.getName().matches("javax.security%") or
    this.getName().matches("javax.crypto%") or
    this.getName().matches("sun.security%") or
    this.getName().matches("com.sun.crypto%")
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
// Needs exclusion/adjustment for ALL heuristics:
// 1) Check for subtyping in all the similar classes/methods, and see if can make heuristic smart enough to avoid if so.
// DONE with `not TestLibrary` addition: exclude "test" ones; check if can exclude TestUtils like ExternalApi, etc. ("assert" as method name as well if doesn't fully exlude it).
// DONE BenchmarkConfig$Builder etc. issue, handle in output below...
private Callable getAVulnerableParameterNameBasedGuess(int paramIdx, string sinkKind) {
  exists(Parameter p |
    p = result.getParameter(paramIdx) and
    //not isJdkInternal(result.getDeclaringType().getPackage()) and // exclude JDK internals for now
    //not p.getCallable().getDeclaringType() instanceof TestLibrary and // exclude testing packages
    not p.getCallable().getName().matches("assert%") and // exclude test assertion methods
    not p.getCallable().getName().matches("is%") and // exclude "is..." pattern that seems to usually be neutral
    // select heuristic to use based on sinkKind
    (
      sinkKind = "sql-injection" and // AI-related
      sqlHeuristic(p)
      or
      sinkKind = "request-forgery" and // AI-related
      ssrfHeuristic(p)
      or
      sinkKind = "path-injection" and // AI-related
      pathInjectionHeuristic(p)
      or
      sinkKind = "xpath-injection" and
      xPathInjectionHeuristic(p)
      or
      sinkKind = "credentials-password" and
      passwordHeuristic(p)
      or
      sinkKind = "credentials-username" and
      usernameHeuristic(p)
      or
      sinkKind = "credentials-cryptoKey" and // should maybe be "encryption-key" instead to match Swift (or should Swift switch to match this?)
      cryptoKeyHeuristic(p)
      or
      sinkKind = "regex" and // still a problem - should put on planning board at some point...
      regexInjectionHeuristic(p)
    )
  )
}

// below isn't really necessary, but keeping for now in case want to expand to use `reason`
private Callable getAVulnerableParameter(int paramIdx, string sinkKind, string reason) {
  result = getAVulnerableParameterNameBasedGuess(paramIdx, sinkKind) and
  reason = "nameBasedGuess"
}

// DONE - refactor all of below to use `getSourceDeclaration`?
// DONE - and to be able nestedTypes (e.g. `BenchmarkConfig$Builder`)?
bindingset[paramIdx]
private string hasExistingSink(Callable callable, int paramIdx) {
  if
    sinkModel(callable.getDeclaringType().getCompilationUnit().getPackage().getName(),
      callable.getDeclaringType().getSourceDeclaration().nestedName(), _, callable.getName(),
      [paramsString(callable), ""], _, "Argument[" + paramIdx + "]", _, _) // may want to allow for finding "generated" as well; also "Name" may be affected for existing queries?.
  then
    exists(string existingKind, string existingProv |
      existingKind =
        // `sinkModelKindResult` needs to be refactored; should be a simpler way to get this info, hopefully combined with the above
        // Also, should add check for ANY existing model for the API (e.g. summary, etc.), and make sure that subtyping is taken into account.
        sinkModelKindResult(callable.getDeclaringType().getCompilationUnit().getPackage().getName(),
          callable.getDeclaringType().getSourceDeclaration().nestedName(), _, callable.getName(),
          [paramsString(callable), ""], _, "Argument[" + paramIdx + "]", _, _) and
      existingProv =
        sinkModelProvenanceResult(callable
              .getDeclaringType()
              .getCompilationUnit()
              .getPackage()
              .getName(), callable.getDeclaringType().getSourceDeclaration().nestedName(), _,
          callable.getName(), [paramsString(callable), ""], _, "Argument[" + paramIdx + "]", _, _) and
      result =
        "yes, for sink kind \"" + existingKind + "\", with provenance=\"" + existingProv + "\""
    )
  else result = "no"
}

private string hasExistingSummary(Callable callable) {
  if
    summaryModel(callable.getDeclaringType().getCompilationUnit().getPackage().getName(),
      callable.getDeclaringType().getSourceDeclaration().nestedName(), _, callable.getName(), _, _,
      _, _, _, _)
  then result = "yes, existing summary model"
  else result = "no"
}

private string hasExistingSource(Callable callable) {
  if
    sourceModel(callable.getDeclaringType().getCompilationUnit().getPackage().getName(),
      callable.getDeclaringType().getSourceDeclaration().nestedName(), _, callable.getName(), _, _,
      _, _, _)
  then result = "yes, existing source model"
  else result = "no"
}

private string hasExistingNeutral(Callable callable) {
  if
    neutralModel(callable.getDeclaringType().getCompilationUnit().getPackage().getName(),
      callable.getDeclaringType().getSourceDeclaration().nestedName(), callable.getName(), _, _, _)
  then result = "yes, existing neutral model"
  else result = "no"
}

// DONE - not affected: not sure why I had changed the below PublicCallable to a Callable... need to retest all heuristics to see how this affects them...
// also should probably switch to DataFlowTargetApi or TargetApiSpecific anyways - wait until create new `Api` class for models that Michael suggested...
string getAVulnerableParameterSpecification(
  ModelApi modelApi, string existingSink, string existingSummary, string existingSource,
  string existingNeutral, string sinkKind, string paramType, string paramName
) {
  exists(int paramIdx |
    modelApi = getAVulnerableParameter(paramIdx, sinkKind, _) and
    result =
      "[\"" + modelApi.getDeclaringType().getCompilationUnit().getPackage().getName() + "\", \"" +
        modelApi.getDeclaringType().getSourceDeclaration().nestedName() + "\", " + "True, \"" +
        modelApi.getName() + "\", \"" + paramsString(modelApi) + "\", \"\", \"" + "Argument[" +
        paramIdx + "]\", \"" + sinkKind + "\", \"manual\"]" and
    existingSink = hasExistingSink(modelApi, paramIdx) and
    existingSummary = hasExistingSummary(modelApi) and
    existingSource = hasExistingSource(modelApi) and
    existingNeutral = hasExistingNeutral(modelApi) and
    paramType = modelApi.getParameterType(paramIdx).getErasure().toString() and // debugging
    paramName = modelApi.getParameter(paramIdx).getName() // debugging
  )
}
