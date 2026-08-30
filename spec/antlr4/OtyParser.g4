parser grammar OtyParser;

options {
    tokenVocab = OtyLexer;
}

/*
 * Oty v0.1 parser grammar.
 *
 * This grammar mirrors spec/language.ebnf after lexical normalization.
 * ASI/ACI MUST be applied before parsing. The parser itself intentionally
 * does not attempt to infer statement/list separators from NEWLINE.
 *
 * Some semantic distinctions (type/value resolution, opaque types, generic
 * validity, match exhaustiveness, $it binding, etc.) belong to later phases.
 */

otySource
    : shebang? sourceElement* EOF
    ;

shebang
    : SHEBANG
    ;

sourceElement
    : namespaceDeclaration
    | useDeclaration
    | exportDeclaration
    | typeAliasDeclaration
    | opaqueTypeDeclaration
    | structDeclaration
    | classDeclaration
    | interfaceDeclaration
    | traitDeclaration
    | enumDeclaration
    | functionDeclaration
    | constantDeclaration
    | attributeGroup
    | statement
    | haltCompilerDirective
    ;

haltCompilerDirective
    : IDENTIFIER LPAREN RPAREN SEMICOLON
    ;

/* ---------- Names ---------- */

qualifiedName
    : BACKSLASH? IDENTIFIER (BACKSLASH IDENTIFIER)*
    ;

namedType
    : qualifiedName
    ;

/* ---------- Modules ---------- */

namespaceDeclaration
    : NAMESPACE qualifiedName SEMICOLON
    ;

useDeclaration
    : USE useKind? useClause SEMICOLON
    ;

useKind
    : TYPE
    | FUNCTION
    | CONST
    ;

useClause
    : useItem
    | qualifiedName BACKSLASH LBRACE useItemList RBRACE
    ;

useItemList
    : useItem (COMMA useItem)* COMMA?
    ;

useItem
    : qualifiedName (AS IDENTIFIER)?
    ;

exportDeclaration
    : EXPORT (exportItem | LBRACE exportItemList RBRACE) SEMICOLON
    ;

exportItemList
    : exportItem (COMMA exportItem)* COMMA?
    ;

exportItem
    : IDENTIFIER
    | qualifiedName
    ;

/* ---------- Attributes ---------- */

attributeGroup
    : HASH LBRACK attributeList RBRACK
    ;

attributeList
    : attribute (COMMA attribute)* COMMA?
    ;

attribute
    : qualifiedName (LPAREN argumentList? RPAREN)?
    ;

/* ---------- Declarations ---------- */

typeAliasDeclaration
    : attributeGroup? TYPE IDENTIFIER genericParameterClause?
      ASSIGN typeExpression SEMICOLON
    ;

opaqueTypeDeclaration
    : attributeGroup? OPAQUE TYPE IDENTIFIER genericParameterClause?
      (COLON typeExpression)? ASSIGN typeExpression SEMICOLON
    ;

structDeclaration
    : attributeGroup? STRUCT IDENTIFIER genericParameterClause?
      (EXTENDS namedType)?
      (IMPLEMENTS typeList)?
      structBody
    ;

structBody
    : LBRACE structMember* RBRACE
    ;

structMember
    : attributeGroup? structPropertyDeclaration
    | attributeGroup? constantDeclaration
    | attributeGroup? methodDeclaration
    | attributeGroup? traitUseDeclaration
    ;

structPropertyDeclaration
    : visibilityModifier? STATIC? READONLY? VARIABLE
      (COLON typeExpression)?
      (ASSIGN expression)? SEMICOLON
    ;

classDeclaration
    : attributeGroup? classModifier* CLASS IDENTIFIER genericParameterClause?
      (EXTENDS namedType)?
      (IMPLEMENTS typeList)?
      classBody
    ;

classBody
    : LBRACE classMember* RBRACE
    ;

classMember
    : attributeGroup? propertyDeclaration
    | attributeGroup? constantDeclaration
    | attributeGroup? methodDeclaration
    | attributeGroup? traitUseDeclaration
    ;

interfaceDeclaration
    : attributeGroup? INTERFACE IDENTIFIER genericParameterClause?
      (EXTENDS typeList)?
      interfaceBody
    ;

interfaceBody
    : LBRACE interfaceMember* RBRACE
    ;

interfaceMember
    : attributeGroup? constantDeclaration
    | attributeGroup? methodSignature
    ;

traitDeclaration
    : attributeGroup? TRAIT IDENTIFIER genericParameterClause? traitBody
    ;

traitBody
    : LBRACE traitMember* RBRACE
    ;

traitMember
    : attributeGroup? propertyDeclaration
    | attributeGroup? constantDeclaration
    | attributeGroup? methodDeclaration
    | attributeGroup? traitUseDeclaration
    ;

traitUseDeclaration
    : USE qualifiedNameList traitAdaptationBlock? SEMICOLON
    ;

qualifiedNameList
    : qualifiedName (COMMA qualifiedName)* COMMA?
    ;

traitAdaptationBlock
    : LBRACE traitAdaptation* RBRACE
    ;

traitAdaptation
    : traitPrecedence
    | traitAlias
    ;

traitPrecedence
    : qualifiedName DOUBLE_COLON IDENTIFIER INSTEADOF qualifiedNameList SEMICOLON
    ;

traitAlias
    : visibilityModifier? qualifiedName DOUBLE_COLON IDENTIFIER
      AS IDENTIFIER? SEMICOLON
    ;

enumDeclaration
    : attributeGroup? ENUM IDENTIFIER (COLON backedEnumType)?
      (IMPLEMENTS typeList)? enumBody
    ;

backedEnumType
    : INT
    | STRING
    ;

enumBody
    : LBRACE enumMember* RBRACE
    ;

enumMember
    : attributeGroup? enumCase
    | attributeGroup? constantDeclaration
    | attributeGroup? methodDeclaration
    ;

enumCase
    : CASE IDENTIFIER (ASSIGN scalarLiteral)? SEMICOLON
    ;

functionDeclaration
    : attributeGroup? EXPORT? FUNCTION AMP? IDENTIFIER
      genericParameterClause? parameterClause (COLON typeExpression)?
      functionBody
    ;

functionBody
    : blockStatement
    ;

methodDeclaration
    : attributeGroup? methodModifier* FUNCTION AMP? IDENTIFIER
      genericParameterClause? parameterClause (COLON typeExpression)?
      (functionBody | SEMICOLON)
    ;

methodSignature
    : attributeGroup? methodModifier* FUNCTION AMP? IDENTIFIER
      genericParameterClause? parameterClause (COLON typeExpression)?
      SEMICOLON
    ;

/* ---------- Modifiers ---------- */

visibilityModifier
    : PUBLIC
    | PROTECTED
    | PRIVATE
    ;

classModifier
    : ABSTRACT
    | FINAL
    ;

methodModifier
    : STATIC
    | ABSTRACT
    | FINAL
    ;

/* ---------- Parameters / properties / constants ---------- */

parameterClause
    : LPAREN parameterList? RPAREN
    ;

parameterList
    : parameter (COMMA parameter)* COMMA?
    ;

parameter
    : attributeGroup?
      ELLIPSIS?
      IN?
      typeExpression?
      AMP?
      VARIABLE
      (ASSIGN expression)?
    ;

propertyDeclaration
    : attributeGroup?
      READONLY*
      visibilityModifier?
      STATIC?
      propertyItemList
      SEMICOLON
    ;

propertyItemList
    : propertyItem (COMMA propertyItem)*
    ;

propertyItem
    : VARIABLE (COLON typeExpression)? (ASSIGN expression)?
    ;

constantDeclaration
    : attributeGroup?
      visibilityModifier?
      CONST constantItemList SEMICOLON
    ;

constantItemList
    : constantItem (COMMA constantItem)*
    ;

constantItem
    : IDENTIFIER ASSIGN constantExpression
    ;

/* ---------- Generics ---------- */

genericParameterClause
    : LT genericParameterList GT
    ;

genericParameterList
    : genericParameter (COMMA genericParameter)* COMMA?
    ;

genericParameter
    : varianceModifier? IDENTIFIER (genericConstraint)?
      (ASSIGN typeExpression)?
    ;

varianceModifier
    : IN
    | OUT
    ;

genericConstraint
    : IS typeExpression
    ;

/* ---------- Types ---------- */

typeExpression
    : conditionalType
    ;

conditionalType
    : unionType
      (EXTENDS typeExpression QUESTION typeExpression COLON typeExpression)?
    ;

unionType
    : intersectionType (PIPE intersectionType)*
    ;

intersectionType
    : nullableType (AMP nullableType)*
    ;

nullableType
    : QUESTION? postfixType
    ;

postfixType
    : primaryType typePostfix*
    ;

typePostfix
    : arraySuffix
    | indexedAccessSuffix
    | genericInstantiation
    ;

arraySuffix
    : LBRACK RBRACK
    ;

indexedAccessSuffix
    : LBRACK typeExpression RBRACK
    ;

genericInstantiation
    : LT typeArgumentList GT
    ;

primaryType
    : builtinType
    | namedType
    | literalType
    | tupleType
    | arrayType
    | arrayShapeType
    | inlineStructType
    | callableType
    | keyOfType
    | typeOfType
    | inferType
    | utilityType
    | templateLiteralType
    | parenthesizedType
    ;

builtinType
    : BOOL | INT | FLOAT | STRING | TRUE | FALSE | NULL
    | VOID | NEVER | MIXED | OBJECT | RESOURCE | CALLABLE
    ;

literalType
    : INTEGER_LITERAL
    | FLOAT_LITERAL
    | STRING_LITERAL
    | TRUE
    | FALSE
    | NULL
    ;

tupleType
    : LBRACK typeList? COMMA? RBRACK
    ;

arrayType
    : LBRACK typeExpression RBRACK
    ;

arrayShapeType
    : LBRACK arrayShapeFieldList? COMMA? RBRACK
    ;

arrayShapeFieldList
    : arrayShapeField (COMMA arrayShapeField)*
    ;

arrayShapeField
    : arrayShapeKey? ELLIPSIS? QUESTION? COLON typeExpression
    ;

arrayShapeKey
    : IDENTIFIER
    | STRING_LITERAL
    | INTEGER_LITERAL
    ;

inlineStructType
    : STRUCT LBRACE inlineStructFieldList? COMMA? RBRACE
    ;

inlineStructFieldList
    : inlineStructField (COMMA inlineStructField)*
    ;

inlineStructField
    : READONLY? IDENTIFIER QUESTION? COLON typeExpression
    ;

callableType
    : CALLABLE LPAREN callableParameterTypeList? RPAREN
      (COLON typeExpression)?
    ;

callableParameterTypeList
    : callableParameterType (COMMA callableParameterType)* COMMA?
    ;

callableParameterType
    : ELLIPSIS? typeExpression (ASSIGN typeExpression)?
    ;

keyOfType
    : IDENTIFIER LT typeExpression GT
    ;

typeOfType
    : TYPEOF typeOfOperand
    ;

typeOfOperand
    : VARIABLE
    | qualifiedName
    | parenthesizedExpression
    ;

inferType
    : IDENTIFIER
    ;

utilityType
    : utilityTypeName LT typeExpression GT
    ;

utilityTypeName
    : PARTIAL | REQUIRED | READONLY_TYPE | PICK | OMIT | RECORD
    | EXCLUDE | EXTRACT | NON_NULLABLE | RETURN_TYPE | PARAMETERS
    ;

templateLiteralType
    : BACKTICK templateLiteralTypePart* BACKTICK
    ;

templateLiteralTypePart
    : ~['] /* placeholder: custom lexer mode recommended */
    ;

/*
 * ANTLR lexer character sets cannot directly express the EBNF interpolation
 * fragment portably in a parser grammar. The reference implementation should
 * model template literal types with a dedicated lexer mode.
 */

parenthesizedType
    : LPAREN typeExpression RPAREN
    ;

typeArgumentList
    : typeExpression (COMMA typeExpression)* COMMA?
    ;

typeList
    : typeExpression (COMMA typeExpression)* COMMA?
    ;

/* ---------- Constant expressions ---------- */

constantExpression
    : constantConditionalExpression
    ;

constantConditionalExpression
    : constantLogicalOrExpression
      (QUESTION constantExpression COLON constantExpression)?
    ;

constantLogicalOrExpression
    : constantLogicalAndExpression (OR_OR constantLogicalAndExpression)*
    ;

constantLogicalAndExpression
    : constantBitwiseOrExpression (AND_AND constantBitwiseOrExpression)*
    ;

constantBitwiseOrExpression
    : constantBitwiseXorExpression (PIPE constantBitwiseXorExpression)*
    ;

constantBitwiseXorExpression
    : constantBitwiseAndExpression (CARET constantBitwiseAndExpression)*
    ;

constantBitwiseAndExpression
    : constantEqualityExpression (AMP constantEqualityExpression)*
    ;

constantEqualityExpression
    : constantRelationalExpression
      (equalityOperator constantRelationalExpression)*
    ;

constantRelationalExpression
    : constantShiftExpression
      (relationalOperator constantShiftExpression)*
    ;

constantShiftExpression
    : constantAdditiveExpression
      (shiftOperator constantAdditiveExpression)*
    ;

constantAdditiveExpression
    : constantMultiplicativeExpression
      (additiveOperator constantMultiplicativeExpression)*
    ;

constantMultiplicativeExpression
    : constantExponentiationExpression
      (multiplicativeOperator constantExponentiationExpression)*
    ;

constantExponentiationExpression
    : constantPrefixExpression (POWER constantExponentiationExpression)?
    ;

constantPrefixExpression
    : prefixOperator constantPrefixExpression
    | constantPrimaryExpression
    ;

constantPrimaryExpression
    : scalarLiteral
    | qualifiedName
    | LPAREN constantExpression RPAREN
    ;

/* ---------- Expressions ---------- */

expression
    : orExpression
    ;

orExpression
    : xorExpression (OR xorExpression)*
    ;

xorExpression
    : andExpression (XOR andExpression)*
    ;

andExpression
    : assignmentExpression (AND assignmentExpression)*
    ;

assignmentExpression
    : ternaryExpression (assignmentOperator assignmentExpression)?
    ;

assignmentOperator
    : ASSIGN | PLUS_ASSIGN | MINUS_ASSIGN | MUL_ASSIGN | DIV_ASSIGN
    | MOD_ASSIGN | CONCAT_ASSIGN | POWER_ASSIGN | SHIFT_LEFT_ASSIGN
    | SHIFT_RIGHT_ASSIGN | BIT_AND_ASSIGN | BIT_XOR_ASSIGN
    | BIT_OR_ASSIGN | NULL_COALESCE_ASSIGN
    ;

ternaryExpression
    : coalesceExpression
      (QUESTION expression COLON ternaryExpression)?
    ;

coalesceExpression
    : pipelineExpression (NULL_COALESCE coalesceExpression)?
    ;

pipelineExpression
    : isExpression (PIPELINE isExpression)*
    ;

isExpression
    : logicalOrExpression (IS pattern)?
    ;

logicalOrExpression
    : logicalAndExpression (OR_OR logicalAndExpression)*
    ;

logicalAndExpression
    : bitwiseOrExpression (AND_AND bitwiseOrExpression)*
    ;

bitwiseOrExpression
    : bitwiseXorExpression (PIPE bitwiseXorExpression)*
    ;

bitwiseXorExpression
    : bitwiseAndExpression (CARET bitwiseAndExpression)*
    ;

bitwiseAndExpression
    : equalityExpression (AMP equalityExpression)*
    ;

equalityExpression
    : relationalExpression (equalityOperator relationalExpression)*
    ;

equalityOperator
    : EQ | NEQ | STRICT_EQ | STRICT_NEQ
    ;

relationalExpression
    : shiftExpression (relationalOperator shiftExpression)*
    ;

relationalOperator
    : LT | LTE | GT | GTE | SPACESHIP
    ;

shiftExpression
    : additiveExpression (shiftOperator additiveExpression)*
    ;

shiftOperator
    : SHIFT_LEFT | SHIFT_RIGHT
    ;

additiveExpression
    : multiplicativeExpression (additiveOperator multiplicativeExpression)*
    ;

additiveOperator
    : PLUS | MINUS | DOT
    ;

multiplicativeExpression
    : exponentiationExpression (multiplicativeOperator exponentiationExpression)*
    ;

multiplicativeOperator
    : STAR | SLASH | PERCENT
    ;

exponentiationExpression
    : prefixExpression (POWER exponentiationExpression)?
    ;

prefixExpression
    : prefixOperator prefixExpression
    | throwExpression
    | yieldExpression
    | cloneExpression
    | castExpression
    | postfixExpression
    ;

prefixOperator
    : PLUS | MINUS | BANG | TILDE | AT | AMP
    ;

throwExpression
    : THROW assignmentExpression
    ;

yieldExpression
    : YIELD yieldOperand?
    ;

yieldOperand
    : yieldFromExpression
    | assignmentExpression
    ;

yieldFromExpression
    : FROM assignmentExpression
    ;

cloneExpression
    : CLONE postfixExpression
    ;

castExpression
    : castOperator prefixExpression
    ;

castOperator
    : LPAREN
      (INT | INTEGER | FLOAT | DOUBLE | STRING | BOOL | BOOLEAN | ARRAY | OBJECT)
      RPAREN
    ;

/* ---------- Postfix ---------- */

postfixExpression
    : primaryExpression postfixOperator*
    ;

postfixOperator
    : memberAccessSuffix
    | nullsafeMemberAccessSuffix
    | staticAccessSuffix
    | arrayAccessSuffix
    | callSuffix
    | firstClassCallableSuffix
    | postfixIncrementSuffix
    | postfixDecrementSuffix
    ;

memberAccessSuffix
    : ARROW memberName
    ;

nullsafeMemberAccessSuffix
    : NULLSAFE_ARROW memberName
    ;

staticAccessSuffix
    : DOUBLE_COLON staticMemberName
    ;

memberName
    : IDENTIFIER
    | VARIABLE
    | LBRACE expression RBRACE
    ;

staticMemberName
    : IDENTIFIER
    | VARIABLE
    | CLASS
    ;

arrayAccessSuffix
    : LBRACK expression? RBRACK
    ;

callSuffix
    : LPAREN argumentList? RPAREN
    ;

firstClassCallableSuffix
    : LPAREN ELLIPSIS RPAREN
    ;

argumentList
    : argument (COMMA argument)* COMMA?
    ;

argument
    : ELLIPSIS? (namedArgumentName COLON)? expression
    ;

namedArgumentName
    : IDENTIFIER
    ;

/* ---------- Primary expressions ---------- */

primaryExpression
    : variableExpression
    | itExpression
    | literalExpression
    | nameExpression
    | callableReferenceExpression
    | arrayExpression
    | closureExpression
    | arrowFunctionExpression
    | newExpression
    | matchExpression
    | parenthesizedExpression
    | exitExpression
    | evalExpression
    | includeExpression
    | requireExpression
    | shellExpression
    ;

variableExpression
    : VARIABLE
    | variableVariable
    ;

variableVariable
    : VARIABLE VARIABLE
    ;

itExpression
    : IT_VARIABLE
    ;

literalExpression
    : scalarLiteral
    ;

nameExpression
    : qualifiedName
    ;

callableReferenceExpression
    : callableReferenceTarget LPAREN ELLIPSIS RPAREN
    ;

callableReferenceTarget
    : IDENTIFIER
    | qualifiedName
    | VARIABLE
    | memberReferenceTarget
    | staticReferenceTarget
    ;

memberReferenceTarget
    : primaryExpression ARROW memberName
    ;

staticReferenceTarget
    : qualifiedName DOUBLE_COLON staticMemberName
    ;

arrayExpression
    : LBRACK arrayItemList? RBRACK
    ;

arrayItemList
    : arrayItem (COMMA arrayItem)* COMMA?
    ;

arrayItem
    : (arrayKey FAT_ARROW)? ELLIPSIS? expression
    ;

arrayKey
    : expression
    ;

closureExpression
    : FUNCTION AMP? parameterClause useClause? (COLON typeExpression)?
      blockStatement
    ;

useClause
    : USE LPAREN closureCaptureList? RPAREN
    ;

closureCaptureList
    : closureCapture (COMMA closureCapture)* COMMA?
    ;

closureCapture
    : AMP? VARIABLE
    ;

arrowFunctionExpression
    : FN AMP? parameterClause (COLON typeExpression)? FAT_ARROW expression
    ;

newExpression
    : NEW newTarget constructorArgumentClause?
    ;

newTarget
    : namedType
    | parenthesizedExpression
    ;

constructorArgumentClause
    : LPAREN argumentList? RPAREN
    ;

matchExpression
    : MATCH LPAREN expression? RPAREN
      LBRACE matchArmList RBRACE
    ;

matchArmList
    : matchArm (COMMA matchArm)* COMMA?
    ;

matchArm
    : matchConditionList FAT_ARROW expression
    ;

matchConditionList
    : matchCondition (COMMA matchCondition)*
    ;

matchCondition
    : pattern
    | expression
    ;

parenthesizedExpression
    : LPAREN expression RPAREN
    ;

exitExpression
    : (EXIT | DIE) (LPAREN expression? RPAREN)?
    ;

evalExpression
    : EVAL LPAREN expression RPAREN
    ;

includeExpression
    : includeOperator expression
    ;

includeOperator
    : INCLUDE
    | INCLUDE_ONCE
    ;

requireExpression
    : requireOperator expression
    ;

requireOperator
    : REQUIRE
    | REQUIRE_ONCE
    ;

shellExpression
    : BACKTICK shellCharacter* BACKTICK
    ;

shellCharacter
    : ~BACKTICK
    ;

/* ---------- Patterns ---------- */

pattern
    : patternAlternation
    ;

patternAlternation
    : patternPrimary (PIPE patternPrimary)*
    ;

patternPrimary
    : typePattern
    | literalPattern
    | identifierPattern
    | wildcardPattern
    | objectPattern
    | arrayPattern
    | rangePattern
    | parenthesizedPattern
    ;

typePattern
    : patternType patternBinding?
    ;

patternType
    : typeExpression
    ;

patternBinding
    : AS IDENTIFIER
    ;

literalPattern
    : scalarLiteral
    ;

identifierPattern
    : IDENTIFIER
    ;

wildcardPattern
    : UNDERSCORE
    ;

objectPattern
    : namedType LBRACE objectPatternFieldList? COMMA? RBRACE
    ;

objectPatternFieldList
    : objectPatternField (COMMA objectPatternField)*
    ;

objectPatternField
    : IDENTIFIER (COLON pattern)?
    ;

arrayPattern
    : LBRACK arrayPatternItemList? COMMA? RBRACK
    ;

arrayPatternItemList
    : arrayPatternItem (COMMA arrayPatternItem)*
    ;

arrayPatternItem
    : (arrayPatternKey FAT_ARROW)? pattern
    ;

arrayPatternKey
    : INTEGER_LITERAL
    | STRING_LITERAL
    | IDENTIFIER
    ;

rangePattern
    : rangeBound (RANGE | RANGE_INCLUSIVE) rangeBound
    ;

rangeBound
    : INTEGER_LITERAL
    | FLOAT_LITERAL
    | STRING_LITERAL
    ;

parenthesizedPattern
    : LPAREN pattern RPAREN
    ;

/* ---------- Statements ---------- */

statement
    : emptyStatement
    | variableDeclarationStatement
    | expressionStatement
    | returnStatement
    | throwStatement
    | ifStatement
    | switchStatement
    | whileStatement
    | doWhileStatement
    | forStatement
    | foreachStatement
    | breakStatement
    | continueStatement
    | tryStatement
    | echoStatement
    | printStatement
    | unsetStatement
    | globalStatement
    | gotoStatement
    | labelStatement
    | declareStatement
    | blockStatement
    ;

emptyStatement
    : SEMICOLON
    ;

variableDeclarationStatement
    : VAR variableDeclarationList SEMICOLON
    ;

variableDeclarationList
    : variableDeclaration (COMMA variableDeclaration)*
    ;

variableDeclaration
    : VARIABLE (COLON typeExpression)? (ASSIGN expression)?
    ;

expressionStatement
    : expression SEMICOLON
    ;

returnStatement
    : RETURN expression? SEMICOLON
    ;

throwStatement
    : THROW expression SEMICOLON
    ;

ifStatement
    : IF LPAREN expression RPAREN statementOrBlock
      elseIfClause*
      elseClause?
    ;

elseIfClause
    : ELSEIF LPAREN expression RPAREN statementOrBlock
    ;

elseClause
    : ELSE statementOrBlock
    ;

switchStatement
    : SWITCH LPAREN expression RPAREN LBRACE switchCase* RBRACE
    ;

switchCase
    : switchCaseLabel statement*
    ;

switchCaseLabel
    : CASE expression COLON
    | DEFAULT COLON
    ;

whileStatement
    : WHILE LPAREN expression RPAREN statementOrBlock
    ;

doWhileStatement
    : DO statementOrBlock WHILE LPAREN expression RPAREN SEMICOLON
    ;

forStatement
    : FOR LPAREN forInitializer? SEMICOLON expression? SEMICOLON
      forUpdate? RPAREN statementOrBlock
    ;

forInitializer
    : variableDeclarationList
    | expressionList
    ;

forUpdate
    : expressionList
    ;

expressionList
    : expression (COMMA expression)*
    ;

foreachStatement
    : FOREACH LPAREN expression AS foreachTarget RPAREN statementOrBlock
    ;

foreachTarget
    : AMP? foreachValueTarget
    ;

foreachValueTarget
    : VARIABLE
    | destructuringTarget
    ;

destructuringTarget
    : LBRACK destructuringItemList? COMMA? RBRACK
    ;

destructuringItemList
    : destructuringItem (COMMA destructuringItem)*
    ;

destructuringItem
    : (destructuringKey FAT_ARROW)? ELLIPSIS? AMP?
      (VARIABLE | destructuringTarget)
    ;

destructuringKey
    : INTEGER_LITERAL
    | STRING_LITERAL
    | IDENTIFIER
    ;

breakStatement
    : BREAK INTEGER_LITERAL? SEMICOLON
    ;

continueStatement
    : CONTINUE INTEGER_LITERAL? SEMICOLON
    ;

tryStatement
    : TRY blockStatement catchClause+ finallyClause?
    ;

catchClause
    : CATCH LPAREN catchType VARIABLE? RPAREN blockStatement
    ;

catchType
    : typeExpression
    ;

finallyClause
    : FINALLY blockStatement
    ;

echoStatement
    : ECHO expressionList SEMICOLON
    ;

printStatement
    : PRINT expression SEMICOLON
    ;

unsetStatement
    : UNSET LPAREN expressionList RPAREN SEMICOLON
    ;

globalStatement
    : GLOBAL globalVariableList SEMICOLON
    ;

globalVariableList
    : VARIABLE (COMMA VARIABLE)*
    ;

gotoStatement
    : GOTO IDENTIFIER SEMICOLON
    ;

labelStatement
    : IDENTIFIER COLON
    ;

declareStatement
    : DECLARE LPAREN declareDirectiveList RPAREN
      (COLON statement* ENDDECLARE SEMICOLON)?
    ;

declareDirectiveList
    : declareDirective (COMMA declareDirective)*
    ;

declareDirective
    : IDENTIFIER ASSIGN constantExpression
    ;

blockStatement
    : LBRACE statement* RBRACE
    ;

statementOrBlock
    : blockStatement
    | statement
    ;

/* ---------- Scalars ---------- */

scalarLiteral
    : INTEGER_LITERAL
    | FLOAT_LITERAL
    | STRING_LITERAL
    | TRUE
    | FALSE
    | NULL
    ;
