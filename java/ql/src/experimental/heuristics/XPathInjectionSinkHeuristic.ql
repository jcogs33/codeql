import java
import Heuristics

from Callable callable, string sinkKind, string proposedSink, string existingSink
where
  sinkKind = "xpath" and
  proposedSink = getAVulnerableParameterSpecification(callable, existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
