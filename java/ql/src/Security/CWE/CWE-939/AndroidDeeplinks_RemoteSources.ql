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

import java
import semmle.code.xml.AndroidManifest
// * selects entire component
// from AndroidComponentXmlElement compElement
// where
//   //exists(compElement.getAnIntentFilterElement()) and // has an intent filter - below all show that it has an intent-filter, duplicates work
//   compElement.getAnIntentFilterElement().getAnActionElement().getActionName() =
//     "android.intent.action.VIEW" and
//   compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.BROWSABLE" and
//   compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.DEFAULT" and
//   compElement.getAnIntentFilterElement().getAChild("data").hasAttribute("scheme") // make sure to check for 'android' prefix in real query
// select compElement, "A deeplink is used here."
import semmle.code.java.frameworks.android.Android

// * select component that declares a getUrl method
// from AndroidComponent andComp
// where andComp.declaresMethod("getUrl")
// select andComp, "This component is reachable through a deeplink."
// * select all methods?
// from AndroidComponent andComp
// where andComp.declaresMethod("getUrl")
// select andComp.getAMethod(), "This component is reachable through a deeplink."
// * select just the getUrl method
// from AndroidComponent andComp, Callable callable, Method m
// where
//   //andComp.declaresMethod("getUrl") and
//   callable.hasName("getData") and
//   m = andComp.getAMethod() and
//   m.calls(callable)
// //andComp.getAMethod().calls(callable)
// select m, "This component is reachable through a deeplink."
// * select getData() method access in RouterActivity
from AndroidComponent andComp, MethodAccess ma
where
  andComp
      .getAndroidComponentXmlElement()
      .getAnIntentFilterElement()
      .getAnActionElement()
      .getActionName() = "android.intent.action.VIEW" and
  andComp
      .getAndroidComponentXmlElement()
      .getAnIntentFilterElement()
      .getACategoryElement()
      .getCategoryName() = "android.intent.category.BROWSABLE" and
  andComp
      .getAndroidComponentXmlElement()
      .getAnIntentFilterElement()
      .getACategoryElement()
      .getCategoryName() = "android.intent.category.DEFAULT" and
  andComp
      .getAndroidComponentXmlElement()
      .getAnIntentFilterElement()
      .getAChild("data")
      .hasAttribute("scheme") and // make sure to check for 'android' prefix in real query
  ma.getMethod().hasName("getData") and
  //ma.getCompilationUnit().toString() = andComp.toString() // string is "RouterActivity"
  // andComp.getPackage() gives "org.schabi.newpipe"; andComp.getFile().getBaseName() gives "RouterActivity.java"
  // andComp.getName() gives "RouterActivity"; andComp.getQualifiedName() gives org.schabi.newpipe.RouterActivity
  // andComp.getPrimaryQlClasses() gives "Class"; andComp.getSourceDeclaration() gives link to "RouterActivity" in file
  // ma.getControlFlowNode() links to getData(...) calls; ma.getFile().getBaseName() gives "RouterActivity.java"
  andComp.getFile() = ma.getFile() // ? best way to check this? see options above...
select ma, "getData usage related to deeplink"
