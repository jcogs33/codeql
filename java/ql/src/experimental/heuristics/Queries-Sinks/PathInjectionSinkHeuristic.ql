import java
import experimental.heuristics.Heuristics

from
  Callable callable, string sinkKind, string proposedSink, string existingSink,
  string existingSummary, string existingSource, string existingNeutral, string paramType,
  string paramName
where
  sinkKind = "path-injection" and
  proposedSink =
    getAVulnerableParameterSpecification(callable, existingSink, existingSummary, existingSource,
      existingNeutral, sinkKind, paramType, paramName)
select proposedSink, paramType, paramName, callable, existingSink, existingSummary, existingSource,
  existingNeutral order by proposedSink
