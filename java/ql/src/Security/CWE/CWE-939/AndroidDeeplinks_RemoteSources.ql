/**
 * @name Android deep links
 * @description Android deep links
 * @problem.severity recommendation
 * @security-severity 0.1
 * @id java/android/deeplinks
 * @tags security
 *       external/cwe/cwe-939
 * @precision high
 */

// * experiment with StartActivityIntentStep
// import java
// import semmle.code.java.frameworks.android.DeepLink
// import semmle.code.java.dataflow.DataFlow
// from StartServiceIntentStep startServiceIntStep, DataFlow::Node n1, DataFlow::Node n2
// where startServiceIntStep.step(n1, n2)
// select n2, "placeholder"
// * experiment with taint-tracking
// import java
// import semmle.code.java.dataflow.TaintTracking
// import semmle.code.java.frameworks.android.DeepLink
// import semmle.code.java.frameworks.android.Intent
// import semmle.code.java.frameworks.android.Android
// import semmle.code.java.dataflow.DataFlow
// import semmle.code.java.dataflow.FlowSteps
// import semmle.code.java.dataflow.FlowSources
// import semmle.code.java.dataflow.ExternalFlow
// import semmle.code.xml.AndroidManifest
// import semmle.code.java.dataflow.TaintTracking
// class MyTaintTrackingConfiguration extends TaintTracking::Configuration {
//   MyTaintTrackingConfiguration() { this = "MyTaintTrackingConfiguration" }
//   override predicate isSource(DataFlow::Node source) {
//     // exists(AndroidActivityXmlElement andActXmlElem |
//     //   andActXmlElem.hasDeepLink() and
//     //   source.asExpr() instanceof TypeActivity
//     //   )
//     source instanceof RemoteFlowSource and //AndroidIntentInput
//     exists(AndroidComponent andComp |
//       andComp.getAndroidComponentXmlElement().(AndroidActivityXmlElement).hasDeepLink() and
//       source.asExpr().getFile() = andComp.getFile() // ! ugly, see if better way to do this
//     )
//   }
//   override predicate isSink(DataFlow::Node sink) {
//     exists(MethodAccess m |
//       m.getMethod().hasName("getIntent") and
//       sink.asExpr() = m
//     )
//   }
// }
// from DataFlow::Node src, DataFlow::Node sink, MyTaintTrackingConfiguration config
// where config.hasFlow(src, sink)
// select src, "This environment variable constructs a URL $@.", sink, "here"
// * experiment with GLOBAL FLOW
// import java
// import semmle.code.java.dataflow.TaintTracking
// import semmle.code.java.frameworks.android.Intent
// import semmle.code.java.frameworks.android.Android
// import semmle.code.java.dataflow.DataFlow
// import semmle.code.java.dataflow.FlowSteps
// import semmle.code.java.dataflow.FlowSources
// import semmle.code.java.dataflow.ExternalFlow
// import semmle.code.xml.AndroidManifest
// import semmle.code.java.dataflow.TaintTracking
// class StartComponentConfiguration extends DataFlow::Configuration {
//   StartComponentConfiguration() { this = "StartComponentConfiguration" }
//   // Override `isSource` and `isSink`.
//   override predicate isSource(DataFlow::Node source) {
//     exists(ClassInstanceExpr classInstanceExpr |
//       classInstanceExpr.getConstructedType() instanceof TypeIntent and
//       source.asExpr() = classInstanceExpr
//     )
//   }
//   override predicate isSink(DataFlow::Node sink) {
//     exists(MethodAccess startActivity |
//       (
//         startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) or
//         startActivity.getMethod().overrides*(any(ActivityStartActivityMethod m))
//       ) and
//       sink.asExpr() = startActivity.getArgument(0)
//     )
//   }
// }
// class SendIntentConfiguration extends DataFlow::Configuration {
//   SendIntentConfiguration() { this = "SendIntentConfiguration" }
//   override predicate isSource(DataFlow::Node source) {
//     exists(MethodAccess startActivity |
//       (
//         startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) or
//         startActivity.getMethod().overrides*(any(ActivityStartActivityMethod m))
//       ) and
//       source.asExpr() = startActivity.getArgument(0)
//     )
//   }
//   override predicate isSink(DataFlow::Node sink) {
//     exists(MethodAccess getIntent |
//       getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
//       sink.asExpr() = getIntent
//     )
//   }
//   // override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
//   //   exists(MethodAccess startActivity, MethodAccess getIntent, ClassInstanceExpr newIntent |
//   //     startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//   //     getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
//   //     newIntent.getConstructedType() instanceof TypeIntent and
//   //     DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//   //     newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//   //       getIntent.getReceiverType() and
//   //     n1.asExpr() = startActivity.getArgument(0) and
//   //     n2.asExpr() = getIntent
//   //   )
//   // }
// }
// from
//   DataFlow::Node src1, DataFlow::Node sink1, StartComponentConfiguration config1,
//   DataFlow::Node src2, DataFlow::Node sink2, SendIntentConfiguration config2
// where
//   config1.hasFlow(src1, sink1) and
//   sink1 = src2 and
//   config2.hasFlow(src2, sink2) and
//   src2.asExpr().getFile().getBaseName() = "MainActivity.java" // ! just for faster testing, remove when done
// select src2, "This source flows to this $@.", sink2, "sink"
// * try wrapping whole thing in global flow
// class StartComponentConfiguration_Full extends DataFlow::Configuration {
//   StartComponentConfiguration_Full() { this = "StartComponentConfiguration_Full" }
//   // Override `isSource` and `isSink`.
//   override predicate isSource(DataFlow::Node source) {
//     exists(ClassInstanceExpr newIntent |
//       newIntent.getConstructedType() instanceof TypeIntent and
//       source.asExpr() = newIntent
//     )
//   }
//   override predicate isSink(DataFlow::Node sink) {
//     exists(MethodAccess getIntent |
//       getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
//       sink.asExpr() = getIntent
//     )
//   }
//   override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
//     exists(MethodAccess startActivity, ClassInstanceExpr newIntent |
//       startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//       newIntent.getConstructedType() instanceof TypeIntent and
//       DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//       node2.asExpr() = startActivity.getArgument(0) and
//       node1.asExpr() = newIntent
//     )
//   }
//   // override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
//   //   exists(MethodAccess startActivity, MethodAccess getIntent, ClassInstanceExpr newIntent |
//   //     startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//   //     getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
//   //     newIntent.getConstructedType() instanceof TypeIntent and
//   //     DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//   //     newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//   //       getIntent.getReceiverType() and
//   //     node1.asExpr() = startActivity.getArgument(0) and
//   //     node2.asExpr() = getIntent
//   //   )
//   // }
// }
// from DataFlow::Node src, DataFlow::Node sink, StartComponentConfiguration_Full config
// where
//   config.hasFlow(src, sink) and
//   sink.asExpr().getFile().getBaseName() = "MainActivity.java" // ! just for faster testing, remove when done
// select src, "This source flows to this $@.", sink, "sink"
// * DeepLinks config
// import java
// import semmle.code.java.dataflow.DataFlow
// import semmle.code.java.security.DeepLinks
// class DeepLinkConfig extends DataFlow::Configuration {
//   DeepLinkConfig() { this = "DeepLinkConfig" }
//   override predicate isSource(DataFlow::Node source) { source instanceof DeepLinkSource }
//   override predicate isSink(DataFlow::Node sink) { sink instanceof DeepLinkSink }
// }
// from DataFlow::Node src, DataFlow::Node sink, DeepLinkConfig config
// where
//   config.hasFlow(src, sink) and
//   sink.asExpr().getFile().getBaseName() = "MainActivity.java" // ! just for faster testing, remove when done
// select src, "This source flows to this $@.", sink, "sink"
// * two configs
import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.frameworks.android.DeepLink

from
  DataFlow::Node src, DataFlow::Node sink, StartComponentConfiguration config,
  StartComponentToIntentConfiguration sctiConfig
where
  sctiConfig.hasFlow(src, sink) and
  sink.asExpr().getFile().getBaseName() = "MainActivity.java" // ! just for faster testing, remove when done
select src, "This source flows to this $@.", sink, "sink"
