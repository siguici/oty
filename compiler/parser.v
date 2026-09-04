module compiler

import compiler.core { Position, Span, parser_error }
import compiler.ast { ArrayDecl, AssignExpr, BinaryExpr, Block, Decl, Expr, ForStmt, IfStmt, ListDecl, LiteralExpr, Node, PrintStmt, ScanExpr, Stmt, TypeDecl, UnaryExpr, VarDecl }

pub fn parse(tokens []Token) ![]Node {
	mut p := new_parser(tokens)
	return p.parse()!
}

pub struct Parser {
	tokens []Token
	limit  int
mut:
	offset int
	span   Span
}

pub fn Parser.new(tokens []Token) Parser {
	return Parser{tokens, tokens.len, 0, Span.empty()}
}

pub fn new_parser(tokens []Token) Parser {
	return Parser.new(tokens)
}

pub fn (mut this Parser) parse() ![]Node {
	mut nodes := []Node{}
	for !this.is_eof() {
		nodes << this.parse_top_stmt()!
		this.next()
	}
	return nodes
}

fn (mut this Parser) parse_top_stmt() !Stmt {
	return if this.eat(.type) {
		Decl(TypeDecl{this.parse_expr()!, this.span_from_position()})
	} else if this.current().in([.name, .lpar, .lsbr, .lcbr]) {
		this.parse_decl()!
	} else {
		this.parse_stmt()!
	}
}

fn (mut this Parser) parse_stmt() !Stmt {
	return if this.eat(.print) {
		PrintStmt{this.parse_expr()!, this.span_from_position()}
	} else if this.eat(.for) {
		c := this.parse_expr()!
		this.expect(.lcbr)!
		b := this.parse_block([TokenType.rcbr, TokenType.else])!
		return if this.eat(.else) {
			this.current()
			this.expect(.lcbr)!
			ForStmt{c, b, this.parse_block([TokenType.rcbr])!, this.span_from_position()}
		} else {
			ForStmt{c, b, unsafe { nil }, this.span_from_position()}
		}
	} else if this.eat(.if) {
		c := this.parse_expr()!
		this.expect(.lcbr)!
		b := this.parse_block([TokenType.rcbr, TokenType.else])!
		return if this.eat(.else) {
			this.current()
			this.expect(.lcbr)!
			IfStmt{c, b, this.parse_block([TokenType.rcbr])!, this.span_from_position()}
		} else {
			IfStmt{c, b, unsafe { nil }, this.span_from_position()}
		}
	} else {
		Stmt(this.parse_expr()!)
	}
}

fn (mut this Parser) parse_block(delimiters []TokenType) !&Block {
	mut s := []Stmt{}
	for (this.remaining() > 0 && !this.current().in(delimiters)) {
		this.eat_any([.semicolon, .nl])
		s << this.parse_stmt()!
		if !this.is_eof() {
			this.expect_any([.semicolon, .nl])!
		}
	}
	if !(delimiters.len == 1 && TokenType.eof in delimiters) {
		this.expect_any(delimiters)!
	}
	return &Block{s, this.span_from_position()}
}

fn (mut this Parser) parse_decl() !Stmt {
	return if this.current().is(.name) && this.peek().is(.name) {
		Decl(this.parse_var_decl()!)
	} else if this.current().is(.lpar) && this.peek().is(.rpar) && this.peek_n(2).is(.name)
		&& this.peek_n(3).is(.name) {
		Decl(this.parse_list_decl()!)
	} else if this.current().is(.lsbr) && this.peek().is(.name) && this.peek_n(2).is(.rsbr)
		&& this.peek_n(3).is(.name) && this.peek_n(4).is(.name) {
		Decl(this.parse_array_decl()!)
	} else {
		this.parse_expr()!
	}
}

fn (mut this Parser) parse_var_decl() !VarDecl {
	var_type := this.current().val
	this.advance()
	return VarDecl{var_type, this.parse_expr()!, this.span_from_position()}
}

fn (mut this Parser) parse_list_decl() !ListDecl {
	this.expect(.lpar)!
	this.expect(.rpar)!
	item_type := this.current().val
	this.advance()
	return ListDecl{item_type, this.parse_expr()!, this.span_from_position()}
}

fn (mut this Parser) parse_array_decl() !ArrayDecl {
	this.expect(.lsbr)!
	key_type := this.current().val
	this.advance()
	this.expect(.rsbr)!
	value_type := this.current().val
	this.advance()
	return ArrayDecl{key_type, value_type, this.parse_expr()!, this.span_from_position()}
}

fn (mut this Parser) parse_expr() !Expr {
	this.eat(.nl)
	return this.parse_assign_expr()!
}

fn (mut this Parser) parse_assign_expr() !Expr {
	mut l := this.parse_scan_expr()!

	for this.eat(.assign) {
		l = AssignExpr{l, this.parse_scan_expr()!, this.span_from_position()}
	}

	return l
}

fn (mut this Parser) parse_scan_expr() !Expr {
	if this.eat(.scan) {
		return ScanExpr{this.parse_concat_expr()!, this.span_from_position()}
	}

	return this.parse_concat_expr()!
}

fn (mut this Parser) parse_concat_expr() !Expr {
	mut l := this.parse_term_expr()!

	for this.eat(.comma) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_term_expr()!, v, this.span_from_position()}
	}

	return l
}

fn (mut this Parser) parse_term_expr() !Expr {
	mut l := this.parse_factor_expr()!

	for this.eat_any([.plus, .minus]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_factor_expr()!, v, this.span_from_position()}
	}

	return l
}

fn (mut this Parser) parse_factor_expr() !Expr {
	mut l := this.parse_power_expr()!

	for this.eat_any([.mul, .div, .mod]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_power_expr()!, v, this.span_from_position()}
	}

	return l
}

fn (mut this Parser) parse_power_expr() !Expr {
	mut r := this.parse_unary_expr()!

	for this.eat(.power) {
		v := this.peek_back().val
		r = BinaryExpr{this.parse_unary_expr()!, r, v, this.span_from_position()}
	}

	return r
}

fn (mut this Parser) parse_unary_expr() !Expr {
	if this.eat_any([.plus, .minus, .not]) {
		v := this.peek_back().val
		return UnaryExpr{this.parse_literal_expr()!, v, this.span_from_position()}
	}

	return this.parse_literal_expr()!
}

fn (mut this Parser) parse_literal_expr() !Expr {
	mut t := this.next()

	if t.in([.name, .bool, .number, .string, .backticks]) {
		return LiteralExpr{t.name(), t.val, this.span_from(t.pos)}
	}

	if t.is(.lpar) {
		mut expr := this.parse_expr()!
		this.expect(.rpar)!
		this.next()
		return expr
	}

	return parser_error('Unexpected token ${t.val}', this.span_from(t.pos))
}

fn (mut this Parser) span_from_position() Span {
	return this.span_from(this.position())
}

fn (mut this Parser) span_to_position() Span {
	return this.span_to(this.position())
}

fn (mut this Parser) span_from(pos Position) Span {
	this.span = this.span.from_position(pos)
	return this.span
}

fn (mut this Parser) span_to(pos Position) Span {
	this.span = this.span.to_position(pos)
	return this.span
}

fn (this Parser) position() Position {
	return this.current().pos
}

fn (mut this Parser) expect(type TokenType) !Token {
	return this.eat_or_fail(type, '${token_to_str(type)} expected but ${this.current().val} provided')!
}

fn (mut this Parser) expect_any(types []TokenType) !Token {
	return this.eat_any_or_fail(types, '${tokens_to_str(types)} expected but ${this.current().val} provided')!
}

fn (mut this Parser) eat(type TokenType) bool {
	if this.current().is(type) {
		this.advance()
		return true
	}
	return false
}

fn (mut this Parser) eat_any(types []TokenType) bool {
	if this.current().in(types) {
		this.advance()
		return true
	}
	return false
}

fn (mut this Parser) eat_or_fail(type TokenType, msg string) !Token {
	token := this.current()
	if this.eat(type) {
		return token
	}
	return parser_error(msg, this.span_from(token.pos))
}

fn (mut this Parser) eat_any_or_fail(types []TokenType, msg string) !Token {
	token := this.current()
	if this.eat_any(types) {
		return token
	}
	return parser_error(msg, this.span_from(token.pos))
}

fn (this &Parser) is_eof() bool {
	return this.peek().is(.eof)
}

@[inline]
fn (this &Parser) remaining() int {
	return this.limit - this.offset
}

@[direct_array_access; inline]
fn (mut this Parser) next() Token {
	o := this.offset++
	if o < this.limit {
		return this.tokens[o]
	}
	return Token.eof(this.position())
}

@[inline]
fn (mut this Parser) skip() {
	if this.offset < this.limit {
		this.offset++
	}
}

@[inline]
fn (mut this Parser) skip_n(n int) {
	this.offset += n
	if this.offset > this.limit {
		this.offset = this.limit
	}
}

@[direct_array_access; inline]
fn (this &Parser) peek() Token {
	return this.peek_n(1)
}

@[direct_array_access; inline]
fn (this &Parser) peek_n(n int) Token {
	o := this.offset + n
	if o < this.limit {
		return this.tokens[o]
	}
	return Token.eof(this.position())
}

@[inline]
fn (mut this Parser) advance() {
	if this.offset < this.limit {
		this.offset++
	}
}

fn (mut this Parser) advance_n(n int) {
	this.offset += n
	if this.offset > this.limit {
		this.offset = this.limit
	}
}

@[inline]
fn (mut this Parser) back() {
	if this.offset > 0 {
		this.offset--
	}
}

fn (mut this Parser) back_n(n int) {
	this.offset -= n
	if this.offset < 0 {
		this.offset = 0
	}
}

@[direct_array_access; inline]
fn (this &Parser) peek_back() Token {
	return this.peek_back_n(1)
}

@[direct_array_access; inline]
fn (this &Parser) peek_back_n(n int) Token {
	if this.offset >= n {
		return this.tokens[this.offset - n]
	}
	return Token.eof(this.position())
}

@[direct_array_access; inline]
fn (this Parser) current() Token {
	if this.offset <= this.limit {
		return this.tokens[this.offset]
	}
	mut pos := this.peek_back().pos
	return Token.eof(pos.next_column())
}

fn (mut this Parser) reset() {
	this.offset = 0
}

fn (mut this Parser) goto_eof() {
	this.offset = this.limit
}

@[unsafe]
fn (mut this Parser) free() {
	unsafe {
		this.tokens.free()
	}
}
