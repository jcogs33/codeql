import java
import semmle.code.java.security.QueryInjection
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.ExternalFlow
import semmle.code.java.dataflow.internal.DataFlowPrivate

class PublicCallable extends Callable {
  PublicCallable() { this.isPublic() and this.getDeclaringType().isPublic() }
}

class PublicArgumentToSqlInjectionSinkConfiguration extends DataFlow::Configuration {
  PublicArgumentToSqlInjectionSinkConfiguration() {
    this = "PublicArgumentToSqlInjectionSinkConfiguration"
  }

  override predicate isSource(DataFlow::Node node) {
    node.asParameter() = any(PublicCallable c).getAParameter() and
    node.getType() instanceof TypeString
  }

  override predicate isSink(DataFlow::Node node) { node instanceof SqlInjectionSink }
}

class PublicArgumentToSqlInjectionSinkTaintConfiguration extends TaintTracking::Configuration {
  PublicArgumentToSqlInjectionSinkTaintConfiguration() {
    this = "PublicArgumentToSqlInjectionSinkTaintConfiguration"
  }

  override predicate isSource(DataFlow::Node node) {
    node.asParameter() = any(PublicCallable c).getAParameter() and
    node.getType() instanceof TypeString
  }

  override predicate isSink(DataFlow::Node node) { node instanceof SqlInjectionSink }
}

DataFlowCallable getASqlInjectionVulnerableParameterValueFlow(int paramIdx) {
  exists(PublicArgumentToSqlInjectionSinkConfiguration config, DataFlow::ParameterNode source |
    config.hasFlow(source, _) and
    source.isParameterOf(result, paramIdx)
  )
}

DataFlowCallable getASqlInjectionVulnerableParameterTaintFlow(int paramIdx) {
  exists(PublicArgumentToSqlInjectionSinkTaintConfiguration config, DataFlow::ParameterNode source |
    config.hasFlow(source, _) and
    source.isParameterOf(result, paramIdx)
  )
}

DataFlowCallable getASqlInjectionVulnerableParameterNameBasedGuess(int paramIdx) {
  exists(Parameter p |
    p.getName() = "sql" and
    p = result.asCallable().getParameter(paramIdx)
  )
}

query DataFlowCallable getASqlInjectionVulnerableParameter(int paramIdx, string reason) {
  result = getASqlInjectionVulnerableParameterValueFlow(paramIdx) and
  reason = "valueFlowToKnownSink"
  or
  result = getASqlInjectionVulnerableParameterTaintFlow(paramIdx) and
  not result = getASqlInjectionVulnerableParameterValueFlow(paramIdx) and
  reason = "taintFlowToKnownSink"
  or
  result = getASqlInjectionVulnerableParameterNameBasedGuess(paramIdx) and
  not result = getASqlInjectionVulnerableParameterValueFlow(paramIdx) and
  not result = getASqlInjectionVulnerableParameterTaintFlow(paramIdx) and
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

query string getASqlInjectionVulnerableParameterSpecification() {
  exists(DataFlowCallable c, int paramIdx |
    c = getASqlInjectionVulnerableParameter(paramIdx, _) and
    result =
      c.asCallable().getDeclaringType().getPackage() + ";" +
        c.asCallable().getDeclaringType().getName() + ";" + "false;" + c.asCallable().getName() +
        ";" + signatureIfNeeded(c.asCallable()) + ";;" + "Argument[" + paramIdx + "];" + "sql"
  )
}
