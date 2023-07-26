import java
private import semmle.code.java.dataflow.ExternalFlow // for `paramsString`

// /**
//  * A MaD model added in https://github.com/github/codeql/pull/13403
//  * represented as a string of its qualified name and signature.
//  */
// class Tr153ModelsString extends string {
//   Tr153ModelsString() {
//     this =
//       [
//         // Correct Sinks (path-injection, request-forgery)
//         "java.io.File.createNewFile#()", "java.nio.channels.FileChannel.open#(Path,OpenOption[])",
//         "java.nio.channels.FileChannel.open#(Path,Set,FileAttribute[])",
//         "java.nio.file.FileSystems.newFileSystem#(URI,Map)",
//         // Incorrect Sinks (file-content-store)
//         "java.nio.channels.FileChannel.write#(ByteBuffer,long)",
//         "java.nio.channels.FileChannel.write#(ByteBuffer)",
//         "java.util.zip.ZipOutputStream.putNextEntry#(ZipEntry)",
//         // Summaries
//         "java.lang.ProcessBuilder.environment#()", "java.net.URL.getFile#()",
//         "java.net.URL.getPath#()", "java.nio.file.Path.resolveSibling#(String)",
//         "java.util.zip.ZipEntry.ZipEntry#(String)", "okhttp3.Request$Builder.get#()",
//         "okhttp3.Request$Builder.url#(String)", "org.gradle.api.file.Directory.getAsFile#()",
//         "org.gradle.api.file.DirectoryProperty.file#(String)",
//         "retrofit2.Retrofit$Builder.baseUrl#(String)"
//       ]
//   }
// }
// from Call call, Callable callable, string qualifiedNameWithSignature
// where
//   // exclude test directories since alerts there are not interesting
//   not call.getFile().getRelativePath().matches("%/test/%") and
//   call.getCallee() = callable and
//   qualifiedNameWithSignature = callable.getQualifiedName() + "#" + paramsString(callable) and
//   qualifiedNameWithSignature instanceof Tr153ModelsString
// select call, qualifiedNameWithSignature
// //callable.getStringSignature() // returns `open(Path, OpenOption[])`, etc.
/** A MaD model added in https://github.com/github/codeql/pull/13403. */
private class Tr153Model extends Callable {
  Tr153Model() {
    exists(string qualifiedNameWithSignature |
      qualifiedNameWithSignature = this.getQualifiedName() + "#" + paramsString(this) and
      qualifiedNameWithSignature =
        [
          // Correct Sinks (path-injection, request-forgery)
          "java.io.File.createNewFile#()", //
          "java.nio.channels.FileChannel.open#(Path,OpenOption[])", //
          "java.nio.channels.FileChannel.open#(Path,Set,FileAttribute[])", //
          "java.nio.file.FileSystems.newFileSystem#(URI,Map)", //
          // Incorrect Sinks (file-content-store)
          "java.nio.channels.FileChannel.write#(ByteBuffer,long)", //
          "java.nio.channels.FileChannel.write#(ByteBuffer)", //
          "java.util.zip.ZipOutputStream.putNextEntry#(ZipEntry)", //
          // Summaries
          "java.lang.ProcessBuilder.environment#()", //
          "java.net.URL.getFile#()", //
          "java.net.URL.getPath#()", //
          "java.nio.file.Path.resolveSibling#(String)", //
          "java.util.zip.ZipEntry.ZipEntry#(String)", //
          "okhttp3.Request$Builder.get#()", //
          "okhttp3.Request$Builder.url#(String)", //
          "org.gradle.api.file.Directory.getAsFile#()", //
          "org.gradle.api.file.DirectoryProperty.file#(String)", //
          "retrofit2.Retrofit$Builder.baseUrl#(String)"
        ]
    )
  }
}

// from Call call, Tr153Model callable
// where
//   // exclude test directories since alerts there are not interesting
//   not call.getFile().getRelativePath().matches("%/test/%") and
//   call.getCallee() = callable
// select call, callable.getQualifiedName() + "#" + paramsString(callable)
from Call call
where
  // exclude test directories since alerts there are not interesting
  not call.getFile().getRelativePath().matches("%/test/%") and
  call.getCallee() instanceof Tr153Model
select call
