import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;

public class Writer {
	private File f;
	private FileOutputStream fos;
	private PrintWriter pw;

	public Writer(String fileName) {
		try {
			f = new File(fileName);
			if (!f.exists()) {
				f.createNewFile();
			}
			fos = new FileOutputStream(f);
			pw = new PrintWriter(fos);
		} catch (FileNotFoundException fnfe) {
			fnfe.printStackTrace();
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	public void writeContent(String content) {
		pw.println(content);
		pw.flush();
	}

	public void closeWriter() {
		pw.close();
		try {
			fos.close();
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	public void writeObject(ArrayList<Node> nodes, String fileName) {
		try {
			ObjectOutputStream oos = new ObjectOutputStream(
					new FileOutputStream(fileName));
			oos.writeObject(nodes);
			oos.flush();
			oos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}
}
