import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Iterator;


public class TreeBuilder {
	
	private ArrayList<Node> nodeList;
	
	@SuppressWarnings("unchecked")
	public TreeBuilder( String fileName ) {
		try {
			ObjectInputStream ois;
			ois = new ObjectInputStream( new FileInputStream( fileName ) );
			this.nodeList = (ArrayList<Node>)ois.readObject();
			ois.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	public void createSkeleton() {
		Iterator<Node> iterator = nodeList.iterator();
		Node current, next;
		current = iterator.next();
		while( iterator.hasNext() ) {
			next = iterator.next();
			if( current.getStatementType() != Node.GOTO_INST && current.getStatementType() != Node.RETURN_INST ) {
				if( current.getStatementType() != Node.IF_INST ) {
					current.setCfsTrue( next );
				} else {
					current.setCfsFalse( next );
				}
			}
			current = next;
		}
		iterator = nodeList.iterator();
	}
	
	public void processGoto() {
		for( Node node : nodeList ) {
			if( node.getStatementType() == Node.GOTO_INST ) {
				for( Node n : nodeList ) {
					if( n.getLabel().equals( node.getTarget() ) ) {
						node.setCfsTrue( n );
						break;
					}
				}
			}
		}
	}
	
	public void processIf() {
		for( Node node : nodeList ) {
			if( node.getStatementType() == Node.IF_INST ) {
				for( Node n : nodeList ) {
					if( n.getLabel().equals( node.getTarget() ) ) {
						node.setCfsTrue( n );
						break;
					}
				}
			}
		}
	}
	
	public void print( ) {
		Node node = nodeList.iterator().next();
		display( node );
	}
	
	public void display( Node node ) {
		System.out.println( node.getStatement() );
		if( node.getCfsTrue() != null ) {
			display( node.getCfsTrue() );
		}
		if( node.getCfsFalse() != null ) {
			display( node.getCfsFalse() );
		}
	}
	
	public void printAll() {
		for( Node node : nodeList ) {
			System.out.println( node.getStatement() );
		}
	}
	
	public Node writeObject( String fileName ) {
		Node node = null;
		try {
			node = nodeList.iterator().next();
			ObjectOutputStream oos = new ObjectOutputStream( new FileOutputStream( fileName ) );
			oos.writeObject( node );
			oos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return node;
	}
}
