/**
 * @kind path-problem
 */

import java
import semmle.code.java.frameworks.spring.SpringController
import semmle.code.xml.MyBatisMapperXML
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.ExternalFlow

abstract class CsrfUnprotectedMethod extends Method { }

private class SpringCsrfUnprotectedMethod extends CsrfUnprotectedMethod instanceof SpringRequestMappingMethod
{
  SpringCsrfUnprotectedMethod() {
    this.hasAnnotation("org.springframework.web.bind.annotation", "GetMapping")
    or
    this.hasAnnotation("org.springframework.web.bind.annotation", "RequestMapping") and
    (
      this.getAnAnnotation().getAnEnumConstantArrayValue("method").getName() =
        ["GET", "HEAD", "OPTIONS", "TRACE"]
      or
      // if no request type specified with `@RequestMapping`, then all request types are possible, so treat as unsafe
      // example: @RequestMapping(value = "test")
      not exists(this.getAnAnnotation().getAnArrayValue("method"))
    )
  }
}

abstract class DatabaseUpdateMethodCall extends MethodCall { }

class MyBatisMapperMethodCall extends DatabaseUpdateMethodCall {
  MyBatisMapperMethodCall() {
    // MyBatis XML Mapper method that updates/inserts/deletes
    exists(MyBatisMapperSqlOperation mapperXml |
      (
        mapperXml instanceof MyBatisMapperInsert or
        mapperXml instanceof MyBatisMapperUpdate or
        mapperXml instanceof MyBatisMapperDelete
      ) and
      this.getMethod() = mapperXml.getMapperMethod()
    )
  }
}

// TODO for Java Sql: narrow down to only insert/update/delete
class JavaSqlExecuteUpdateMethodCall extends DatabaseUpdateMethodCall {
  JavaSqlExecuteUpdateMethodCall() {
    exists(Method m | m = this.getMethod() |
      m.getDeclaringType().hasQualifiedName("java.sql", "PreparedStatement") and
      m.getName().matches("executeUpdate")
    )
  }
}

class JavaSqlInjectionMethodCall extends DatabaseUpdateMethodCall {
  JavaSqlInjectionMethodCall() {
    exists(DataFlow::Node n | this = n.asExpr().(Argument).getCall() |
      sinkNode(n, "sql-injection") and
      this.getMethod()
          .getName()
          .regexpMatch(".*(?i)(delete|insert|update|save|persist|merge|replicate|execute).*")
    )
  }
}

class DatabaseUpdateMethod extends Method {
  DatabaseUpdateMethod() { exists(DatabaseUpdateMethodCall dbumc | this = dbumc.getMethod()) }
}

module CallGraph {
  newtype TPathNode =
    TMethod(Method m) or
    TCall(Call c)

  class PathNode extends TPathNode {
    Method asMethod() { this = TMethod(result) }

    Call asCall() { this = TCall(result) }

    string toString() {
      result = this.asMethod().toString()
      or
      result = this.asCall().toString()
    }

    PathNode getASuccessor() {
      this.asMethod() = result.asCall().getEnclosingCallable()
      or
      this.asCall().getCallee() = result.asMethod()
    }

    Location getLocation() {
      result = this.asMethod().getLocation()
      or
      result = this.asCall().getLocation()
    }
  }

  query predicate edges(PathNode pred, PathNode succ) { pred.getASuccessor() = succ }
}

import CallGraph

from PathNode source, PathNode reachable
where
  source.asMethod() instanceof CsrfUnprotectedMethod and
  reachable.asMethod() instanceof DatabaseUpdateMethod and
  source.asMethod().polyCalls+(reachable.asMethod())
select source.asMethod(), source, reachable, "This method, $@, reaches $@.", source,
  source.asMethod().getName(), reachable.asMethod(), reachable.toString()
