import java
import Heuristics

// * update below to adjust heuristic
bindingset[paramName]
predicate sqlHeuristic(string paramName, string paramType) {
  paramName.matches(["regex"]) and
  paramType = "String" // instanceof TypeString // ! change/remove this?
}

// * update below to adjust what sink kind you're looking for
string getSinkKind() {
  result = "regex" // ! kind may be problematic with regex% sinks
}

from
  Callable callable, string sinkKind, string paramName, string paramType, string proposedSink,
  string existingSink
where
  sinkKind = getSinkKind() and
  sqlHeuristic(paramName, paramType) and
  proposedSink =
    getAVulnerableParameterSpecification(callable, paramName, paramType, existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
