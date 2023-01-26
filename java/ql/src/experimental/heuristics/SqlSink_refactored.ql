import java
import semmle.code.java.dataflow.ExternalFlow
import Heuristics

// select getAVulnerableParameterSpecification()
bindingset[paramName]
predicate sqlHeuristic(string sinkKind, string paramName, string paramType) {
  sinkKind = "sql" and // ! kind is problematic with regex% sinks
  paramName.matches(["sql%", "query%"]) and
  paramType = "String" // instanceof TypeString
}

// from
//   Callable callable, int paramIdx, string paramName, string paramType, string sinkKind,
//   string proposedSink, string existingSink
// where
//   paramIdx = 0 and
//   // setup specifics of heuristic
//   sqlHeuristic(sinkKind, paramName, paramType) and
//   // get callable for proposed sink based on heuristics
//   callable = getAVulnerableParameterNameBasedGuess(paramIdx, paramName, paramType) and // ! need to add paramType
//   // construct proposed yml for proposed sink
//   proposedSink = getProposedSink(callable, paramIdx, sinkKind) and
//   // check if proposed sink already exists
//   existingSink = hasExistingSink(callable, paramIdx)
// select proposedSink, callable, existingSink order by existingSink, proposedSink
from
  Callable callable, string sinkKind, string paramName, string paramType, string proposedSink,
  string existingSink
where
  sqlHeuristic(sinkKind, paramName, paramType) and
  proposedSink = getAVulnerableParameterSpecification(callable, paramName, paramType, existingSink)
select proposedSink, callable, existingSink order by existingSink, proposedSink
