lexer grammar OtyLexer;

@header {
package oty.parser;
}

/*
 * Oty v0.1 canonical lexer.
 *
 * IMPORTANT:
 * ASI/ACI are normalization phases defined by language.ebnf.
 * This lexer therefore preserves NEWLINE tokens and does not insert
 * semicolons or commas itself. A preprocessing/token-normalization layer
 * must perform ASI/ACI before OtyParser consumes the stream.
 *
 * Unicode identifier semantics are delegated to the runtime/tooling profile.
 */

/* ---------- Shebang ---------- */

SHEBANG
    : '#!' ~[\r\n]* -> channel(HIDDEN)
    ;

/* ---------- Comments / whitespace ---------- */

BLOCK_COMMENT
    : '/*' .*? '*/' -> channel(HIDDEN)
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> channel(HIDDEN)
    | '#' ~[\r\n]* -> channel(HIDDEN)
    ;

WS
    : [ \t\v\f]+ -> channel(HIDDEN)
    ;

NEWLINE
    : '\r\n'
    | '\r'
    | '\n'
    ;

/* ---------- Keywords ---------- */

AND             : 'and' ;
ARRAY           : 'array' ;
AS              : 'as' ;
BREAK           : 'break' ;
CASE            : 'case' ;
CATCH           : 'catch' ;
CLASS           : 'class' ;
CLONE           : 'clone' ;
CONST           : 'const' ;
CONTINUE        : 'continue' ;
DECLARE         : 'declare' ;
DEFAULT         : 'default' ;
DIE             : 'die' ;
DO              : 'do' ;
ECHO            : 'echo' ;
ELSE            : 'else' ;
ELSEIF          : 'elseif' ;
ENUM            : 'enum' ;
EVAL            : 'eval' ;
EXTENDS         : 'extends' ;
FALSE           : 'false' ;
FINAL           : 'final' ;
FN              : 'fn' ;
FOR             : 'for' ;
FOREACH         : 'foreach' ;
FUNCTION        : 'function' ;
GLOBAL          : 'global' ;
GOTO            : 'goto' ;
IF              : 'if' ;
IMPLEMENTS      : 'implements' ;
INCLUDE         : 'include' ;
INCLUDE_ONCE    : 'include_once' ;
IN              : 'in' ;
INSTANCEOF      : 'instanceof' ;
INTERFACE       : 'interface' ;
IS              : 'is' ;
MATCH           : 'match' ;
NAMESPACE       : 'namespace' ;
NEW             : 'new' ;
NULL            : 'null' ;
OBJECT          : 'object' ;
OPAQUE          : 'opaque' ;
OR              : 'or' ;
PRINT           : 'print' ;
PRIVATE         : 'private' ;
PROTECTED       : 'protected' ;
PUBLIC          : 'public' ;
READONLY        : 'readonly' ;
REQUIRE         : 'require' ;
REQUIRE_ONCE    : 'require_once' ;
RETURN          : 'return' ;
STATIC          : 'static' ;
STRUCT          : 'struct' ;
SWITCH          : 'switch' ;
THROW           : 'throw' ;
TRAIT           : 'trait' ;
TRUE            : 'true' ;
TRY             : 'try' ;
TYPE            : 'type' ;
TYPEOF          : 'typeof' ;
UNSET           : 'unset' ;
USE             : 'use' ;
VAR             : 'var' ;
VOID            : 'void' ;
WHILE           : 'while' ;
XOR             : 'xor' ;
YIELD           : 'yield' ;

/* ---------- Builtin type keywords ---------- */

BOOL            : 'bool' ;
INT             : 'int' ;
FLOAT           : 'float' ;
STRING          : 'string' ;
NEVER           : 'never' ;
MIXED           : 'mixed' ;
RESOURCE        : 'resource' ;
CALLABLE        : 'callable' ;
INTEGER         : 'integer' ;
DOUBLE          : 'double' ;
BOOLEAN         : 'boolean' ;

/* ---------- Utility type identifiers ---------- */

PARTIAL         : 'Partial' ;
REQUIRED        : 'Required' ;
READONLY_TYPE   : 'Readonly' ;
PICK            : 'Pick' ;
OMIT            : 'Omit' ;
RECORD          : 'Record' ;
EXCLUDE         : 'Exclude' ;
EXTRACT         : 'Extract' ;
NON_NULLABLE    : 'NonNullable' ;
RETURN_TYPE     : 'ReturnType' ;
PARAMETERS      : 'Parameters' ;

/* ---------- Literals ---------- */

BINARY_LITERAL
    : '0' [bB] [01] ([01] | '_' [01])*
    ;

OCTAL_LITERAL
    : '0' [oO] [0-7] ([0-7] | '_' [0-7])*
    ;

HEX_LITERAL
    : '0' [xX] [0-9a-fA-F] ([0-9a-fA-F] | '_' [0-9a-fA-F])*
    ;

FLOAT_LITERAL
    : DIGITS '.' DIGITS EXPONENT?
    | DIGITS EXPONENT
    ;

INTEGER_LITERAL
    : '0'
    | NON_ZERO_DIGIT (DIGIT | '_' DIGIT)*
    ;

fragment DIGITS
    : DIGIT (DIGIT | '_' DIGIT)*
    ;

fragment EXPONENT
    : [eE] [+-]? DIGIT (DIGIT | '_' DIGIT)*
    ;

fragment NON_ZERO_DIGIT
    : [1-9]
    ;

fragment DIGIT
    : [0-9]
    ;

/* ---------- Strings ---------- */

STRING_LITERAL
    : '\'' (ESCAPE_SINGLE | ~['\\\r\n])* '\''
    | '"' (ESCAPE_SEQUENCE | STRING_INTERPOLATION | ~["\\\r\n])* '"'
    ;

fragment ESCAPE_SINGLE
    : '\\' ('\\' | '\'')
    ;

fragment ESCAPE_SEQUENCE
    : '\\' (
          '\\' | '"' | '\'' | 'n' | 'r' | 't' | 'v' | 'e' | 'f' | '$'
        | 'x' HEX_DIGIT HEX_DIGIT
        | 'u' '{' HEX_DIGIT+ '}'
      )
    ;

fragment STRING_INTERPOLATION
    : '${' .*? '}'
    | '$' ID_START ID_PART*
    | '$' ID_START ID_PART* '->' ID_START ID_PART*
    ;

HEREDOC_START
    : '<<<' '\''? ID '\''?
    ;

/*
 * Heredoc/nowdoc bodies require mode-sensitive lexing to implement exactly.
 * The generated reference lexer reserves HEREDOC_START; the compiler lexer
 * should switch modes after recognizing the opening label and consume until
 * the matching label.
 */

/* ---------- Variables / identifiers ---------- */

IT_VARIABLE
    : '$it'
    ;

VARIABLE
    : '$' ID_START ID_PART*
    ;

IDENTIFIER
    : ID_START ID_PART*
    ;

fragment ID_START
    : [\p{L}\p{Nl}]
    ;

fragment ID_PART
    : [\p{M}\p{N}\p{Pc}]
    ;

/* ---------- Multi-character operators ---------- */

PIPELINE        : '|>' ;
NULL_COALESCE_ASSIGN : '??=' ;
STRICT_EQ       : '===' ;
STRICT_NEQ      : '!==' ;
SPACESHIP       : '<=>' ;
SHIFT_LEFT_ASSIGN  : '<<=' ;
SHIFT_RIGHT_ASSIGN : '>>=' ;
POWER_ASSIGN    : '**=' ;
PLUS_ASSIGN     : '+=' ;
MINUS_ASSIGN    : '-=' ;
MUL_ASSIGN      : '*=' ;
DIV_ASSIGN      : '/=' ;
MOD_ASSIGN      : '%=' ;
CONCAT_ASSIGN   : '.=' ;
BIT_AND_ASSIGN  : '&=' ;
BIT_XOR_ASSIGN  : '^=' ;
BIT_OR_ASSIGN   : '|=' ;
SHIFT_LEFT      : '<<' ;
SHIFT_RIGHT     : '>>' ;
POWER           : '**' ;
NULLSAFE_ARROW  : '?->' ;
ARROW           : '->' ;
DOUBLE_COLON    : '::' ;
FAT_ARROW       : '=>' ;
ELLIPSIS        : '...' ;
EQ              : '==' ;
NEQ             : '!=' ;
LTE             : '<=' ;
GTE             : '>=' ;
PLUS_PLUS       : '++' ;
MINUS_MINUS     : '--' ;

/* ---------- Single-character operators / delimiters ---------- */

ASSIGN          : '=' ;
PLUS            : '+' ;
MINUS           : '-' ;
STAR            : '*' ;
SLASH           : '/' ;
PERCENT         : '%' ;
DOT             : '.' ;
AMP             : '&' ;
PIPE            : '|' ;
CARET           : '^' ;
BANG            : '!' ;
TILDE           : '~' ;
QUESTION        : '?' ;
COLON           : ':' ;
SEMICOLON       : ';' ;
COMMA           : ',' ;
LPAREN          : '(' ;
RPAREN          : ')' ;
LBRACK          : '[' ;
RBRACK          : ']' ;
LBRACE          : '{' ;
RBRACE          : '}' ;
BACKSLASH       : '\\' ;
LT              : '<' ;
GT              : '>' ;
AT              : '@' ;
BACKTICK        : '`' ;

/* ---------- Additional contextual / punctuation tokens ---------- */

HASH            : '#' ;
UNDERSCORE      : '_' ;
RANGE_INCLUSIVE : '..=' ;
RANGE           : '..' ;
OR_OR           : '||' ;
AND_AND         : '&&' ;
FROM            : 'from' ;
EXPORT          : 'export' ;
ABSTRACT       : 'abstract' ;
OUT            : 'out' ;
INSTEADOF       : 'insteadof' ;
ENDDECLARE      : 'enddeclare' ;
ARRAY_KW        : 'array' ;
EXIT            : 'exit' ;

/* ---------- Fallback ---------- */

ERROR_CHAR
    : .
    ;

fragment HEX_DIGIT
    : [0-9a-fA-F]
    ;
