# Oty ANTLR4 grammar

This directory contains the ANTLR4 representation of the Oty v0.1 grammar.

## Files

- `OtyLexer.g4` — lexical grammar.
- `OtyParser.g4` — parser grammar.

## Important

`language.ebnf` remains the normative specification.

ANTLR4 is an implementation grammar. It does not replace `spec/language.ebnf`.

The Oty compiler pipeline should be:

    source
      -> Oty lexer
      -> ASI/ACI normalization
      -> Oty parser
      -> Oty AST
      -> semantic analysis
      -> lowering IR
      -> PHP AST
      -> PHP emitter

ASI and ACI are deliberately not hidden inside ordinary parser productions.
A production-level implementation should therefore use a token stream
normalizer/filter between the lexer and parser.

Some constructs such as heredoc/nowdoc and template-literal types require
ANTLR lexer modes in the production lexer. The grammar reserves their lexical
entry points; the reference compiler should implement the exact termination
rules from `language.ebnf`.

The ANTLR grammar is intended to be mechanically aligned with the normative
grammar, while ANTLR-specific factoring and semantic predicates may be added
when required by the concrete parser implementation.
