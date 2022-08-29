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

// from AndroidComponentXmlElement compXmlElement
// where
//   //exists(compElement.getAnIntentFilterElement()) and // has an intent filter - below all show that it has an intent-filter, duplicates work
//   compXmlElement.getAnIntentFilterElement().getAnActionElement().getActionName() =
//     "android.intent.action.VIEW" and
//   compXmlElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.BROWSABLE" and
//   compXmlElement.getAnIntentFilterElement().getACategoryElement().getCategoryName() =
//     "android.intent.category.DEFAULT" and
//   compXmlElement.getAnIntentFilterElement().getAChild("data").hasAttribute("scheme") and // make sure to check for 'android' prefix in real query
//   not compXmlElement.getFile().(AndroidManifestXmlFile).isInBuildDirectory()
// select compXmlElement, "A deeplink is used here."
// * with AndroidManifest.qll predicate instead
from AndroidActivityXmlElement actXmlElement
where
  actXmlElement.hasDeepLink() and
  not actXmlElement.getFile().(AndroidManifestXmlFile).isInBuildDirectory()
select actXmlElement, "A deeplink is used here."
