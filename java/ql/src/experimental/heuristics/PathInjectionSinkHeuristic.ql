import java
import Heuristics

from Callable callable, string sinkKind, string proposedSink, string existingSink
where
  sinkKind = "create-file" and
  proposedSink = getAVulnerableParameterSpecification(callable, existingSink, sinkKind)
select proposedSink, callable, existingSink order by proposedSink
