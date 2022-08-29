/** Provides classes and predicates to reason about deep links in Android. */

import java
//private import semmle.code.java.frameworks.android.Intent
private import semmle.code.java.frameworks.android.AsyncTask
private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.FlowSteps
private import semmle.code.java.dataflow.ExternalFlow

/**
 * The class `android.content.Intent`.
 */
class TypeIntent extends Class {
  TypeIntent() { this.hasQualifiedName("android.content", "Intent") }
}

/** The class `android.content.ComponentName`. */
class TypeComponentName extends Class {
  TypeComponentName() { this.hasQualifiedName("android.content", "ComponentName") }
}

/**
 * The class `android.app.Activity`.
 */
class TypeActivity extends Class {
  TypeActivity() { this.hasQualifiedName("android.app", "Activity") }
}

/**
 * The class `android.content.Context`.
 */
class TypeContext extends RefType {
  // Not inlining this makes it more likely to be used as a sentinel,
  // which is useful when running Android queries on non-Android projects.
  pragma[noinline]
  TypeContext() { this.hasQualifiedName("android.content", "Context") }
}

/**
 * The class `android.content.BroadcastReceiver`.
 */
class TypeBroadcastReceiver extends Class {
  TypeBroadcastReceiver() { this.hasQualifiedName("android.content", "BroadcastReceiver") }
}

/**
 * The method `Activity.getIntent`
 */
class AndroidGetIntentMethod extends Method {
  AndroidGetIntentMethod() {
    this.hasName("getIntent") and this.getDeclaringType() instanceof TypeActivity
  }
}

/**
 * The method `Intent.getSerializableExtra`
 */
class AndroidGetSerializableExtraMethod extends Method {
  AndroidGetSerializableExtraMethod() {
    this.hasName("getSerializableExtra") and this.getDeclaringType() instanceof TypeIntent
  }
}

/**
 * The method `BroadcastReceiver.onReceive`.
 */
class AndroidReceiveIntentMethod extends Method {
  AndroidReceiveIntentMethod() {
    this.hasName("onReceive") and this.getDeclaringType() instanceof TypeBroadcastReceiver
  }
}

/**
 * The method `Context.startActivity` or `startActivities`.
 */
class ContextStartActivityMethod extends Method {
  ContextStartActivityMethod() {
    (
      this.hasName("startActivity") or
      this.hasName("startActivities") //or
      //this.hasName("startIntentSender") // might not be for an Activity - add new class to model this?
      //this.hasName("startService")
    ) and
    this.getDeclaringType() instanceof TypeContext
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
 * Specifies that if an `Intent` is tainted, then so are its synthetic fields.
 */
private class IntentFieldsInheritTaint extends DataFlow::SyntheticFieldContent,
  TaintInheritingContent {
  IntentFieldsInheritTaint() { this.getField().matches("android.content.Intent.%") }
}

/**
 * The method `Intent.getParcelableExtra`.
 */
class IntentGetParcelableExtraMethod extends Method {
  IntentGetParcelableExtraMethod() {
    this.hasName("getParcelableExtra") and
    this.getDeclaringType() instanceof TypeIntent
  }
}

/** The class `android.os.BaseBundle`, or a class that extends it. */
class AndroidBundle extends Class {
  AndroidBundle() { this.getAnAncestor().hasQualifiedName("android.os", "BaseBundle") }
}

/**
 * An `Intent` that explicitly sets a destination component.
 *
 * The `Intent` is not considered explicit if a `null` value ever flows to the destination
 * component, even if only conditionally.
 *
 * For example, in the following code, `intent` is not considered an `ExplicitIntent`:
 * ```java
 * intent.setClass(condition ? null : "MyClass");
 * ```
 */
class ExplicitIntent extends Expr {
  ExplicitIntent() {
    exists(MethodAccess ma, Method m |
      ma.getMethod() = m and
      m.getDeclaringType() instanceof TypeIntent and
      m.hasName(["setPackage", "setClass", "setClassName", "setComponent"]) and
      not exists(NullLiteral nullLiteral | DataFlow::localExprFlow(nullLiteral, ma.getAnArgument())) and
      ma.getQualifier() = this
    )
    or
    exists(ConstructorCall cc, Argument classArg |
      cc.getConstructedType() instanceof TypeIntent and
      cc.getAnArgument() = classArg and
      classArg.getType() instanceof TypeClass and
      not exists(NullLiteral nullLiteral | DataFlow::localExprFlow(nullLiteral, classArg)) and
      cc = this
    )
  }
}

/**
 * A sanitizer for explicit intents.
 *
 * Use this when you want to work only with implicit intents
 * in a `DataFlow` or `TaintTracking` configuration.
 */
class ExplicitIntentSanitizer extends DataFlow::Node {
  ExplicitIntentSanitizer() {
    exists(ExplicitIntent explIntent | DataFlow::localExprFlow(explIntent, this.asExpr()))
  }
}

private class BundleExtrasSyntheticField extends SyntheticField {
  BundleExtrasSyntheticField() { this = "android.content.Intent.extras" }

  override RefType getType() { result instanceof AndroidBundle }
}

/**
 * Holds if extras may be implicitly read from the Intent `node`.
 */
predicate allowIntentExtrasImplicitRead(DataFlow::Node node, DataFlow::Content c) {
  node.getType() instanceof TypeIntent and
  (
    c instanceof DataFlow::MapValueContent
    or
    c.(DataFlow::SyntheticFieldContent).getType() instanceof AndroidBundle
  )
}

/**
 * The fields to grant URI permissions of the class `android.content.Intent`:
 *
 * - `Intent.FLAG_GRANT_READ_URI_PERMISSION`
 * - `Intent.FLAG_GRANT_WRITE_URI_PERMISSION`
 * - `Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION`
 * - `Intent.FLAG_GRANT_PREFIX_URI_PERMISSION`
 */
class GrantUriPermissionFlag extends Field {
  GrantUriPermissionFlag() {
    this.getDeclaringType() instanceof TypeIntent and
    this.getName().matches("FLAG_GRANT_%_URI_PERMISSION")
  }
}

/** The field `Intent.FLAG_GRANT_READ_URI_PERMISSION`. */
class GrantReadUriPermissionFlag extends GrantUriPermissionFlag {
  GrantReadUriPermissionFlag() { this.hasName("FLAG_GRANT_READ_URI_PERMISSION") }
}

/** The field `Intent.FLAG_GRANT_WRITE_URI_PERMISSION`. */
class GrantWriteUriPermissionFlag extends GrantUriPermissionFlag {
  GrantWriteUriPermissionFlag() { this.hasName("FLAG_GRANT_WRITE_URI_PERMISSION") }
}

/**
 * A value-preserving step from the Intent argument of a `startActivity` call to
 * a `getIntent` call in the Activity the Intent pointed to in its constructor.
 */
//private class StartActivityIntentStep extends AdditionalValueStep {
class StartActivityIntentStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(MethodAccess startActivity, MethodAccess getIntent, ClassInstanceExpr newIntent |
      startActivity.getMethod().overrides*(any(ContextStartActivityMethod m)) and
      getIntent.getMethod().overrides*(any(AndroidGetIntentMethod m)) and
      newIntent.getConstructedType() instanceof TypeIntent and
      DataFlow::localExprFlow(newIntent, startActivity.getArgument(0)) and
      newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
        getIntent.getReceiverType() and
      n1.asExpr() = startActivity.getArgument(0) and
      n2.asExpr() = getIntent
    )
  }
}

// /**
//  * A value-preserving step from the Intent argument of a `startService` call to
//  * a `getSerializableExtra` call in the Service the Intent pointed to in its constructor.
//  */
// class StartServiceIntentStep extends AdditionalValueStep {
//   override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
//     exists(
//       MethodAccess startService, MethodAccess getSerializableExtra, ClassInstanceExpr newIntent
//     |
//       startService.getMethod().overrides*(any(ContextStartServiceMethod m)) and
//       getSerializableExtra.getMethod().overrides*(any(AndroidGetSerializableExtraMethod m)) and
//       newIntent.getConstructedType() instanceof TypeIntent and
//       DataFlow::localExprFlow(newIntent, startService.getArgument(0)) and
//       //newIntent.getArgument(1).getType().(ParameterizedType).getATypeArgument() =
//       // getSerializableExtra.getReceiverType() and
//       newIntent.getArgument(1).toString() = "FetcherService.class" and // BAD
//       getSerializableExtra.getFile().getBaseName() = "RouterActivity.java" and // BAD
//       n1.asExpr() = startService.getArgument(0) and
//       n2.asExpr() = getSerializableExtra
//     )
//   }
// }
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
      newIntent.getArgument(1).toString() = "FetcherService.class" and // BAD
      intentVar.getFile().getBaseName() = "RouterActivity.java" and // BAD
      n1.asExpr() = startService.getArgument(0) and
      n2.asExpr() = intentVar
    )
  }
}

private class IntentBundleFlowSteps extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        //"namespace;type;subtypes;name;signature;ext;input;output;kind"
        "android.os;BaseBundle;true;get;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;BaseBundle;true;getString;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;BaseBundle;true;getString;(String,String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;BaseBundle;true;getString;(String,String);;Argument[1];ReturnValue;value;manual",
        "android.os;BaseBundle;true;getStringArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;BaseBundle;true;keySet;();;Argument[-1].MapKey;ReturnValue.Element;value;manual",
        "android.os;BaseBundle;true;putAll;(PersistableBundle);;Argument[0].MapKey;Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putAll;(PersistableBundle);;Argument[0].MapValue;Argument[-1].MapValue;value;manual",
        "android.os;BaseBundle;true;putBoolean;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putBooleanArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putDouble;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putDoubleArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putInt;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putIntArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putLong;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putLongArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putString;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putString;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;BaseBundle;true;putStringArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;BaseBundle;true;putStringArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;false;Bundle;(Bundle);;Argument[0].MapKey;Argument[-1].MapKey;value;manual",
        "android.os;Bundle;false;Bundle;(Bundle);;Argument[0].MapValue;Argument[-1].MapValue;value;manual",
        "android.os;Bundle;false;Bundle;(PersistableBundle);;Argument[0].MapKey;Argument[-1].MapKey;value;manual",
        "android.os;Bundle;false;Bundle;(PersistableBundle);;Argument[0].MapValue;Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;clone;();;Argument[-1].MapKey;ReturnValue.MapKey;value;manual",
        "android.os;Bundle;true;clone;();;Argument[-1].MapValue;ReturnValue.MapValue;value;manual",
        // model for Bundle.deepCopy is not fully precise, as some map values aren't copied by value
        "android.os;Bundle;true;deepCopy;();;Argument[-1].MapKey;ReturnValue.MapKey;value;manual",
        "android.os;Bundle;true;deepCopy;();;Argument[-1].MapValue;ReturnValue.MapValue;value;manual",
        "android.os;Bundle;true;getBinder;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getBundle;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getByteArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getCharArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getCharSequence;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getCharSequence;(String,CharSequence);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getCharSequence;(String,CharSequence);;Argument[1];ReturnValue;value;manual",
        "android.os;Bundle;true;getCharSequenceArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getCharSequenceArrayList;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getParcelable;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getParcelableArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getParcelableArrayList;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getSerializable;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getSparseParcelableArray;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;getStringArrayList;(String);;Argument[-1].MapValue;ReturnValue;value;manual",
        "android.os;Bundle;true;putAll;(Bundle);;Argument[0].MapKey;Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putAll;(Bundle);;Argument[0].MapValue;Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putBinder;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putBinder;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putBundle;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putBundle;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putByte;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putByteArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putByteArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putChar;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putCharArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putCharArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putCharSequence;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putCharSequence;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putCharSequenceArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putCharSequenceArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putCharSequenceArrayList;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putCharSequenceArrayList;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putFloat;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putFloatArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putIntegerArrayList;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putParcelable;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putParcelable;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putParcelableArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putParcelableArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putParcelableArrayList;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putParcelableArrayList;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putSerializable;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putSerializable;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putShort;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putShortArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putSize;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putSizeF;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putSparseParcelableArray;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putSparseParcelableArray;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;putStringArrayList;;;Argument[0];Argument[-1].MapKey;value;manual",
        "android.os;Bundle;true;putStringArrayList;;;Argument[1];Argument[-1].MapValue;value;manual",
        "android.os;Bundle;true;readFromParcel;;;Argument[0];Argument[-1].MapKey;taint;manual",
        "android.os;Bundle;true;readFromParcel;;;Argument[0];Argument[-1].MapValue;taint;manual",
        // currently only the Extras part of the intent and the data field are fully modeled
        "android.content;Intent;false;Intent;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapKey;Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;false;Intent;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapValue;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;false;Intent;(String,Uri);;Argument[1];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;false;Intent;(String,Uri,Context,Class);;Argument[1];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;true;addCategory;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;addFlags;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;false;createChooser;;;Argument[0..2];ReturnValue.SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;getBundleExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getByteArrayExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getCharArrayExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getCharSequenceArrayExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getCharSequenceArrayListExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getCharSequenceExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getData;;;Argument[-1].SyntheticField[android.content.Intent.data];ReturnValue;value;manual",
        "android.content;Intent;true;getDataString;;;Argument[-1].SyntheticField[android.content.Intent.data];ReturnValue;taint;manual",
        "android.content;Intent;true;getExtras;();;Argument[-1].SyntheticField[android.content.Intent.extras];ReturnValue;value;manual",
        "android.content;Intent;false;getIntent;;;Argument[0];ReturnValue.SyntheticField[android.content.Intent.data];taint;manual",
        "android.content;Intent;false;getIntentOld;;;Argument[0];ReturnValue.SyntheticField[android.content.Intent.data];taint;manual",
        "android.content;Intent;true;getParcelableArrayExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getParcelableArrayListExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getParcelableExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getSerializableExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getStringArrayExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getStringArrayListExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;true;getStringExtra;(String);;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;ReturnValue;value;manual",
        "android.content;Intent;false;parseUri;;;Argument[0];ReturnValue.SyntheticField[android.content.Intent.data];taint;manual",
        "android.content;Intent;true;putCharSequenceArrayListExtra;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putCharSequenceArrayListExtra;;;Argument[1];Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putCharSequenceArrayListExtra;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putExtra;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putExtra;;;Argument[1];Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putExtra;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putExtras;(Bundle);;Argument[0].MapKey;Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putExtras;(Bundle);;Argument[0].MapValue;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putExtras;(Bundle);;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putExtras;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapKey;Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putExtras;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapValue;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putExtras;(Intent);;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putIntegerArrayListExtra;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putIntegerArrayListExtra;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putParcelableArrayListExtra;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putParcelableArrayListExtra;;;Argument[1];Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putParcelableArrayListExtra;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;putStringArrayListExtra;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;putStringArrayListExtra;;;Argument[1];Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;putStringArrayListExtra;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;replaceExtras;(Bundle);;Argument[0].MapKey;Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;replaceExtras;(Bundle);;Argument[0].MapValue;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;replaceExtras;(Bundle);;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;replaceExtras;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapKey;Argument[-1].SyntheticField[android.content.Intent.extras].MapKey;value;manual",
        "android.content;Intent;true;replaceExtras;(Intent);;Argument[0].SyntheticField[android.content.Intent.extras].MapValue;Argument[-1].SyntheticField[android.content.Intent.extras].MapValue;value;manual",
        "android.content;Intent;true;replaceExtras;(Intent);;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setAction;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setClass;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setClassName;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setComponent;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setData;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setData;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;true;setDataAndNormalize;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setDataAndNormalize;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;true;setDataAndType;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setDataAndType;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;true;setDataAndTypeAndNormalize;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setDataAndTypeAndNormalize;;;Argument[0];Argument[-1].SyntheticField[android.content.Intent.data];value;manual",
        "android.content;Intent;true;setFlags;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setIdentifier;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setPackage;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setType;;;Argument[-1];ReturnValue;value;manual",
        "android.content;Intent;true;setTypeAndNormalize;;;Argument[-1];ReturnValue;value;manual"
      ]
  }
}

private class IntentComponentTaintSteps extends SummaryModelCsv {
  override predicate row(string s) {
    s =
      [
        "android.content;Intent;true;Intent;(Intent);;Argument[0];Argument[-1];taint;manual",
        "android.content;Intent;true;Intent;(Context,Class);;Argument[1];Argument[-1];taint;manual",
        "android.content;Intent;true;Intent;(String,Uri,Context,Class);;Argument[3];Argument[-1];taint;manual",
        "android.content;Intent;true;getIntent;(String);;Argument[0];ReturnValue;taint;manual",
        "android.content;Intent;true;getIntentOld;(String);;Argument[0];ReturnValue;taint;manual",
        "android.content;Intent;true;parseUri;(String,int);;Argument[0];ReturnValue;taint;manual",
        "android.content;Intent;true;setPackage;;;Argument[0];Argument[-1];taint;manual",
        "android.content;Intent;true;setClass;;;Argument[1];Argument[-1];taint;manual",
        "android.content;Intent;true;setClassName;(Context,String);;Argument[1];Argument[-1];taint;manual",
        "android.content;Intent;true;setClassName;(String,String);;Argument[0..1];Argument[-1];taint;manual",
        "android.content;Intent;true;setComponent;;;Argument[0];Argument[-1];taint;manual",
        "android.content;ComponentName;false;ComponentName;(String,String);;Argument[0..1];Argument[-1];taint;manual",
        "android.content;ComponentName;false;ComponentName;(Context,String);;Argument[1];Argument[-1];taint;manual",
        "android.content;ComponentName;false;ComponentName;(Context,Class);;Argument[1];Argument[-1];taint;manual",
        "android.content;ComponentName;false;ComponentName;(Parcel);;Argument[0];Argument[-1];taint;manual",
        "android.content;ComponentName;false;createRelative;(String,String);;Argument[0..1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;createRelative;(Context,String);;Argument[1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;flattenToShortString;;;Argument[-1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;flattenToString;;;Argument[-1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;getClassName;;;Argument[-1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;getPackageName;;;Argument[-1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;getShortClassName;;;Argument[-1];ReturnValue;taint;manual",
        "android.content;ComponentName;false;unflattenFromString;;;Argument[0];ReturnValue;taint;manual"
      ]
  }
}

// *************************************************************************************************
/*
 * The following flow steps aim to model the life-cycle of `AsyncTask`s described here:
 * https://developer.android.com/reference/android/os/AsyncTask#the-4-steps
 */

/**
 * A taint step from the vararg arguments of `AsyncTask::execute` and `AsyncTask::executeOnExecutor`
 * to the parameter of `AsyncTask::doInBackground`.
 */
private class AsyncTaskExecuteAdditionalValueStep extends AdditionalTaintStep {
  override predicate step(DataFlow::Node node1, DataFlow::Node node2) {
    exists(ExecuteAsyncTaskMethodAccess ma, AsyncTaskRunInBackgroundMethod m |
      DataFlow::getInstanceArgument(ma).getType() = m.getDeclaringType()
    |
      node1.asExpr() = ma.getParamsArgument() and
      node2.asParameter() = m.getParameter(0)
    )
  }
}

/**
 * A value-preserving step from the return value of `AsyncTask::doInBackground`
 * to the parameter of `AsyncTask::onPostExecute`.
 */
private class AsyncTaskOnPostExecuteAdditionalValueStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node node1, DataFlow::Node node2) {
    exists(
      AsyncTaskRunInBackgroundMethod runInBackground, AsyncTaskOnPostExecuteMethod onPostExecute
    |
      onPostExecute.getDeclaringType() = runInBackground.getDeclaringType()
    |
      node1.asExpr() = any(ReturnStmt r | r.getEnclosingCallable() = runInBackground).getResult() and
      node2.asParameter() = onPostExecute.getParameter(0)
    )
  }
}

/**
 * A value-preserving step from field initializers in `AsyncTask`'s constructor or initializer method
 * to the instance parameter of `AsyncTask::runInBackground` and `AsyncTask::onPostExecute`.
 */
private class AsyncTaskFieldInitQualifierToInstanceParameterStep extends AdditionalValueStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(AsyncTaskInit init, Callable receiver |
      n1.(DataFlow::PostUpdateNode).getPreUpdateNode() =
        DataFlow::getFieldQualifier(any(FieldWrite f | f.getEnclosingCallable() = init)) and
      n2.(DataFlow::InstanceParameterNode).getCallable() = receiver and
      receiver.getDeclaringType() = init.getDeclaringType() and
      (
        receiver instanceof AsyncTaskRunInBackgroundMethod or
        receiver instanceof AsyncTaskOnPostExecuteMethod
      )
    )
  }
}

/**
 * The Android class `android.os.AsyncTask`.
 */
private class AsyncTask extends RefType {
  AsyncTask() { this.hasQualifiedName("android.os", "AsyncTask") }
}

/** The constructor or initializer method of the `android.os.AsyncTask` class. */
private class AsyncTaskInit extends Callable {
  AsyncTaskInit() {
    this.getDeclaringType().getSourceDeclaration().getASourceSupertype*() instanceof AsyncTask and
    (this instanceof Constructor or this instanceof InitializerMethod)
  }
}

/** A call to the `execute` or `executeOnExecutor` methods of the `android.os.AsyncTask` class. */
private class ExecuteAsyncTaskMethodAccess extends MethodAccess {
  ExecuteAsyncTaskMethodAccess() {
    this.getMethod().hasName(["execute", "executeOnExecutor"]) and
    this.getMethod().getDeclaringType().getSourceDeclaration().getASourceSupertype*() instanceof
      AsyncTask
  }

  /** Returns the `params` argument of this call. */
  Argument getParamsArgument() { result = this.getAnArgument() and result.isVararg() }
}

/** The `doInBackground` method of the `android.os.AsyncTask` class. */
private class AsyncTaskRunInBackgroundMethod extends Method {
  AsyncTaskRunInBackgroundMethod() {
    this.getDeclaringType().getSourceDeclaration().getASourceSupertype*() instanceof AsyncTask and
    this.hasName("doInBackground")
  }
}

/** The `onPostExecute` method of the `android.os.AsyncTask` class. */
private class AsyncTaskOnPostExecuteMethod extends Method {
  AsyncTaskOnPostExecuteMethod() {
    this.getDeclaringType().getSourceDeclaration().getASourceSupertype*() instanceof AsyncTask and
    this.hasName("onPostExecute")
  }
}
