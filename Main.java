public class Main {

	public static void main(String[] args) {
		TreeBuilder tb = new TreeBuilder( "C:\\Users\\Lallu Anthoor\\workspace\\Compiler Design\\src\\nodes.ser" );
		tb.createSkeleton();
		tb.processGoto();
		tb.processIf();
		Node root = tb.writeObject( "CFG.ser" );
	}
}