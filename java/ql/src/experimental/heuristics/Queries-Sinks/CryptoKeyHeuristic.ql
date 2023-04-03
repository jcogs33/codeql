import java
import experimental.heuristics.Heuristics

from Callable callable, string sinkKind, string proposedSink, string existingSink
where
  sinkKind = "cryptoKey" and
  proposedSink = getAVulnerableParameterSpecification(callable, existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
