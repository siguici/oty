# ANTLR4 grammar validation status

## Target

ANTLR 4.13.2, Python 3 target for executable parsing tests.

The normative grammar remains `../language.ebnf`; these `.g4` files are an
implementation grammar and must not redefine Oty semantics.

## Static preflight completed

- No duplicate parser rules.
- No duplicate lexer rules/tokens.
- Every uppercase token referenced by `OtyParser.g4` is defined by `OtyLexer.g4`.
- Every parser rule reference resolves to a defined parser rule.
- `$it` has a dedicated token.
- `$$name` has a dedicated `VARIABLE_VARIABLE` token.
- `#[...]` is protected from `#` line-comment matching.
- Shebang remains visible to the parser.
- `??`, `??=`, `inout`, `keyof`, `infer`, and `finally` have dedicated tokens.
- The tuple/array ambiguity was resolved: `[T]` is an array; `[T,]` is a one-element tuple.

## Runtime compilation

The execution environment used to prepare this artifact does not contain the
ANTLR 4 tool JAR and has no network access for downloading it. Therefore a
literal `java -jar antlr-4.13.2-complete.jar ...` compilation could not be
executed in this session.

This is intentionally recorded rather than claiming a successful ANTLR
compilation that did not occur. The supplied `tools/antlr4-generate.sh` is the
exact generation command to run once the official ANTLR 4.13.2 tool JAR is
available, followed by `tools/run-grammar-tests.py`.

## Known lexical boundary

Heredoc/nowdoc and template-literal-type lexing require context-sensitive lexer
handling beyond the current portable token rules. The parser grammar reserves
these constructs, but they are not part of the first executable smoke-test
suite. They should be finalized with dedicated lexer modes before v0.1 is
called fully implementation-complete.
