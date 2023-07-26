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
    // Sinks (path-injection, request-forgery)
    callable.hasQualifiedName("java.io", "File", "createNewFile") and signature = "()"
    or
    callable.hasQualifiedName("java.nio.channels", "FileChannel", "open") and
    signature = ["(Path,OpenOption[])", "(Path,Set,FileAttribute[])"]
    or
    callable.hasQualifiedName("java.nio.file", "FileSystems", "newFileSystem") and
    signature = "(URI,Map)"
    or
    // Sinks (file-content-store)
    callable.hasQualifiedName("java.nio.channels", "FileChannel", "write") and
    signature = ["(ByteBuffer,long)", "(ByteBuffer)"]
    or
    callable.hasQualifiedName("java.util.zip", "ZipOutputStream", "putNextEntry") and
    signature = "(ZipEntry)"
    or
    // Summaries
    callable.hasQualifiedName("java.lang", "ProcessBuilder", "environment") and
    signature = "()"
    or
    callable.hasQualifiedName("java.net", "URL", "getFile") and
    signature = "()"
    or
    callable.hasQualifiedName("java.net", "URL", "getPath") and
    signature = "()"
    or
    callable.hasQualifiedName("java.nio.file", "Path", "resolveSibling") and
    signature = "(String)"
    or
    callable.hasQualifiedName("java.util.zip", "ZipEntry", "ZipEntry") and
    signature = "(String)"
    or
    // ! confirm the nested type ones are properly formatted for what `hasQualifiedName` expects
    callable.hasQualifiedName("okhttp3", "Request$Builder", "get") and
    signature = "()"
    or
    callable.hasQualifiedName("okhttp3", "Request$Builder", "url") and
    signature = "(String)"
    or
    callable.hasQualifiedName("org.gradle.api.file", "Directory", "getAsFile") and
    signature = "()"
    or
    callable.hasQualifiedName("org.gradle.api.file", "DirectoryProperty", "file") and
    signature = "(String)"
    or
    callable.hasQualifiedName("retrofit2", "Retrofit$Builder", "baseUrl") and
    signature = "(String)"
  )
select call, callable.getQualifiedName() + "#" + signature
//callable.getStringSignature() // returns `open(Path, OpenOption[])`, etc.
