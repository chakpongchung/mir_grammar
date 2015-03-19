grammar MIRFinal;

@header {
	import java.util.*;
}

@parser::members {
	Writer writer = new Writer("parseOutput.txt");
	ArrayList<Node> nodes = new ArrayList<Node>();
	String label = "";
}

program
	: (
		jumpLabel r=':'
		{
			String procName = $jumpLabel.text;
			int n = $r.line;
			writer.writeContent( "Procedure Name: " + procName + " on line " + n );
		}
	)? 
	progUnit*
	{ 
		writer.closeWriter();
		writer.writeObject( nodes, "nodes.ser" );
	}
	;
progUnit
	: (jumpLabel ':')? 
	begin='begin'
	{
		Node node = new Node( "BEGIN", Node.BEGIN, "", $begin.line );
		nodes.add( node );
		writer.writeContent( "BEGIN found on line " + $begin.line );
	} 
	mirInsts 
	end='end'
	{
		node = new Node( "END", Node.END, "", $end.line );
		nodes.add( node );
		writer.writeContent( "END found on line " + $end.line );
	}
	;
mirInsts
	: (
		(
			jumpLabel ':'
			{
				label = $jumpLabel.text;
			}
		)? 
		mirInst
		{
			label = "";
		} 
		Comment?
	  )*
	;
mirInst
	: receiveInst
	| assignInst
	| gotoInst
	| ifInst
	| callInst
	| returnInst
	| sequenceInst
	| jumpLabel{ label = $jumpLabel.text; } ':' mirInst { label = ""; }
	;
receiveInst
	: receive='receive' varName '(' paramType ')'
	{
		String statement = "receive " + $varName.text + "(" + $paramType.text + ")";
		int n = $receive.line;
		Node node = new Node( statement, Node.RECEIVE_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
assignInst
	: v3=varName asg='<-' expression
	{
		String statement = $v3.text + " <- " + $expression.text;
		int n = $asg.line;
		Node node = new Node( statement, Node.ASSIGN_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	| v1=varName asg='<-' '(' v2=varName ')' operand
	{
		String statement = $v1.text + " <- (" + $v2.text + ") " + $operand.text;
		int n = $asg.line;
		Node node = new Node( statement, Node.ASSIGN_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	| (star='*')? v4=varName (dot='.' eltName)? asg='<-' operand
	{
		String statement = "";
		if( $star != null ) {
			statement += "* ";
		}
		statement += $v4.text;
		if( $dot != null ) {
			statement += "." + $eltName.text;
		}
		statement += " <- " + $operand.text;
		int n = $asg.line;
		Node node = new Node( statement, Node.ASSIGN_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
gotoInst
	: gt='goto' jumpLabel
	{
		String statement = "goto " + $jumpLabel.text;
		int n = $gt.line;
		Node node = new Node( statement, Node.GOTO_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
ifInst
	: 'if' relExpr (gto='goto' jumpLabel | trp='trap' Integer )
	{
		String statement = "if " + $relExpr.text;
		int n;
		if( $gto != null ) {
			statement += " goto ";
			statement += $jumpLabel.text;
			n = $gto.line;
		} else {
			statement += " trap ";
			statement += $Integer.text;
			n = $trp.line;
		}
		Node node = new Node( statement, Node.IF_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
callInst
	: (call='call' | varName asg='<-') procName ',' argsList
	{
		String statement = "";
		int n;
		if( $call != null ) {
			statement += "call ";
			n = $call.line;
		} else {
			statement += $varName.text + " <- ";
			n = $asg.line;
		}
		statement += $procName.text + ", " + $argsList.text;
		Node node = new Node( statement, Node.CALL_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
argsList
	: '(' argList (';' argList)* ')'
	;
argList
	: operand ',' typeName
	;
returnInst
	: rt='return' (operand)?
	{
		String statement = "return";
		if( $operand.text != null ) {
			statement += " " + $operand.text;
		}
		int n = $rt.line;
		Node node = new Node( statement, Node.RETURN_INST, label, n );
		nodes.add( node );
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
sequenceInst
	: sq='sequence'
	{
		Node node = new Node( "sequence", Node.SEQUENCE_INST, label, $sq.line );
		nodes.add( node );
		writer.writeContent( "Statement: sequence on line " + $sq.line );
	}
	;
expression
	: operand binOper operand
	| unaryOper operand
	| operand
	;
relExpr
	: operand relOper operand
	| ('!')? operand
	;
operand
	: varName
	| Const
	;
binOper
	: '+'
	| '-'
	| '*'
	| '/'
	| 'mod' 
	| 'min' 
	| 'max'
	| relOper 
	| 'shl' 
	| 'shr' 
	| 'shra' 
	| 'and' 
	| 'or'
	| 'xor' 
	| '.' 
	| '*.'
	;
relOper
	: '=' 
	| '!=' 
	| '<' 
	| '<=' 
	| '>' 
	| '>='
	;
unaryOper
	: '-' 
	| '!' 
	| 'addr' 
	| '(' typeName ')' 
	| '*'
	;
jumpLabel
	: Identifier
	;
varName
	: Identifier
	;
eltName
	: Identifier
	;
procName
	: Identifier
	;
paramType
	: 'val' 
	| 'res' 
	| 'valres' 
	| 'ref'
	;
typeName
	: 'int' 
	| 'char' 
	| Identifier
	;
	
BEGIN: 'begin';
END: 'end';
RECEIVE: 'receive';
IF: 'if';
GOTO: 'goto';
TRAP: 'trap';
CALL: 'call';
RETURN: 'return';
SEQUENCE: 'sequence';
VAL: 'val';
RES: 'res';
VALRES: 'valres';
REF: 'ref';
INT: 'int';
CHAR: 'char';



COLON: ':';
COMMENT: '||';
DOT: '.';
STARDOT: '*.';
COMMA: ',';
SEMI: ';';
ASSIGN: '<-';
PLUS: '+';
MINUS: '-';
ASTERISK: '*';
FSLASH: '/';
MOD: 'mod';
MIN: 'min';
MAX: 'max';
LPAREN: '(';
RPAREN: ')';
EQUALS: '=';
NOTEQUALS: '!=';
GREATER: '>';
LESS: '<';
GREATEREQ: '>=';
LESSEQ: '<=';
NOT: '!';
ADDR: 'addr';
AND: 'and';
OR: 'or';
XOR: 'xor';
SHL: 'shl';
SHR: 'shr';
SHRA: 'shra';

Identifier
	: Letter (Letter | DecDigit | '_')*
	;
Const
	: Integer 
	| FloatNumber 
	| Boolean
	;
Integer
	: '0' 
	| ('-')? NZDecDigit DecDigit* 
	| '0x' HexDigit+
	;
FloatNumber
	: ('-')? DecDigit+ '.' DecDigit+ ('E' ('-')? DecDigit+)? ('D')?
	;
Boolean
	: 'true' 
	| 'false'
	;
Whitespace
	: [ \t]+ 
	-> skip
	;
NewLine
	: ('\r' '\n'? | '\n') 
	-> skip 
	;
Comment
	: '||' ~[\n\r]* 
	-> skip
	;
fragment
Letter: [a-zA-Z];

fragment
NZDecDigit: [1-9];

fragment
DecDigit: [0-9];

fragment
HexDigit: [0-9a-fA-F];