import java
private import semmle.code.java.dataflow.ExternalFlow // for `paramsString`

// Models added in https://github.com/github/codeql/pull/13403
// ? Were all of the 5 sinks below correctly classified by the ML model? Or are we giving the ML model more credit than it deserves?
// ? Partial Answer: first three were at least (https://github.com/github/CodeML/issues/153#issuecomment-1582196580), not sure about the`FileSystems` one(s)
// * Sinks:
// * - ["java.io", "File", True, "createNewFile", "()", "", "Argument[this]", "path-injection", "ai-manual"]
// * - ["java.nio.channels", "FileChannel", False, "open", "(Path,OpenOption[])", "", "Argument[0]", "path-injection", "ai-manual"]
// * - ["java.nio.channels", "FileChannel", False, "open", "(Path,Set,FileAttribute[])", "", "Argument[0]", "path-injection", "ai-manual"]
// * - ["java.nio.file", "FileSystems", False, "newFileSystem", "(URI,Map)", "", "Argument[0]", "path-injection", "ai-manual"]
// * - ["java.nio.file", "FileSystems", False, "newFileSystem", "(URI,Map)", "", "Argument[0]", "request-forgery", "ai-manual"] // ! not suggested for this kind by ML...
// ! Confirm okay with non-disjoint sink kinds....
// Sinks, but ML should not have been classifying "file-content-store", we're doing that manually...
// - ["java.nio.channels", "FileChannel", True, "write", "(ByteBuffer,long)", "", "Argument[0]", "file-content-store", "ai-manual"]
// - ["java.nio.channels", "FileChannel", True, "write", "(ByteBuffer)", "", "Argument[0]", "file-content-store", "ai-manual"]
// - ["java.util.zip", "ZipOutputStream", True, "putNextEntry", "(ZipEntry)", "", "Argument[0]", "file-content-store", "ai-manual"]
// Steps, manually created from model's incorrect predictions:
// - ["java.lang", "ProcessBuilder", False, "environment", "()", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"]
// - ["java.net", "URL", False, "getFile", "()", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"]
// - ["java.net", "URL", False, "getPath", "()", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"]
// - ["java.nio.file", "Path", True, "resolveSibling", "(String)", "", "Argument[0]", "ReturnValue", "taint", "ai-manual"]
// - ["java.util.zip", "ZipEntry", True, "ZipEntry", "(String)", "", "Argument[0]", "ReturnValue", "taint", "ai-manual"]
// - ["okhttp3", "Request$Builder", False, "get", "()", "", "Argument[this]", "ReturnValue", "value", "ai-manual"]
// - ["okhttp3", "Request$Builder", False, "url", "(String)", "", "Argument[this]", "ReturnValue", "value", "ai-manual"]
// - ["org.gradle.api.file", "Directory", True, "getAsFile", "()", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"]
// - ["org.gradle.api.file", "DirectoryProperty", True, "file", "(String)", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"]
// - ["retrofit2", "Retrofit$Builder", False, "baseUrl", "(String)", "", "Argument[this]", "ReturnValue", "taint", "ai-manual"] // maybe just a sink instead
from Call call, Callable callable, string signature
where
  // exclude test directories since alerts there are not interesting
  not call.getFile().getRelativePath().matches("%/test/%") and
  call.getCallee() = callable and
  signature = paramsString(callable) and
  (
    callable.hasQualifiedName("java.io", "File", "createNewFile") and signature = "()"
    or
    callable.hasQualifiedName("java.nio.channels", "FileChannel", "open") and
    signature = ["(Path,OpenOption[])", "(Path,Set,FileAttribute[])"]
    or
    callable.hasQualifiedName("java.nio.file", "FileSystems", "newFileSystem") and
    signature = "(URI,Map)"
  )
select call, callable.getQualifiedName() + "#" + signature
// DONE - ! Note: just finding based on qualified name for now, should Maybe be more precise and include signature?
// DONE - ! Also exclude test directories...
// TODOs:
//// (1): just "correct" sink types without signatures and without %/test/% exclusion --- DON'T USE
// todo (2): just "correct" sink types WITH signatures and WITH %/test/% exclusion --- USE THIS ONE
//// (3): ALL models without signatures --- DON'T USE, SIGNATURES ARE MORE PRECISE, THEREFORE BETTER FOR THIS
// todo (4): ALL models WITH signatures and WITH %/test/% exclusion
// todo possibly (5): all SINKS but no summaries WITH signatures and WITH %/test/% exclusion
