/**
 * @name Request type potentially vulnerable to CSRF
 * @description Using a request type which is not default-protected from CSRF for a
 *              state-changing action makes the application vulnerable to a Cross-Site
 *              Request Forgery (CSRF) attack.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision low
 * @id java/csrf-maybe-unprotected-request-type
 * @tags security
 *       external/cwe/cwe-352
 */

import java
import semmle.code.java.security.CsrfUnprotectedRequestTypeQuery

from CsrfUnprotectedMethod m
where
  m instanceof StateChangingMethod and
  // TODO: remove below, temporary exclusion of test/samples dirs for sake of faster MRVA reviewing
  not m.getFile().getRelativePath().matches(["%/test/%", "%/samples/%"])
select m,
  "Potential CSRF vulnerability due to using a request type which is not default-protected from CSRF for an apparent state-changing action."
