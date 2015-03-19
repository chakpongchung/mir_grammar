import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;

public class Node implements Serializable {

	private static final long serialVersionUID = 8246934031841754264L;

	public static final int ROOT = 0, PROC_NAME = 1, BEGIN = 2, RECEIVE_INST = 3,
			ASSIGN_INST = 4, GOTO_INST = 5, IF_INST = 6, CALL_INST = 7,
			RETURN_INST = 8, SEQUENCE_INST = 9, END = 10;

	private String statement;
	private int statementType;
	private String label;
	private int statementNumber;
	private boolean leader;
	private ArrayList<Information> details;
	private Node cfsTrue;
	private Node cfsFalse;

	public Node(String statement, int type, String label, int statementNumber ) {
		this.statement = statement;
		this.statementType = type;
		this.label = label;
		this.statementNumber = statementNumber;
		this.leader = false;
		this.details = new ArrayList<>();
		this.cfsTrue = null;
		this.cfsFalse = null;
		if( this.statementType == Node.GOTO_INST ) {
			processTarget();
		} else if( this.statementType == Node.IF_INST ) {
			processIfTarget();
		}
	}

	public String getStatement() {
		return statement;
	}

	public void setStatement(String statement) {
		this.statement = statement;
	}

	public int getStatementType() {
		return statementType;
	}

	public void setStatementType(int statementType) {
		this.statementType = statementType;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}
	
	public void setStatementNumber( int statementNumber ) {
		this.statementNumber = statementNumber;
	}
	
	public int getStatementNumber() {
		return this.statementNumber;
	}

	public void setLeader(boolean leader) {
		this.leader = leader;
	}

	public boolean isLeader() {
		return this.leader;
	}

	public Node getCfsTrue() {
		return cfsTrue;
	}

	public void setCfsTrue(Node cfsTrue) {
		this.cfsTrue = cfsTrue;
	}

	public Node getCfsFalse() {
		return cfsFalse;
	}

	public void setCfsFalse(Node cfsFalse) {
		this.cfsFalse = cfsFalse;
	}

	public boolean addInformation(Information info) {
		return details.add(info);
	}

	public boolean isInformationEmpty() {
		return details.isEmpty();
	}

	public Iterator<Information> informationIterator() {
		return details.iterator();
	}

	public boolean removeInformation(Information info) {
		return details.remove(info);
	}

	public int informationSize() {
		return details.size();
	}

	public boolean hasInformation(String name) {
		for (Information inf : details) {
			if (inf.getInfoName().equals(name)) {
				return true;
			}
		}
		return false;
	}

	public String getInformation(String name) {
		for (Information inf : details) {
			if (inf.getInfoName().equals(name)) {
				return inf.getInfoValue();
			}
		}
		return null;
	}
	
	public void processTarget() {
		String stmt = getStatement();
		String[] components = stmt.split( " " );
		this.addInformation( new Information( "TARGET", components[1] ) );
	}
	
	public void processIfTarget() {
		String stmt = getStatement();
		String[] components = stmt.split( " " );
		this.addInformation( new Information( "TARGET", components[components.length - 1] ) );
	}
	
	public String getTarget() {
		for( Information info : details ) {
			if( info.getInfoName().equals( "TARGET" ) ) {
				return info.getInfoValue();
			}
		}
		return "";
	}
}

class Information implements Serializable {

	private static final long serialVersionUID = -2242398008897200660L;
	
	private String infoName;
	private String infoValue;

	public Information(String name, String value) {
		infoName = name;
		infoValue = value;
	}

	public String getInfoName() {
		return infoName;
	}

	public String getInfoValue() {
		return infoValue;
	}

	public void setInfoName(String name) {
		infoName = name;
	}

	public void setInfoValue(String value) {
		infoValue = value;
	}
}