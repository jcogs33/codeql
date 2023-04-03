import java
private import semmle.code.java.dataflow.FlowSummary
private import semmle.code.java.dataflow.internal.FlowSummaryImpl as FlowSummaryImpl
private import semmle.code.java.dataflow.ExternalFlow

/** Holds if `c` has the MaD-formatted name `apiName`. */
predicate hasApiName(Callable c, string apiName) {
  apiName =
    c.getDeclaringType().getPackage() + "." + c.getDeclaringType().getSourceDeclaration() + "#" +
      c.getName() + paramsString(c)
}

/** Holds if this API has a manual summary model. */
private predicate hasManualSummary(SummarizedCallableBase c) {
  c.(SummarizedCallable).hasProvenance(false)
}

/** Holds if this API has a manual neutral model. */
private predicate hasManualNeutral(SummarizedCallableBase c) {
  c.(FlowSummaryImpl::Public::NeutralCallable).hasProvenance(false)
}

/** Holds if this API has a manual MaD model. */
predicate hasManualMadModel(SummarizedCallableBase c) { hasManualSummary(c) or hasManualNeutral(c) }

from string apiName, string message
where
  apiName in ["java.util.List#add(Object)", "java.util.Collection#add(Object)"] and
  (
    // top jdk api names for which there is no callable
    not hasApiName(_, apiName) and
    message = "no callable"
    or
    // top jdk api names for which there isn't a manual model
    exists(SummarizedCallableBase scb |
      not hasManualMadModel(scb) and
      hasApiName(scb.asCallable(), apiName) and
      message = "no manual model" //and
      //   if exists(ClassOrInterface ci | ci = scb.asCallable().getDeclaringType().getAStrictAncestor())
      //   then supertype = scb.asCallable().getDeclaringType().getAStrictAncestor().toString()
      //   else supertype = "false"
    )
  )
select apiName, message order by apiName
