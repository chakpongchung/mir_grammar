grammar MIR;
program
	: (jumpLabel ':')? progUnit*
	;

progUnit
	: (jumpLabel ':')? 'begin' mirInsts 'end'
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
	: 'receive' varName '(' paramType ')'
	;

assignInst
	: varName '<-' expression
	| varName '<-' '(' varName ')' operand
	| ('*')? varName ('.' eltName)? '<-' operand
	;

gotoInst
	: 'goto' jumpLabel
	;

ifInst
	: 'if' relExpr ('goto' jumpLabel | 'trap' Integer )
	;

callInst
	: ('call' | varName '<-') procName ',' argsList
	;

argsList
	: '(' argList (';' argList)* ')'
	;

argList
	: operand ',' typeName
	;

returnInst
	: 'return' operand?
	;

sequenceInst
	: 'sequence'
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