module compiler

import compiler.core { Position }

pub enum TokenType {
	amp // &
	and // &&
	and_assign // &=
	arrow // <-
	assign // =
	at // @
	await
	backticks // `ls -la`
	bit_not // ~
	boolean_and_assign // &&=
	boolean_or_assign // ||=
	colon // :
	comma // ,
	comment
	dec // --
	decl_assign // :=
	diff // <>
	div // /
	div_assign // /=
	dollar // $
	dot // .
	dotdot // ..
	ellipsis // ...
	eof
	eq // ==
	float // .456
	ge // >=
	gt // >
	hash // #
	inc // ++
	int // 123
	lcbr // {
	ldoc // <!
	le // <=
	left_shift // <<
	left_shift_assign // >>=
	logical_or // ||
	lpar // (
	lsbr // [
	lt // <
	ltag // <?
	minus // -
	minus_assign // -=
	mod // %
	mod_assign // %=
	mul // *
	mul_assign // *=
	name // abc
	ne // !=
	nl
	not // !
	not_in // !in
	not_is // !is
	number // 123.456
	or_assign // |=
	pipe // |
	plus // +
	plus_assign // +=
	power // **
	question // ?
	rcbr // }
	rdoc // !>
	right_shift // >>
	right_shift_assign // <<=
	rpar // )
	rsbr // ]
	rtag // ?>
	semicolon // ;
	str_dollar
	string // "foo"
	unknown
	unsigned_right_shift // >>>
	unsigned_right_shift_assign // >>>=
	whitespace
	xor // ^
	xor_assign // ^=

	// Keywords
	as
	assert
	bool
	break
	case
	continue
	debug
	do
	dump
	else
	emit
	ensure
	exit
	extends
	false
	for
	if
	in
	is
	let
	nil
	on
	print
	private
	protected
	public
	return
	scan
	spawn
	static
	true
	type
	unset
	use
}

@[params]
pub struct TokenOptions {
	type TokenType
	pos  Position
	val  string
}

pub struct Token {
	type TokenType
	val  string
	size int
mut:
	pos Position
}

pub fn token_to_str(type TokenType) string {
	return match type {
		.amp {
			'&'
		}
		.and {
			'&&'
		}
		.and_assign {
			'&='
		}
		.arrow {
			'<-'
		}
		.assign {
			'='
		}
		.at {
			'@'
		}
		.bit_not {
			'~'
		}
		.boolean_and_assign {
			'&&='
		}
		.boolean_or_assign {
			'||='
		}
		.colon {
			':'
		}
		.comma {
			','
		}
		.dec {
			'--'
		}
		.decl_assign {
			':='
		}
		.diff {
			'<>'
		}
		.div {
			'/'
		}
		.div_assign {
			'/='
		}
		.dollar {
			'\$'
		}
		.dot {
			'.'
		}
		.dotdot {
			'..'
		}
		.ellipsis {
			'...'
		}
		.eof {
			'EOF'
		}
		.eq {
			'=='
		}
		.ge {
			'>='
		}
		.gt {
			'>'
		}
		.hash {
			'#'
		}
		.inc {
			'++'
		}
		.ldoc {
			'<!'
		}
		.lcbr {
			'{'
		}
		.le {
			'<='
		}
		.left_shift {
			'<<'
		}
		.left_shift_assign {
			'>>='
		}
		.logical_or {
			'||'
		}
		.lpar {
			'('
		}
		.lsbr {
			'['
		}
		.lt {
			'<'
		}
		.ltag {
			'<?'
		}
		.minus {
			'-'
		}
		.minus_assign {
			'-='
		}
		.mod {
			'%'
		}
		.mod_assign {
			'%='
		}
		.mul {
			'*'
		}
		.mul_assign {
			'*='
		}
		.ne {
			'!='
		}
		.nl {
			'\n'
		}
		.not {
			'!'
		}
		.not_in {
			'!in'
		}
		.not_is {
			'!is'
		}
		.or_assign {
			'|='
		}
		.pipe {
			'|'
		}
		.plus {
			'+'
		}
		.plus_assign {
			'+='
		}
		.power {
			'**'
		}
		.question {
			'?'
		}
		.rcbr {
			'}'
		}
		.rdoc {
			'!>'
		}
		.right_shift {
			'>>'
		}
		.right_shift_assign {
			'<<='
		}
		.rpar {
			')'
		}
		.rsbr {
			']'
		}
		.rtag {
			'?>'
		}
		.semicolon {
			';'
		}
		.unsigned_right_shift {
			'>>>'
		}
		.unsigned_right_shift_assign {
			'>>>='
		}
		.xor {
			'^'
		}
		.xor_assign {
			'^='
		}
		else {
			type.str()
		}
	}
}

pub fn tokens_to_str(types []TokenType) string {
	mut s := ''
	for type in types {
		s += ' ${token_to_str(type)}'
	}
	return s.trim(' ')
}

pub fn (this Token) is(type TokenType) bool {
	return this.type == type
}

pub fn (this Token) in(types []TokenType) bool {
	for type in types {
		if this.is(type) {
			return true
		}
	}
	return false
}

pub fn (this Token) name() string {
	return token_to_str(this.type)
}

pub fn (this Token) val_is(val string) bool {
	return this.val == val || this.name() == val
}

pub fn (this Token) val_in(vals []string) bool {
	for val in vals {
		if this.val_is(val) {
			return true
		}
	}
	return false
}

pub fn Token.new(opts TokenOptions) Token {
	val := if opts.val.len > 0 {
		opts.val
	} else {
		token_to_str(opts.type)
	}
	return Token{opts.type, val, val.len, opts.pos}
}

pub fn new_token(type TokenType, val string, pos Position) Token {
	return Token.new(type: type, val: val, pos: pos)
}

pub fn new_keyword(keyword TokenType, pos Position) Token {
	return new_token(keyword, keyword.str(), pos)
}

pub fn (this Token) is_keyword() bool {
	return token_to_str(this.type) == this.val
}

pub fn Token.eof(pos Position) Token {
	return new_token(.eof, 'EOF', pos)
}

pub fn Token.symbols() []TokenType {
	return [
		TokenType.ne,
		.right_shift_assign,
		.left_shift,
		.arrow,
		.ltag,
		.ldoc,
		.le,
		.lt,
		.unsigned_right_shift_assign,
		.unsigned_right_shift,
		.left_shift_assign,
		.right_shift,
		.ge,
		.gt,
		.boolean_or_assign,
		.or_assign,
		.logical_or,
		.pipe,
		.ellipsis,
		.dotdot,
		.dot,
		.at,
		.bit_not,
		.comma,
		.dollar,
		.hash,
		.lpar,
		.lcbr,
		.lsbr,
		.rpar,
		.rcbr,
		.rsbr,
		.semicolon,
		.not_is,
		.not_in,
		.ne,
		.rdoc,
		.not,
		.boolean_and_assign,
		.and,
		.and_assign,
		.amp,
		.rtag,
		.question,
		.eq,
		.assign,
		.decl_assign,
		.colon,
		.xor_assign,
		.xor,
		.power,
		.mul_assign,
		.mul,
		.div_assign,
		.div,
		.mod_assign,
		.mod,
		.plus_assign,
		.inc,
		.plus,
		.minus_assign,
		.dec,
		.minus,
	]
}
