import java
import Heuristics

// * update below to adjust heuristic
bindingset[paramName]
predicate sqlHeuristic(string paramName, string paramType) {
  paramName.matches(["file", "fd", "fdObj", "out", "dir", "link", "path", "fileName"]) and // ! left out "sink", "name", "target", and "prefix" for now; this will prbably be FP-prone as-is.
  paramType = "String" // instanceof TypeString // ! need to fix this
}

// * update below to adjust what sink kind you're looking for
string getSinkKind() { result = "create-file" }

from
  Callable callable, string sinkKind, string paramName, string paramType, string proposedSink,
  string existingSink
where
  sinkKind = getSinkKind() and
  sqlHeuristic(paramName, paramType) and
  proposedSink =
    getAVulnerableParameterSpecification(callable, paramName, paramType, existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
