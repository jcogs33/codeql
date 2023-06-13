import java
import semmle.code.java.dataflow.ExternalFlow

// my attempt without dataflow (to see if it's even necessary: most results can be found without dataflow it seems)
class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

Callable getARegexInjectionVulnerableParameterNameBasedGuess(int paramIdx) {
  exists(Parameter p |
    p.getName() = "regex" and
    p = result.getParameter(paramIdx)
  )
}

query Callable getARegexInjectionVulnerableParameter(int paramIdx, string reason) {
  result = getARegexInjectionVulnerableParameterNameBasedGuess(paramIdx) and
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

query string getARegexInjectionVulnerableParameterSpecification() {
  exists(Callable c, int paramIdx |
    c = getARegexInjectionVulnerableParameter(paramIdx, _) and
    result =
      c.getDeclaringType().getPackage() + ";" + c.getDeclaringType().getName() + ";" + "false;" +
        c.getName() + ";" + signatureIfNeeded(c) + ";;" + "Argument[" + paramIdx + "];" +
        "regex-injection"
  )
}
// ! Notes:
// TODO: remove internal ones? e.g. `com.sun.org.apache.xerces.internal.impl.xpath.regex`
// TODO: look into `javax.net.ssl;SNIHostName;false;createSNIMatcher;;;Argument[0];regex-injection` is this a TP?, does it increase results of regex-injection query? does it cover any CVEs? or find any *new* issues?, check how widely used createSNIMatcher is with GitHub search and testing query, doesn't seem super popular or used in exploitable way based on google search results...
// TODO: also `javax.swing;RowFilter;false;regexFilter;;;Argument[0];regex-injection`
// TODO: also `java.util.regex;PatternSyntaxException;false;PatternSyntaxException;;;Argument[1];regex-injection` - FP?
// from MethodAccess ma
// where ma.getMethod().hasName("createSNIMatcher")
// select ma
