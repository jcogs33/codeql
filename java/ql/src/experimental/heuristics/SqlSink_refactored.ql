import java
import Heuristics

// * update below to adjust heuristic
// bindingset[paramName]
// predicate sqlHeuristic(string paramName, string paramType) {
//   paramName.matches(["sql%", "query%"]) and // ! initialQuery, etc. -- should maybe be more broad and switch to regexpmatch
//   //paramName = "queryString" and
//   paramType = "String" // instanceof TypeString
// }
// * update below to adjust what sink kind you're looking for
// string getSinkKind() { result = "sql" }
from
  Callable callable, string sinkKind, /*string paramName, string paramType,*/ string proposedSink,
  string existingSink
where
  //sinkKind = getSinkKind() and
  //sqlHeuristic(paramName, paramType) and
  sinkKind = "sql" and
  proposedSink =
    getAVulnerableParameterSpecification(callable, /*paramName, paramType,*/ existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
