/**
 * @name Request type unprotected from CSRF
 * @description Using a request type which is not default-protected from CSRF for a
 *              state-changing action makes the application vulnerable to a Cross-Site
 *              Request Forgery (CSRF) attack.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision low
 * @id java/csrf-unprotected-request-type
 * @tags security
 *       external/cwe/cwe-352
 */

import java
import semmle.code.java.security.CsrfUnprotectedRequestTypeQuery

from CsrfUnprotectedMethod m //, Annotation a
where
  m instanceof StateChangingMethod and
  // TODO: remove below, temporary exclusion of test/samples dirs for sake of faster MRVA reviewing
  not m.getFile().getRelativePath().matches(["%/test/%", "%/samples/%"])
// TODO: make below more precise (i.e. select just the GET method in cases like: @RequestMapping(method = RequestMethod.GET)
// TODO: and adjust/remove for other frameworks?; Stapler won't have a request type to point to
// (a = m.getAnAnnotation() and a.toString().matches("%Mapping"))
select m,
  "Potential CSRF vulnerability due to using a (request type) which is not default-protected from CSRF for an apparent (state-changing action)."
