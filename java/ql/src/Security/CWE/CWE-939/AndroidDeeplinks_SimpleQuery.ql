/**
 * @name Android deep links
 * @description Android deep links
 * @kind problem
 * @problem.severity recommendation
 * @security-severity 0.1
 * @id java/android/deeplinks
 * @tags security
 *       external/cwe/cwe-939
 * @precision high
 */

import java
import semmle.code.xml.AndroidManifest

// selects entire component
// from AndroidComponentXmlElement compElement
// where
//   //exists(compElement.getAnIntentFilterElement()) and // has an intent filter - below all show that it has an intent-filter, duplciates work
//   compElement.getAnIntentFilterElement().getAnActionElement().getActionName() =
//     "android.intent.action.VIEW" and
//   compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.BROWSABLE" and
//   compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.DEFAULT" and
//   compElement.getAnIntentFilterElement().getAChild("data").hasAttribute("scheme") // make sure to check for 'android' prefix in real query
// select compElement, "A deeplink is used here."
//selects just the intent-filter -- Note: this causes a LOT of results since there may be multiple intent
// filters that are deeplinks in the same component, prbly better to just select the component instead as a result.
from AndroidIntentFilterXmlElement intentFilterElement
where
  intentFilterElement.getAnActionElement().getActionName() = "android.intent.action.VIEW" and
  intentFilterElement.getACategoryElement().getCategoryName() = "android.intent.category.BROWSABLE" and
  intentFilterElement.getACategoryElement().getCategoryName() = "android.intent.category.DEFAULT" and
  intentFilterElement.getAChild("data").hasAttribute("scheme") // make sure to check for 'android' prefix in real query
select intentFilterElement, "A deeplink is used here."
