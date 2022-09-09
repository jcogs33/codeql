/** Provides classes and predicates to reason about deep links in Android. */

import java
private import semmle.code.java.frameworks.android.Intent
private import semmle.code.java.frameworks.android.Android
private import semmle.code.java.dataflow.DataFlow
//private import semmle.code.java.dataflow.DataFlow2
private import semmle.code.java.dataflow.FlowSteps
private import semmle.code.xml.AndroidManifest

// ! Remember to add 'private' annotation as needed to all new classes/predicates below.
// ! and clean-up comments, etc. in below in general...
// * separate source, sink, etc.
/** An Intent arg of a startActivity MethodAccess. */
class DeepLinkSource extends DataFlow::Node {
  DeepLinkSource() {
    exists(MethodAccess startActivity, ClassInstanceExpr newIntent |
      (
        startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) or
        startActivity.getMethod().overrides*(any(ActivityStartActivityMethod m))
      ) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and //or
      // exists(StartComponentConfiguration cfg |
      //   cfg.hasFlow(DataFlow::exprNode(newIntent),
      //     DataFlow::exprNode(startActivity.getArgument(0)))
      // )
      this.asExpr() = startActivity.getArgument(0)
    )
  }
}

class DeepLinkSink extends DataFlow::Node {
  DeepLinkSink() {
    exists(MethodAccess getIntent, ClassInstanceExpr newIntent |
      getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        getIntent.getReceiverType() and
      this.asExpr() = getIntent
    )
  }
}

// * Global Flow from NewIntent to StartComponent Argument
// ! below works as intended when run by itself (see latest query in AndroidDeeplinks_RemoteSources.ql),
// ! but not when combined with existing flow steps (non-monotonic recursion)
// ! need to figure out how to combine, or wrap all in global flow?
class StartComponentConfiguration extends DataFlow::Configuration {
  StartComponentConfiguration() { this = "StartComponentConfiguration" }

  // Override `isSource` and `isSink`.
  override predicate isSource(DataFlow::Node source) {
    exists(ClassInstanceExpr classInstanceExpr |
      classInstanceExpr.getConstructedType() instanceof TypeIntent and
      source.asExpr() = classInstanceExpr
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess startActivity |
      // ! need to handle for all components, not just Activity
      (
        startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) or
        startActivity.getMethod().overrides*(any(ActivityStartActivityMethod m))
      ) and
      sink.asExpr() = startActivity.getArgument(0)
    )
  }
  // Optionally override `isBarrier`.
  // Optionally override `isAdditionalFlowStep`.
  //   Then, to query whether there is flow between some `source` and `sink`,
  //  write
  //
  //  ```ql
  //  exists(MyAnalysisConfiguration cfg | cfg.hasFlow(source, sink))
  //  ```
}
