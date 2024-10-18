import java
import semmle.code.java.frameworks.spring.SpringController
import semmle.code.java.dataflow.DataFlow

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
private class StaplerCsrfUnprotectedMethod extends CsrfUnprotectedMethod instanceof StaplerWebRequestMethod
{
  StaplerCsrfUnprotectedMethod() {
    not (
      // TODO: check if need to handle RequirePOST.ErrorCustomizer and RequirePOST.Processor nested classes explicitly?
      this.hasAnnotation("org.kohsuke.stapler.interceptor", "RequirePOST") or
      this.hasAnnotation("org.kohsuke.stapler.verb", "POST")
    )
  }
}

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
}
