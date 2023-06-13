import java
import experimental.heuristics.Heuristics

from
  Callable callable, string sinkKind, string proposedSink, string existingSink, string paramType,
  string paramName
where
  sinkKind = "path-injection" and
  proposedSink =
    getAVulnerableParameterSpecification(callable, existingSink, sinkKind, paramType, paramName)
select proposedSink, paramType, paramName, callable, existingSink order by proposedSink
