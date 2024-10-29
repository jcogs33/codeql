import java
private import semmle.code.java.frameworks.spring.SpringController
private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.TaintTracking
private import semmle.code.java.dataflow.FlowSources
private import semmle.code.java.security.QueryInjection

abstract class CsrfUnprotectedMethod extends Method { }

// https://docs.spring.io/spring-security/reference/features/exploits/csrf.html#csrf-protection-read-only
private class SpringCsrfUnprotectedMethod extends CsrfUnprotectedMethod instanceof SpringRequestMappingMethod
{
  SpringCsrfUnprotectedMethod() {
    this.hasAnnotation("org.springframework.web.bind.annotation", "GetMapping")
    or
    this.hasAnnotation("org.springframework.web.bind.annotation", "RequestMapping") and
    (
      // TODO: confirm below works sufficiently and maybe add getMethod using below to SpringController.qll similarly to the existing getProduces?
      // TODO: example cases to test : @RequestMapping(value = "", method = RequestMethod.POST), method = { POST, PUT, PATCH }, method = POST, method = { RequestMethod.GET, RequestMethod.POST } etc.
      // TODO: edge case?, need to handle io.swagger.v3.oas.annotations.Operation with Spring? See https://github.com/Tencent/spring-cloud-tencent/blob/c5f318d1d01ef8a3a4a857d8941dbcde6decf8b8/spring-cloud-tencent-examples/tsf-example/provider-demo/src/main/java/com/tencent/cloud/tsf/demo/provider/swagger/controller/SwaggerApiController.java#L126-L143.
      this.getAnAnnotation().getAnEnumConstantArrayValue("method").getName() =
        ["GET", "HEAD", "OPTIONS", "TRACE"]
      or
      // if no request type specified with `@RequestMapping`, then all request types are possible, so treat as unsafe
      // example: @RequestMapping(value = "test")
      not exists(this.getAnAnnotation().getAnArrayValue("method"))
    )
  }
}

/**
 * see below from docs: https://docs.jenkins.io/dev-docs/handling-requests/actions.html
 * Web methods need to provide some indication that they are intended for Stapler routing:
 * - Any applicable annotation recognized by Stapler, e.g., @RequirePOST.
 * - Any inferable parameter type, e.g., StaplerRequest.
 * - Any applicable parameter annotation, recognized by Stapler, e.g., @AncestorInPath.
 * - Any declared exception type implementing HttpResponse, e.g., HttpResponseException.
 * - A return type implementing HttpResponse.
 */
// TODO: finish/refine implementation and add to Stapler.qll
private class StaplerWebRequestMethod extends Method {
  StaplerWebRequestMethod() {
    // Any applicable annotation recognized by Stapler, e.g., @RequirePOST
    this.hasAnnotation("org.kohsuke.stapler", "WebMethod")
    or
    this.hasAnnotation("org.kohsuke.stapler.interceptor", _) // RequirePOST
    or
    this.hasAnnotation("org.kohsuke.stapler.verb", _) // POST, GET, PUT, DELETE
    or
    // Any inferable parameter type, e.g., StaplerRequest
    // Also https://javadoc.jenkins.io/component/stapler/org/kohsuke/stapler/WebMethodContext.html?
    this.getAParamType()
        .(RefType)
        .hasQualifiedName("org.kohsuke.stapler", ["StaplerRequest", "StaplerRequest2"])
    or
    // Any applicable parameter annotation, recognized by Stapler, e.g., @AncestorInPath
    this.getAParameter().hasAnnotation("org.kohsuke.stapler", ["AncestorInPath", "QueryParameter"])
    or
    // Any declared exception type implementing HttpResponse, e.g., HttpResponseException
    this.getAParameter().hasAnnotation("org.kohsuke.stapler", "HttpResponses.HttpResponseException")
    or
    // A return type implementing HttpResponse
    exists(StaplerHttpResponse httpResponse |
      this.getReturnType().(RefType).extendsOrImplements(httpResponse)
    )
  }
}

// TODO: move to Stapler.qll file
private class StaplerHttpResponse extends Interface {
  StaplerHttpResponse() { this.hasQualifiedName("org.kohsuke.stapler", "HttpResponse") }
}

// docs: https://docs.jenkins.io/dev-docs/security/form-validation.html#_protecting_from_csrf
// TODO: may need to support `checkMethod="post"` for older versions on Jenkins?
// private class StaplerCsrfUnprotectedMethod extends CsrfUnprotectedMethod instanceof StaplerWebRequestMethod
// {
//   StaplerCsrfUnprotectedMethod() {
//     not (
//       // TODO: check if need to handle RequirePOST.ErrorCustomizer and RequirePOST.Processor nested classes explicitly?
//       this.hasAnnotation("org.kohsuke.stapler.interceptor", "RequirePOST") or
//       this.hasAnnotation("org.kohsuke.stapler.verb", "POST")
//     )
//   }
// }
/**
 * A method whose name indicates that it may change the application's state.
 *
 * ! Testing results from a broad heuristic !
 */
class StateChangingMethod extends Method {
  StateChangingMethod() {
    this.getName()
        .regexpMatch(".*(?i)(post|put|patch|delete|remove|create|add|update|edit|publish|unpublish|fill|move|transfer|log(out|in)|access|connect|register|submit|den(y|ied)).*")
  } // TODO: consider opposite of above?, i.e. look for anything except "show", "get", "view", "list", "query", "find", etc.?
  // TODO: note FP from `alibaba/nacos`: getPublishedClientList, should maybe always exclude methods starting with "get", etc.?
  // TODO: connect a FP usually? review https://github.com/WeBankFinTech/DataSphereStudio/blob/f8732934448379ba8be383fc1196d0648a6c6661/dss-apps/dss-data-api/dss-data-api-server/src/main/java/com/webank/wedatasphere/dss/data/api/server/restful/DSSDbApiDataSourceRestful.java#L34, etc.
  // TODO: "pay" as well?
  // TODO: maybe use login/out, etc. _with_ more complex heuristic?
}

// MRVA FP Notes: (at least exclude any that start with get/query/list/)
// - xuxueli/xxl-job: toLogin (looks like probably not the actual login since there's a doLogin POST)
// - alibaba/nacos: get[Publish]edClientList, get[Publish]edServiceList
// - Tencent/spring-cloud-tencent: queryMessageBox[Add]ress
// - shopizer-ecommerce/shopizer: exp[edit]ion
// - gocd/gocd: redirectToThirdParty[Login]Page (or is redirect interesting?)
// - gchq/Gaffer: getGraph[Create]dTime
// - pig-mesh/pig: getSys[Post]Page and list[Post]s
// - mitreid-connect/OpenID-Connect-Java-Spring-Server: confirm[Access], get[Access]TokensByClientId, get[Access]TokenById, getAll[Access]Tokens
// - DSpace/DSpace: getFilter[edIt]ems
// - WeBankFinTech/DataSphereStudio: getHiveTbl[Create]--TP actually since does create table if not exist; get[Login]UserInfo
// - ityouknow/spring-boot-examples: toEdit?, toAdd?
// - erupts/erupt: code[Edit]Hints (//Gets the CodeEdit component hint data)
// - dataease/dataease: proxyUser[Login]Info, user[Login]Info, callBackWithoutLogin?
// - apolloconfig/apollo: findDeletedItems?, namespacePublishInfo?, getNamespacesPublishInfo, hasCreateApplicationPermission, getCreateApplicationRoleUsers
// - PowerJob/PowerJob: ifLogin?, loginCallback?, getThirdPartyLoginUrl?, listSupportLoginTypes?, checkConnectivity?, getSystemOverview?
// - jenkinsci/github-plugin (Stapler since Jenkins?!): doCheckHookRegistered?, ...
// *****
// MRVA Database, etc. notes:
// - alibaba/Sentinel: saves in memory (ConcurrentHashMap, Iterator, etc.) instead of using database
// - apache/incubator-seata:
//    - saves in memory (HashMap), then saves string representation of that HashMap in file
//    - OR saves in DB (String sql = "INSERT INTO with ps.setString->ps.executeUpdate() and String sql = "DELETE FROM  with ps.setString->ps.executeUpdate()): java(x).sql
//    - or in NoSQL Redis (jedis.hset/jedis.hdel): redis.clients.jedis.Jedis, org.apache.seata.server.storage.redis.JedisPooledFactory
// - apache/inlong:
//    - logout: uses org.apache.shiro.SecurityUtils, org.apache.shiro.subject.Subject to handle the state change:  SecurityUtils.getSubject().logout();
//    - delete: uses @Repository+@MapperScan Spring annotation to map to mybatis DB: https://github.com/apache/inlong/blob/15ae01a6eb88777d2538e46245a626ce65c7626f/inlong-manager/manager-dao/src/main/resources/mappers/InlongTenantEntityMapper.xml#L151
// - WeBankFinTech/DataSphereStudio:
//    - apiDelete: mybatis Mapper xml: https://github.com/WeBankFinTech/DataSphereStudio/blob/f8732934448379ba8be383fc1196d0648a6c6661/dss-apps/dss-apiservice-server/src/main/java/com/webank/wedatasphere/dss/apiservice/core/dao/mapper/ApiServiceMapper.xml#L18
// macrozheng/mall:
//    - delete: mybatis Mapper xml
// apache/shenyu:
//    - delete: HashMap it seems
// *** Complex Heuristic Experimentation ***
// /**
//  * A taint-tracking configuration for unvalidated user input that is used in SQL queries.
//  */
// module TestFlowConfig implements DataFlow::ConfigSig {
//   predicate isSource(DataFlow::Node src) {
//     src instanceof ActiveThreatModelSource and
//     src.getEnclosingCallable() instanceof CsrfUnprotectedMethod
//   }
//   predicate isSink(DataFlow::Node sink) { sink instanceof QueryInjectionSink }
// }
// /** Tracks flow of unvalidated user input that is used in SQL queries. */
// module TestFlow = TaintTracking::Global<TestFlowConfig>;
private import semmle.code.java.frameworks.MyBatis

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

private import semmle.code.java.dataflow.ExternalFlow

//private import semmle.code.java.dataflow.FlowSinks
// ! seems potentially too slow after adding this, got stuck on the edges predicate briefly, query results stuck and not displaying... :(, oh 247 results.... Webview is disposed error
// ! Gave method calls that not called from starting method.... might need help understanding virtual dispatch, edges, polyCalls, etc.
// ! why not getting paths longer than two? Am I trying to force too much with path between different types? (Method to MethodCall versus Method to Method)
class JavaSqlExecuteMethodCall extends DatabaseUpdateMethodCall {
  JavaSqlExecuteMethodCall() {
    // TODO: narrow down to only insert/update/delete; need to track the sql expression into the execute call...
    exists(Method m | m = this.getMethod() |
      m.getDeclaringType().hasQualifiedName("java.sql", "PreparedStatement") and
      m.getName().matches("executeUpdate") // TODO: "execute%" when above TODO is handled...
    )
  }
}

// module MyFlowConfiguration implements DataFlow::ConfigSig {
//   predicate isSource(DataFlow::Node source) {
//     exists(StringLiteral sl | sl = source.asExpr() | sl.toString().matches("%DELETE%"))
//   }
//   predicate isSink(DataFlow::Node sink) { sinkNode(sink, "sql-injection") }
// }
// module MyFlow = TaintTracking::Global<MyFlowConfiguration>;
class JavaSqlInjectionMethodCall extends DatabaseUpdateMethodCall {
  JavaSqlInjectionMethodCall() {
    // TODO: narrow down to only insert/update/delete; need to track the sql expression into the execute call...; barrier or exclusion?
    // TODO:   exists a StringLiteral (and Variable? depending where SQL first gets set up...) such that taint from string literal flows to DatabaseUpdateMethodCall
    // TODO    and StringLiteral contains/startsWith DELETE, UPDATE, INSERT, etc.
    exists(DataFlow::Node n |
      this = n.asExpr().(Argument).getCall() // Note: getCall _does_ include constructor calls, so works for SqlUpdate, etc.
    |
      sinkNode(n, "sql-injection") and
      this.getMethod()
          .getName()
          .regexpMatch(".*(?i)(delete|insert|update|save|persist|merge|replicate|execute).*")
    )
  }
}
// TODO: make sure below are fully covered (i.e. modelled as sql-injection sinks and not just something I saw in their docs) (and maybe see Android cleartext local database storage?)
// TODO: ibatis SqlRunner.delete/insert/update
// TODO: hibernate %Session%.save/persist/delete/update/merge/saveOrUpdate/replicate
// TODO: Spring JdbcTemplate/NamedParameterJdbcOperations/BatchSqlUpdate/SqlUpdate/SqlCall?/SqlQuery?, etc.
// TODO: keycloak MapStorage.delete, etc.
