import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.nio.file.Path;
import java.nio.file.Paths;

public class TaintedPath {
    public void sendUserFile(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // BAD: read from a file without checking its path
        BufferedReader fileReader = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
        String fileLine = fileReader.readLine();
        while (fileLine != null) {
            sock.getOutputStream().write(fileLine.getBytes());
            fileLine = fileReader.readLine();
        }
    }

    public void sendUserFileGood(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // GOOD: ensure that the file is in a designated folder in the user's home directory
        if (!filename.contains("..") && filename.startsWith("/home/" + user + "/public/")) {
            BufferedReader fileReader = new BufferedReader(new FileReader(filename));
            String fileLine = fileReader.readLine();
            while (fileLine != null) {
                sock.getOutputStream().write(fileLine.getBytes());
                fileLine = fileReader.readLine();
            }
        }
    }

    public void sendUserFileGood2(Socket sock, String user) throws Exception {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();

        Path publicFolder = Paths.get("/home/" + user + "/public").normalize().toAbsolutePath();
        Path filePath = publicFolder.resolve(filename).normalize().toAbsolutePath();

        // GOOD: ensure that the path stays within the public folder
        if (!filePath.startsWith(publicFolder + File.separator)) {
            throw new IllegalArgumentException("Invalid filename");
        }
        BufferedReader fileReader = new BufferedReader(new FileReader(filePath.toString()));
        String fileLine = fileReader.readLine();
        while (fileLine != null) {
            sock.getOutputStream().write(fileLine.getBytes());
            fileLine = fileReader.readLine();
        }
    }

    public void sendUserFileGood3(Socket sock, String user) throws Exception {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // GOOD: ensure that the filename has no path separators or parent directory references
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            throw new IllegalArgumentException("Invalid filename");
        }
        BufferedReader fileReader = new BufferedReader(new FileReader(filename));
        String fileLine = fileReader.readLine();
        while (fileLine != null) {
            sock.getOutputStream().write(fileLine.getBytes());
            fileLine = fileReader.readLine();
        }
    }

    public void sendUserFileGood4(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File file = new File(filename);
        String baseName = file.getName();
        // GOOD: only use the final component of the user provided path
        BufferedReader fileReader = new BufferedReader(new FileReader(baseName));
        String fileLine = fileReader.readLine();
        while (fileLine != null) {
            sock.getOutputStream().write(fileLine.getBytes());
            fileLine = fileReader.readLine();
        }
    }

    // Tests for CodeQL Java FP: File constructor and path injection
    /** Pattern requested to cover:
       if (!tainted.contains("..")) {
            File f2 = new File(f1, tainted); // f1 is another File object
            //then do something with f2
        }
     */

    // TODO: requested pattern
    public void sendUserFileGood5(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File f1 = new File("safe/file.txt");
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        // (Need to confirm that the safe prefix `f1` is not tainted if not explicitly checking it?)
        if (!filename.contains("..")) {
            File f2 = new File(f1, filename);
            f2.exists();
        }
    }

    // TODO : Confirm sanitized correct node; sanitize the result of the appending, not the original node, which could still be used later
    public void sendUserFileGood5_2(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File f1 = new File("safe/file.txt");
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..")) {
            BufferedReader fileReader1 = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
            // GOOD since safe prefix
            File f2 = new File(f1, filename);
            f2.exists();

            BufferedReader fileReader2 = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
        }
    }

    // TODO : is this the only case they need handled???
    public void sendUserFileGood6(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File f1 = new File("safe/file.txt");
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..") && f1.getPath().startsWith("safe")) {
            File f2 = new File(f1, filename);
            f2.exists();
        }
    }

    // ALREADY HANLDED AS GOOD
    public void sendUserFileGood7(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File f1 = new File("safe/file.txt");
        File f2 = new File(f1, filename);
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..") && f2.getPath().startsWith("safe")) {
            f2.exists();
        }
    }

    // ALREADY HANLDED AS GOOD
    public void sendUserFileGood7_2(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        File f1 = new File("safe/file.txt");
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..")) {
            File f2 = new File(f1, filename);
            if (f2.getPath().startsWith("safe")) {
                f2.exists();
            }
        }
    }

    // // TODO ?
    // public void sendUserFileGood8(Socket sock, String user) throws IOException {
    //     BufferedReader filenameReader =
    //             new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
    //     String filename = filenameReader.readLine();
    //     File f1 = new File("safe/file.txt");
    //     File f2 = new File(f1, filename);
    //     // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
    //     if (!filename.contains("..")) {
    //         f2.exists();
    //     }
    // }

    // // TODO second...
    // public void sendUserFileGood9(Socket sock, String user) throws IOException {
    //     BufferedReader filenameReader =
    //             new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
    //     String filename = filenameReader.readLine();
    //     String path = "safe/" + filename;
    //     // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
    //     if (!path.contains("..")) {
    //         BufferedReader fileReader = new BufferedReader(new FileReader(path));
    //     }
    // }

    // // TODO : Confirm sanitized correct node; sanitize the result of the appending, not the original node, which could still be used later
    // public void sendUserFileGood9_2(Socket sock, String user) throws IOException {
    //     BufferedReader filenameReader =
    //             new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
    //     String filename = filenameReader.readLine();
    //     String path = "safe/" + filename;
    //     // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
    //     if (!path.contains("..")) {
    //         BufferedReader fileReader = new BufferedReader(new FileReader(path)); // GOOD since safe prefix
    //         BufferedReader fileReader2 = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
    //     }
    // }

    // TODO : Confirm sanitized correct node; sanitize the result of the appending, not the original node, which could still be used later
    public void sendUserFileGood9_3(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();

        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..")) {
            String path = "safe/" + filename;
            BufferedReader fileReader = new BufferedReader(new FileReader(path)); // GOOD since safe prefix
            BufferedReader fileReader2 = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
        }
    }

    // TODO first...
    public void sendUserFileGood10(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        if (!filename.contains("..")) {
            String path = "safe/" + filename;
            BufferedReader fileReader = new BufferedReader(new FileReader(path));
        }
    }

    public void sendUserFileBad(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // BAD: concatenated to a safe prefix, but does not ensure that the path does not contain ".."
        String path = "safe/" + filename; //! TODO: file constructor version as well
        BufferedReader fileReader = new BufferedReader(new FileReader(path));  // $ hasTaintFlow
    }

    // TODO: normalize test with strings append
    public void sendUserFileGood11(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        //Path publicFolder = Paths.get("/home/" + user + "/public").normalize().toAbsolutePath();
        Path normalizedFilename = Paths.get(filename).normalize().toAbsolutePath();
        String normalizedFilenameStr = normalizedFilename.toString();
        String finalPath = "safe/" + normalizedFilenameStr;
        BufferedReader fileReader = new BufferedReader(new FileReader(finalPath));

        // confirm these are still alerts, i.e. only sanitize the normalized path when appended to safe prefix
        BufferedReader fileReader2 = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
        BufferedReader fileReader3 = new BufferedReader(new FileReader(normalizedFilenameStr)); // $ hasTaintFlow
    }

    // TODO: normalize test with File constructor
    public void sendUserFileGood12(Socket sock, String user) throws IOException {
        BufferedReader filenameReader =
                new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
        String filename = filenameReader.readLine();
        // GOOD: ensure that the path does not contain ".." and is concatenated to a safe prefix
        //Path publicFolder = Paths.get("/home/" + user + "/public").normalize().toAbsolutePath();
        Path normalizedFilename = Paths.get(filename).normalize().toAbsolutePath();
        String normalizedFilenameStr = normalizedFilename.toString();

        File f1 = new File("safe/file.txt");
        File f2 = new File(f1, normalizedFilenameStr);
        f2.exists(); // GOOD

        // confirm these are still alert, i.e. only sanitize the normalized path when 2nd arg of File Constructor
        BufferedReader fileReader = new BufferedReader(new FileReader(filename)); // $ hasTaintFlow
        BufferedReader fileReader2 = new BufferedReader(new FileReader(normalizedFilenameStr)); // $ hasTaintFlow
    }
}
