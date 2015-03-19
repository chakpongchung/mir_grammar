grammar MIRExtra;

@header {
	import java.io.File;
	import java.io.FileNotFoundException;
	import java.io.FileOutputStream;
	import java.io.IOException;
	import java.io.PrintWriter;
}

@parser::members {
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
	}
	Writer writer = new Writer("parseOutput.txt");
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
	{ writer.closeWriter(); }
	;
progUnit
	: (jumpLabel ':')? 
	begin='begin'
	{
		writer.writeContent( "BEGIN found on line " + $begin.line );
	} 
	mirInsts 
	end='end'
	{
		writer.writeContent( "END found on line " + $end.line );
	}
	;
mirInsts
	: ((jumpLabel ':')? mirInst Comment?)*
	;
mirInst
	: receiveInst
	| assignInst
	| gotoInst
	| ifInst
	| callInst
	| returnInst
	| sequenceInst
	| jumpLabel ':' mirInst
	;
receiveInst
	: receive='receive' varName '(' paramType ')'
	{
		String statement = "receive " + $varName.text + "(" + $paramType.text + ")";
		int n = $receive.line;
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
assignInst
	: varName asg='<-' expression
	{
		String statement = $varName.text + " <- " + $expression.text;
		int n = $asg.line;
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	| v1=varName asg='<-' '(' v2=varName ')' operand
	{
		String statement = $v1.text + " <- (" + $v2.text + ") " + $operand.text;
		int n = $asg.line;
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	| (star='*')? varName (dot='.' eltName)? asg='<-' operand
	{
		String statement = "";
		if( $star != null ) {
			statement += "* ";
		}
		statement += $varName.text;
		if( $dot != null ) {
			statement += "." + $eltName.text;
		}
		statement += " <- " + $operand.text;
		int n = $asg.line;
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
gotoInst
	: gt='goto' jumpLabel
	{
		String statement = "goto " + $jumpLabel.text;
		int n = $gt.line;
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
		writer.writeContent( "Statement: " + statement + " on line " + n );
	}
	;
sequenceInst
	: sq='sequence'
	{
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


//LEXER

//KEYWORDS
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

//OPERATORS
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

Identifier
	: Letter (Letter | DecDigit | '_')*
	;
Whitespace
	: [ \t]+ 
	-> channel(HIDDEN)
	;
NewLine
	: ('\r' '\n'? | '\n') 
	-> channel(HIDDEN) 
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