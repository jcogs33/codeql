import java
import semmle.code.java.security.QueryInjection
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.ExternalFlow
import semmle.code.java.dataflow.internal.DataFlowPrivate

// Chris' code with dataflow
// class PublicCallable extends Callable {
//   PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
// }
// class PublicArgumentToRegexInjectionSinkConfiguration extends DataFlow::Configuration {
//   PublicArgumentToRegexInjectionSinkConfiguration() {
//     this = "PublicArgumentToRegexInjectionSinkConfiguration"
//   }
//   override predicate isSource(DataFlow::Node node) {
//     node.asParameter() = any(PublicCallable c).getAParameter() and
//     node.getType() instanceof TypeString
//   }
//   override predicate isSink(DataFlow::Node node) { node instanceof RegexInjectionSink }
// }
// class PublicArgumentToRegexInjectionSinkTaintConfiguration extends TaintTracking::Configuration {
//   PublicArgumentToRegexInjectionSinkTaintConfiguration() {
//     this = "PublicArgumentToRegexInjectionSinkTaintConfiguration"
//   }
//   override predicate isSource(DataFlow::Node node) {
//     node.asParameter() = any(PublicCallable c).getAParameter() and
//     node.getType() instanceof TypeString
//   }
//   override predicate isSink(DataFlow::Node node) { node instanceof RegexInjectionSink }
// }
// DataFlowCallable getARegexInjectionVulnerableParameterValueFlow(int paramIdx) {
//   exists(PublicArgumentToRegexInjectionSinkConfiguration config, DataFlow::ParameterNode source |
//     config.hasFlow(source, _) and
//     source.isParameterOf(result, paramIdx)
//   )
// }
// DataFlowCallable getARegexInjectionVulnerableParameterTaintFlow(int paramIdx) {
//   exists(PublicArgumentToRegexInjectionSinkTaintConfiguration config, DataFlow::ParameterNode source |
//     config.hasFlow(source, _) and
//     source.isParameterOf(result, paramIdx)
//   )
// }
// DataFlowCallable getARegexInjectionVulnerableParameterNameBasedGuess(int paramIdx) {
//   exists(Parameter p |
//     p.getName() = "regex" and
//     p = result.asCallable().getParameter(paramIdx)
//   )
// }
// query DataFlowCallable getARegexInjectionVulnerableParameter(int paramIdx, string reason) {
//   result = getARegexInjectionVulnerableParameterValueFlow(paramIdx) and
//   reason = "valueFlowToKnownSink"
//   or
//   result = getARegexInjectionVulnerableParameterTaintFlow(paramIdx) and
//   not result = getARegexInjectionVulnerableParameterValueFlow(paramIdx) and
//   reason = "taintFlowToKnownSink"
//   or
//   result = getARegexInjectionVulnerableParameterNameBasedGuess(paramIdx) and
//   not result = getARegexInjectionVulnerableParameterValueFlow(paramIdx) and
//   not result = getARegexInjectionVulnerableParameterTaintFlow(paramIdx) and
//   reason = "nameBasedGuess"
// }
// predicate hasOverloads(PublicCallable c) {
//   exists(PublicCallable other |
//     other.getDeclaringType() = c.getDeclaringType() and
//     other.getName() = c.getName() and
//     other != c
//   )
// }
// string signatureIfNeeded(PublicCallable c) {
//   if hasOverloads(c) then result = paramsString(c) else result = ""
// }
// query string getARegexInjectionVulnerableParameterSpecification() {
//   exists(DataFlowCallable c, int paramIdx |
//     c = getARegexInjectionVulnerableParameter(paramIdx, _) and
//     result =
//       c.asCallable().getDeclaringType().getPackage() + ";" +
//         c.asCallable().getDeclaringType().getName() + ";" + "false;" + c.asCallable().getName() +
//         ";" + signatureIfNeeded(c.asCallable()) + ";;" + "Argument[" + paramIdx + "];" + "regex-injection"
//   )
// }
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
