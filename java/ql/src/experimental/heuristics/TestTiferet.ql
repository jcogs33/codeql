import java
import semmle.code.java.dataflow.ExternalFlow
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSummary
import semmle.code.java.dataflow.internal.DataFlowPrivate
import utils.modelgenerator.internal.CaptureModels
import semmle.code.java.dataflow.internal.FlowSummaryImpl as FlowSummaryImpl
private import utils.modelgenerator.internal.CaptureModelsSpecific as CMS

string getApiName(Callable c) {
  result =
    c.getDeclaringType().getPackage() + "." + c.getDeclaringType().getSourceDeclaration() + "#" +
      c.getName() + paramsString(c)
}

// predicate getAllDataFlowNodesModeledAsMaDSteps() {
// }
// * write a predicate that detects all dataflow nodes that are modeled as MaD taint steps.
// from Callable callable, string paramsString, string apiName
// where
//   paramsString = paramsString(callable) and
//   //paramLoc = "Argument[" + paramIdx + "]" and
//   //paramType = callable.getParameterType(paramIdx.toInt()).getErasure().toString() and
//   //paramName = callable.getParameter(paramIdx.toInt()).getName() and
//   summaryModel(callable.getDeclaringType().getPackage().toString(),
//     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//     [paramsString(callable), ""], _, _, _, _, _) and
//   sinkModel(callable.getDeclaringType().getPackage().toString(),
//     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//     [paramsString(callable), ""], _, _, _, _) and
//   apiName = getApiName(callable)
// select apiName, callable order by apiName
// * write a predicate that detects all dataflow nodes that are modeled as MaD taint steps.
// from DataFlow::Node n, Callable callable, string paramsString, string apiName
// where
//   callable.getAParameter() = n.asParameter() and
//   paramsString = paramsString(callable) and
//   //paramLoc = "Argument[" + paramIdx + "]" and
//   //paramType = callable.getParameterType(paramIdx.toInt()).getErasure().toString() and
//   //paramName = callable.getParameter(paramIdx.toInt()).getName() and
//   summaryModel(callable.getDeclaringType().getPackage().toString(),
//     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//     [paramsString(callable), ""], _, _, _, _, _) and
//   sinkModel(callable.getDeclaringType().getPackage().toString(),
//     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//     [paramsString(callable), ""], _, _, _, _) and
//   apiName = getApiName(callable)
// select apiName, callable, n order by apiName
// * make similar to metrics/top apis queries
// /** Gets a node that is an input to a call to this API. */
// predicate appliesToEndpoint(DataFlow::Node n) {
//   FlowSummaryImpl::Private::Steps::summaryThroughStepValue(n, _, _) or
//   FlowSummaryImpl::Private::Steps::summaryThroughStepTaint(n, _, _) or
//   FlowSummaryImpl::Private::Steps::summaryGetterStep(n, _, _, _) or
//   FlowSummaryImpl::Private::Steps::summarySetterStep(n, _, _, _)
// }
// private DataFlow::Node getAnInput(Callable c) {
//   exists(Call call | call.getCallee().getSourceDeclaration() = c |
//     result.asExpr().(Argument).getCall() = call or
//     result.(ArgumentNode).getCall().asCall() = call
//   )
// }
// predicate getAllDataFlowNodesModeledAsMaDSteps(DataFlow::Node n, Callable callable) {
//   exists(Call c, int paramIdx |
//     c.getCallee() = callable and
//     n.asExpr() = c.getArgument(paramIdx) and
//     summaryModel(c.getCallee().getDeclaringType().getPackage().toString(),
//       c.getCallee().getDeclaringType().getSourceDeclaration().toString(), _,
//       c.getCallee().getName(), [paramsString(c.getCallee()), ""], _, "Argument[" + paramIdx + "]",
//       _, _, _) and
//     not sinkNode(n, _)
//   )
// }
// // from string apiName, Callable c
// // where
// //   c = any(SummarizedCallable sc).asCallable() and
// //   //c instanceof DataFlowTargetApi and
// //   apiName = getApiName(c) //and
// // //not sinkNode(getAnInput(c), _)
// // select apiName, c order by apiName
// // from string apiName, Callable callable
// // where
// //   summaryModel(callable.getDeclaringType().getPackage().toString(),
// //     callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
// //     [paramsString(callable), ""], _, _, _, _, _) and
// //   apiName = getApiName(callable)
// // //not sinkNode(getAnInput(c), _)
// // select apiName, callable order by apiName
// from DataFlow::Node n, Callable c, string apiName //, int paramIdx
// where
//   //c.getDeclaringType().getPackage().toString() = "java.io" and
//   //c.getDeclaringType().getSourceDeclaration().toString() = "File" and
//   getAllDataFlowNodesModeledAsMaDSteps(n, c) and
//   apiName = getApiName(c)
// select apiName, c, n order by apiName
// //select n
// * FINAL for question
// predicate allDataFlowNodesModeledAsMadSteps(DataFlow::Node node, Callable callable, Call cll) {
//   exists(Call call, int paramIdx, string input |
//     call = cll and
//     //call.getCaller() = callable and
//     call.getCallee() = callable and
//     input.matches("%" + paramIdx + "%") and
//     (
//       node.asExpr() = call.getArgument(paramIdx)
//       or
//       node.asExpr() = call.getQualifier() and paramIdx = -1
//     ) and
//     summaryModel(callable.getDeclaringType().getPackage().toString(),
//       callable.getDeclaringType().getSourceDeclaration().toString(), _, callable.getName(),
//       [paramsString(callable), ""], _, input, _, _, _) and
//     not sinkNode(node, _)
//   )
// }
// from DataFlow::Node n, Callable c, Call call, string apiName
// where
//   c.getDeclaringType().getPackage().toString() = "java.lang" and
//   c.getDeclaringType().getSourceDeclaration().toString() = "String" and
//   c.getName() = "replace" and
//   allDataFlowNodesModeledAsMadSteps(n, c, call) and
//   apiName = getApiName(c)
// //select apiName, c, n order by apiName
// select apiName, c, call.getCallee(), call.getCaller() order by apiName
// from Callable c, string apiName
// where
//   c.getDeclaringType().getPackage().toString() = "java.util" and
//   c.getDeclaringType().getSourceDeclaration().toString() = "Map" and
//   c.getName() = "forEach" and
//   apiName = getApiName(c)
// select apiName, c order by apiName
// * testing:
// from Call call
// where
//   call.getCallee().getDeclaringType().getPackage().toString() = "java.lang" and
//   call.getCallee().getName() = "getResourceAsStream"
// select call.getCallee().getDeclaringType().getSourceDeclaration(),
//   call.getCallee().getDeclaringType().getName(), call.getCallee().getDeclaringType().nestedName(),
//   call.getCallee().getDeclaringType().getSourceDeclaration().nestedName() //, CMS::asPartialModel(call.getCallee())
/*
 *  c.getDeclaringType().getPackage()
 *  vs c.getDeclaringType().getPackage().getName()
 *  vs c.getDeclaringType().getCompilationUnit().getPackage().getName()
 */

from Call call
where call.getCallee().getDeclaringType().getSourceDeclaration().nestedName() = "Map$Entry"
//call.getCallee().getDeclaringType().getPackage().toString() = "java.lang" and
//call.getCallee().getName() = "getResourceAsStream"
select call.getCallee(),
  call.getCallee().getDeclaringType(), //, call.getCallee().getDeclaringType().getPackage() //,
  // call.getCallee().getDeclaringType().getPackage().getName()
  call.getCallee().getDeclaringType().getCompilationUnit().getPackage().getName()
//callable.getDeclaringType().getCompilationUnit().getPackage()
