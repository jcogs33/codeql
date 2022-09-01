/** Provides classes and predicates to reason about deep links in Android. */

import java
private import semmle.code.java.frameworks.android.Intent
private import semmle.code.java.frameworks.android.AsyncTask
private import semmle.code.java.frameworks.android.Android
private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.FlowSteps
private import semmle.code.java.dataflow.ExternalFlow

// ! Remember to add 'private' annotation as needed to all new classes/predicates below.
// ! and clean-up in general...
// ! make a DeepLink step that combine Activity, Service, Receiver, etc?
/*
 * Below is a Draft/Test of modelling `Activity.startActivity` methods along
 * with the `Context.startActivity` methods.
 * Move to Intent.qll when finalized.
 */

/**
 * The method `Activity.startActivity` or `Context.startActivity`.
 */
class ContextOrActivityStartActivityMethod extends Method {
  ContextOrActivityStartActivityMethod() {
    // captures all `startAct` methods in both the Activity and the Context classes (9 total)
    this.getName().matches("start%Activit%") and
    (
      this.getDeclaringType() instanceof TypeContext or
      this.getDeclaringType() instanceof TypeActivity
    )
  }
}

/**
 * A value-preserving step from the Intent argument of a `startActivity` call to
 * a `getIntent` call in the Activity the Intent pointed to in its constructor.
 */
private class StartActivityIntentStep_ContextAndActivity extends AdditionalValueStep {
  // ! startActivityFromChild and startActivityFromFragment have Intent as argument(1),
  // ! but rest have Intent as argument(0)...
  // ! startActivityFromChild and startActivityFromFragment are also deprecated and
  // ! may need to look into modelling androidx.fragment.app.Fragment.startActivity() as well
  private Argument getStartActivityIntentArg(MethodAccess startActMethodAccess) {
    if
      startActMethodAccess.getMethod().hasName("startActivityFromChild") or
      startActMethodAccess.getMethod().hasName("startActivityFromFragment")
    then result = startActMethodAccess.getArgument(1)
    else result = startActMethodAccess.getArgument(0)
  }

  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, MethodAccess getIntent, ClassInstanceExpr newIntent |
      startActivity.getMethod().overrides*(any(ContextOrActivityStartActivityMethod m)) and
      getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      //DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      DataFlow::localExprFlow(newIntent, getStartActivityIntentArg(startActivity)) and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        getIntent.getReceiverType() and
      //n1.asExpr() = startActivity.getArgument(0) and
      n1.asExpr() = getStartActivityIntentArg(startActivity) and
      n2.asExpr() = getIntent
    )
  }
}

/* *********  INTENT METHODS, E.G. parseUri, getData, getExtras, etc. *********** */
/*
 * Below is a Draft/Test of modelling `Intent.parseUri`, `Intent.getData`,
 * and `Intent.getExtras` methods
 */

// ! Check if can use pre-existing Synthetic Field.
/**
 * The method `Intent.get%Extra` or `Intent.getExtras`.
 */
class AndroidGetExtrasMethod extends Method {
  AndroidGetExtrasMethod() {
    this.getName().matches("get%Extra%") and
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
    (this.hasName("parseUri") or this.hasName("getIntent")) and // ! Note to self: getIntent for older versions before deprecation to parseUri
    this.getDeclaringType() instanceof TypeIntent
  }
}
// /**
//  * A taint step from the Intent argument of a `startActivity` call to
//  * a `Intent.parseUri` call in the Activity the Intent pointed to in its constructor.
//  */
// private class StartActivityParseUriStep extends AdditionalTaintStep {
//   override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
//     exists(MethodAccess startActivity, MethodAccess parseUri, ClassInstanceExpr newIntent |
//       startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//       parseUri.getMethod().overrides*(any(AndroidParseUriMethod m)) and
//       newIntent.getConstructedType() instanceof TypeIntent and
//       DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//       newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//         parseUri.getReceiverType() and
//       n1.asExpr() = startActivity.getArgument(0) and
//       n2.asExpr() = parseUri
//     )
//   }
// }
// /**
//  * A taint step from the Intent argument of a `startActivity` call to
//  * a `Intent.get%Extra%` call in the Activity the Intent pointed to in its constructor.
//  */
// private class StartActivityGetDataStep extends AdditionalTaintStep {
//   override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
//     exists(MethodAccess startActivity, MethodAccess getData, ClassInstanceExpr newIntent |
//       startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//       getData.getMethod().overrides*(any(AndroidGetDataMethod m)) and
//       newIntent.getConstructedType() instanceof TypeIntent and
//       DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//       newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//         getData.getReceiverType() and
//       n1.asExpr() = startActivity.getArgument(0) and
//       n2.asExpr() = getData
//     )
//   }
// }
// /**
//  * A taint step from the Intent argument of a `startActivity` call to
//  * a `Intent.getData` call in the Activity the Intent pointed to in its constructor.
//  */
// private class StartActivityGetExtrasStep extends AdditionalTaintStep {
//   override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
//     exists(MethodAccess startActivity, MethodAccess getExtras, ClassInstanceExpr newIntent |
//       startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
//       getExtras.getMethod().overrides*(any(AndroidGetExtrasMethod m)) and
//       newIntent.getConstructedType() instanceof TypeIntent and
//       DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
//       newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//         getExtras.getReceiverType() and
//       n1.asExpr() = startActivity.getArgument(0) and
//       n2.asExpr() = getExtras
//     )
//   }
// }
