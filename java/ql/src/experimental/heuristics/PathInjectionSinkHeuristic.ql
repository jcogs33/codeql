import java
import Heuristics

from
  Callable callable, string sinkKind, string proposedSink, string existingSink, string paramType,
  string paramName
where
  sinkKind = "create-file" and
  proposedSink =
    getAVulnerableParameterSpecification(callable, existingSink, sinkKind, paramType, paramName)
select proposedSink, paramType, paramName, callable, existingSink order by proposedSink
