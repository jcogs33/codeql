/** Provides classes and predicates to reason about deep links in Android. */

import java
private import semmle.code.java.frameworks.android.Intent
//private import semmle.code.java.frameworks.android.AsyncTask
private import semmle.code.java.frameworks.android.Android
private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.FlowSteps
//private import semmle.code.java.dataflow.ExternalFlow
private import semmle.code.xml.AndroidManifest

//private import semmle.code.java.dataflow.TaintTracking
// ! if keeping this class, should prbly move to security folder.
// ! Remember to add 'private' annotation as needed to all new classes/predicates below.
// ! and clean-up in general...
// ! make a DeepLink step that combine Activity, Service, Receiver, etc?
/**
 * A value-preserving step from the Intent argument of a method call that starts a component to
 * a `getIntent` call or `Intent` parameter in the component that the Intent pointed to in its constructor.
 */
private class DeepLinkIntentStep extends AdditionalValueStep {
  // DeepLinkIntentStep() {
  //   this instanceof StartActivityIntentStep_ContextAndActivity or
  //   this instanceof SendBroadcastReceiverIntentStep or
  //   this instanceof StartServiceIntentStep
  // }
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    // ! simplify below
    (
      exists(StartServiceIntentStep startServiceIntentStep | startServiceIntentStep.step(n1, n2))
      or
      exists(SendBroadcastReceiverIntentStep sendBroadcastIntentStep |
        sendBroadcastIntentStep.step(n1, n2)
      )
      or
      exists(
        StartActivityIntentStep_ContextAndActivity startActivityIntentStep,
        IntentVariableToStartActivityStep intVarStartActStep
      |
        intVarStartActStep.step(n1, n2) and
        startActivityIntentStep.step(n1, n2)
      )
    ) and
    exists(AndroidComponent andComp |
      andComp.getAndroidComponentXmlElement().(AndroidActivityXmlElement).hasDeepLink() and
      n1.asExpr().getFile() = andComp.getFile() // ! ugly, see if better way to do this
    )
  }
}

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
class StartActivityIntentStep_ContextAndActivity extends AdditionalValueStep {
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

  // ! Intent has two constructors with Class<?> parameter, only the first one with argument
  // ! at position 1 was modelled before leading to lost flow. The second constructor with
  // ! argument at position 3 needs to be modelled as well.
  // ! See https://developer.android.com/reference/android/content/Intent#public-constructors
  private Argument getIntentConstructorClassArg(ClassInstanceExpr intent) {
    if intent.getNumArgument() = 2
    then result = intent.getArgument(1)
    else result = intent.getArgument(3)
  }

  // ! should be more general than ClassInstanceExpr?
  // ! rename to overriden getArgument in Expr.qll file?
  // ! newIntent becomes `this` if moved to Expr.qll file.
  private Expr getArgumentOfType(Type type, ClassInstanceExpr newIntent) {
    exists(Argument arg |
      arg = newIntent.getAnArgument() and
      arg.getType() = type and
      result = arg and
      newIntent.getFile().getBaseName().toString() = "MainActivity.java" and
      //type.toString() = "Class<ManageReposActivity>"
      type.getName().matches("Class<%>")
    )
    // newIntent.getAnArgument().getType() = type and
    // result = newIntent.getAnArgument() and
    // newIntent.getFile().getBaseName().toString() = "MainActivity.java" and
    // type.toString() = "String"
  }

  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(
      MethodAccess startActivity, MethodAccess getIntent, ClassInstanceExpr newIntent, Type argType
    |
      startActivity.getMethod().overrides*(any(ContextOrActivityStartActivityMethod m)) and
      getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      //DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      DataFlow::localExprFlow(newIntent, getStartActivityIntentArg(startActivity)) and
      // newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
      //   getIntent.getReceiverType() and
      // getIntentConstructorClassArg(newIntent).getType().(ParameterizedType).getATypeArgument() =
      //   getIntent.getReceiverType() and
      argType.getName().matches("Class<%>") and
      newIntent
          .getArgumentOfType_ExprClass(argType)
          .getType()
          .(ParameterizedType)
          .getATypeArgument() = getIntent.getReceiverType() and
      //n1.asExpr() = startActivity.getArgument(0) and
      n1.asExpr() = getStartActivityIntentArg(startActivity) and
      n2.asExpr() = getIntent
    )
  }
}

/**
 * A value-preserving step from the Intent variable
 * the `Intent` Parameter in the `startActivity`.
 */
class IntentVariableToStartActivityStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, Variable intentTypeTest |
      startActivity.getMethod().overrides*(any(ContextOrActivityStartActivityMethod m)) and
      intentTypeTest.getType() instanceof TypeIntent and
      //startActivity.getFile().getBaseName() = "MainActivity.java" and // ! REMOVE
      DataFlow::localExprFlow(intentTypeTest.getInitializer(), startActivity.getArgument(0)) and
      n1.asExpr() = intentTypeTest.getInitializer() and
      n2.asExpr() = startActivity.getArgument(0) // ! switch to getStartActivityIntentArg(startActivity)
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
