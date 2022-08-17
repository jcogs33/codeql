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
import semmle.code.java.frameworks.android.Android

// select getData() method access in RouterActivity
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
  andComp.getFile() = ma.getFile()
select ma, "getData usage related to deeplink"
