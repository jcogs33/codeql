/** Provides classes and predicates to reason about deep links in Android. */

import java
private import semmle.code.java.frameworks.android.Intent
private import semmle.code.java.frameworks.android.AsyncTask
private import semmle.code.java.frameworks.android.Android
private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.FlowSteps
private import semmle.code.java.dataflow.ExternalFlow

// ! Remember to add 'private' annotation as needed to all new classes/predicates below.
/**
 * The method `Intent.getSerializableExtra`
 */
class AndroidGetSerializableExtraMethod extends Method {
  AndroidGetSerializableExtraMethod() {
    this.hasName("getSerializableExtra") and this.getDeclaringType() instanceof TypeIntent
  }
}

/**
 * The method `Context.startService`.
 */
class ContextStartServiceMethod extends Method {
  ContextStartServiceMethod() {
    this.hasName("startService") and
    this.getDeclaringType() instanceof TypeContext
  }
}

/**
 * The method `Context.sendBroadcast`.
 */
class ContextSendBroadcastMethod extends Method {
  ContextSendBroadcastMethod() {
    this.hasName("sendBroadcast") and
    this.getDeclaringType() instanceof TypeContext
  }
}

/**
 * A value-preserving step from the Intent argument of a `startService` call to
 * a `getSerializableExtra` call in the Service the Intent pointed to in its constructor.
 */
class StartServiceSerializableIntentStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(
      MethodAccess startService, MethodAccess getSerializableExtra, ClassInstanceExpr newIntent
    |
      startService.getMethod().overrides*(any(ContextStartServiceMethod m)) and
      getSerializableExtra.getMethod().overrides*(any(AndroidGetSerializableExtraMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startService.getArgument(0)) and
      //newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      // getSerializableExtra.getReceiverType() and
      //   newIntent.getArgument(1).toString() = "FetcherService.class" and // BAD
      //   getSerializableExtra.getFile().getBaseName() = "RouterActivity.java" and // BAD
      newIntent.getArgument(1).toString() = "FileDownloader.class" and // BAD
      newIntent.getFile().getBaseName() = "FileDisplayActivity.java" and // BAD
      getSerializableExtra.getFile().getBaseName() = "FileDownloader.java" and // BAD
      n1.asExpr() = startService.getArgument(0) and
      n2.asExpr() = getSerializableExtra
    )
  }
}

/**
 * A value-preserving step from the Intent argument of a `startService` call to
 * an `Intent` TypeAccess in the Service the Intent pointed to in its constructor.
 */
class StartServiceIntentStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startService, VarAccess intentVar, ClassInstanceExpr newIntent |
      startService.getMethod().overrides*(any(ContextStartServiceMethod m)) and
      //getSerializableExtra.getMethod().overrides*(any(AndroidGetSerializableExtraMethod m)) and
      intentVar.getType() instanceof TypeIntent and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startService.getArgument(0)) and
      //   newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      //     intentVar.getBasicBlock().getBasicBlock() and
      //   newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      //     intent.getType().(ParameterizedType).getATypeArgument() and
      //   newIntent.getArgument(1).toString() = "FetcherService.class" and // BAD
      //   intentVar.getFile().getBaseName() = "RouterActivity.java" and // BAD
      newIntent.getArgument(1).toString() = "FileDownloader.class" and // BAD
      newIntent.getFile().getBaseName() = "FileDisplayActivity.java" and // BAD
      intentVar.getFile().getBaseName() = "FileDownloader.java" and // BAD
      n1.asExpr() = startService.getArgument(0) and
      n2.asExpr() = intentVar
    )
  }
}

/**
 * A value-preserving step from the Intent argument of a `sendBroadcast` call to
 * an `Intent` TypeAccess in the Receiver the Intent pointed to in its constructor.
 */
class SendBroadcastIntentStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess sendBroadcast, VarAccess intentVar, ClassInstanceExpr newIntent |
      sendBroadcast.getMethod().overrides*(any(ContextSendBroadcastMethod m)) and
      //getSerializableExtra.getMethod().overrides*(any(AndroidGetSerializableExtraMethod m)) and
      intentVar.getType() instanceof TypeIntent and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, sendBroadcast.getArgument(0)) and
      //   newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      //     intentVar.getBasicBlock().getBasicBlock() and
      //   newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      //     intent.getType().(ParameterizedType).getATypeArgument() and
      //   newIntent.getArgument(1).toString() = "FetcherService.class" and // BAD
      //   intentVar.getFile().getBaseName() = "RouterActivity.java" and // BAD
      newIntent.getArgument(1).toString() = "FileDownloader.class" and // BAD
      newIntent.getFile().getBaseName() = "FileDisplayActivity.java" and // BAD
      intentVar.getFile().getBaseName() = "FileDownloader.java" and // BAD
      n1.asExpr() = sendBroadcast.getArgument(0) and
      n2.asExpr() = intentVar
    )
  }
}

// ! Check if can use pre-existing Synthetic Field instead of the below.
/**
 * The method `Intent.get%Extra` or `Intent.getExtras`.
 */
class AndroidGetExtrasMethod extends Method {
  AndroidGetExtrasMethod() {
    (this.hasName("getExtras") or this.getName().matches("get%Extra")) and // ! switch to get%Extra% instead, I think wildcard holds for nothing there
    this.getDeclaringType() instanceof TypeIntent
  }
}

/**
 * The method `Intent.getData`
 */
class AndroidGetDataMethod extends Method {
  AndroidGetDataMethod() {
    this.hasName("getData") and this.getDeclaringType() instanceof TypeIntent
  }
}

/**
 * The method `Intent.parseUri`
 */
class AndroidParseUriMethod extends Method {
  AndroidParseUriMethod() {
    (this.hasName("parseUri") or this.hasName("getIntent")) and // getIntent for older versions before deprecation to parseUri
    this.getDeclaringType() instanceof TypeIntent
  }
}

/**
 * A taint step from the Intent argument of a `startActivity` call to
 * a `Intent.parseUri` call in the Activity the Intent pointed to in its constructor.
 */
private class StartActivityParseUriStep extends AdditionalTaintStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, MethodAccess parseUri, ClassInstanceExpr newIntent |
      startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
      parseUri.getMethod().overrides*(any(AndroidParseUriMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        parseUri.getReceiverType() and
      n1.asExpr() = startActivity.getArgument(0) and
      n2.asExpr() = parseUri
    )
  }
}

/**
 * A taint step from the Intent argument of a `startActivity` call to
 * a `Intent.get%Extra%` call in the Activity the Intent pointed to in its constructor.
 */
private class StartActivityGetDataStep extends AdditionalTaintStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, MethodAccess getData, ClassInstanceExpr newIntent |
      startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
      getData.getMethod().overrides*(any(AndroidGetDataMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        getData.getReceiverType() and
      n1.asExpr() = startActivity.getArgument(0) and
      n2.asExpr() = getData
    )
  }
}

/**
 * A taint step from the Intent argument of a `startActivity` call to
 * a `Intent.getData` call in the Activity the Intent pointed to in its constructor.
 */
private class StartActivityGetExtrasStep extends AdditionalTaintStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, MethodAccess getExtras, ClassInstanceExpr newIntent |
      startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
      getExtras.getMethod().overrides*(any(AndroidGetExtrasMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        getExtras.getReceiverType() and
      n1.asExpr() = startActivity.getArgument(0) and
      n2.asExpr() = getExtras
    )
  }
}
