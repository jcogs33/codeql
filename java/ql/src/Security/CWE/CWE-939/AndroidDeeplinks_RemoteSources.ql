/**
 * @name Android deep links
 * @description Android deep links
 * @kind path-problem
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
from AndroidComponentXmlElement compElement
where
  //exists(compElement.getAnIntentFilterElement()) and // has an intent filter - below all show that it has an intent-filter, duplicates work
  compElement.getAnIntentFilterElement().getAnActionElement().getActionName() =
    "android.intent.action.VIEW" and
  compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
    "android.intent.category.BROWSABLE" and
  compElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
    "android.intent.category.DEFAULT" and
  compElement.getAnIntentFilterElement().getAChild("data").hasAttribute("scheme") // make sure to check for 'android' prefix in real query
select compElement, "A deeplink is used here."
