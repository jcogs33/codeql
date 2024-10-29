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
//import TestFlow::PathGraph
// simple heuristic:
// from CsrfUnprotectedMethod m //, Annotation a
// where
//   m instanceof StateChangingMethod and
//   // TODO: remove below, temporary exclusion of test/samples dirs for sake of faster MRVA reviewing
//   not m.getFile().getRelativePath().matches(["%/test/%", "%/samples/%"])
// // TODO: make below more precise (i.e. select just the GET method in cases like: @RequestMapping(method = RequestMethod.GET)
// // TODO: and adjust/remove for other frameworks?; Stapler won't have a request type to point to
// // (a = m.getAnAnnotation() and a.toString().matches("%Mapping"))
// select m,
//   "Potential CSRF vulnerability due to using a (request type) which is not default-protected from CSRF for an apparent (state-changing action)."
// *
// complex heursitic - dataflow:
// from TestFlow::PathNode source, TestFlow::PathNode sink
// where TestFlow::flowPath(source, sink)
// select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),
//   "user-provided value"
// *
// complex heursitic - no dataflow:
import semmle.code.xml.MyBatisMapperXML

// query predicate edges(ControlFlowNode a, ControlFlowNode b) {
//   a.(Method).polyCalls*(b.(MethodCall).getEnclosingCallable()) // TODO: ask Chris about better way to do this?
// }
// query predicate edges(Method a, Method b) {
//   a.polyCalls*(b) // doesn't work well if method is from jdk, since then tries to select .class file, e.g. java.sql.Statement.execute%
// }
from CsrfUnprotectedMethod m, DatabaseUpdateMethodCall mc //, Method calledMethod //, MyBatisMapperSqlOperation mapperXml
where
  // * 1
  //   (
  //     mapperXml instanceof MyBatisMapperInsert or
  //     mapperXml instanceof MyBatisMapperUpdate or
  //     mapperXml instanceof MyBatisMapperDelete
  //   ) and
  //   databaseUpdateMethod = mapperXml.getMapperMethod() and
  //   //m = mc.getEnclosingCallable() and
  //   m.polyCalls*(databaseUpdateMethod) //and
  // //mc.getMethod() = databaseUpdateMethod
  // * 2
  //edges+(m, mc)
  // select m, m, mc,
  //   "Potential CSRF vulnerability due to using a (request type) which is not default-protected from CSRF for an apparent $@.",
  //   m, "state-changing action"
  // * 3
  m.polyCalls*(mc.getEnclosingCallable())
select m,
  "Potential CSRF vulnerability due to using a (request type) which is not default-protected from CSRF for an apparent state-changing action."
