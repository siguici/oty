module compiler

import strings.textscanner
import compiler.core { Position, scanner_error }

@[params]
pub struct ScannerOptions {
	file string
	dir  string
	line int = 1
	col  int = 1
}

@[noinit]
pub struct Scanner {
	textscanner.TextScanner
pub:
	file string
	dir  string
pub mut:
	line int = 1
	col  int = 1
}

pub fn Scanner.new(input string, options ScannerOptions) Scanner {
	return Scanner{
		TextScanner: textscanner.new(input)
		file: options.file
		dir: options.dir
		line: options.line
		col: options.col
	}
}

pub fn new_scanner(input string, options ScannerOptions) Scanner {
	return Scanner.new(input, options)
}

pub fn tokenize(input string, options ScannerOptions) ![]Token {
	mut sc := new_scanner(input, options)
	return sc.tokenize()!
}

pub fn (mut this Scanner) tokenize() ![]Token {
	mut t := []Token{}

	for this.pos != this.ilen {
		c := this.scan()!
		if !c.is(.whitespace) {
			t << c
		}
	}

	if !this.current_is_space() {
		t << this.scan()!
	}

	return t
}

fn (mut this Scanner) scan() !Token {
	for symbol in Token.symbols() {
		if lexeme := this.eat(symbol) {
			if symbol == .dollar {
				id := this.scan_identifier()
				if id.len >= 1 {
					this.pos--
					return this.token(.name, '\$${id}')
				}
			}
			return this.token(symbol, lexeme)
		}
	}
	this.next()
	c := this.current_u8()
	match c {
		`'`, `"`, `\`` {
			ss := this.scan_string(this.current())!
			if ss.len >= 1 {
				return if c == `\`` {
					this.token(.backticks, ss)
				} else {
					this.token(.string, ss)
				}
			}
		}
		else {
			nl := this.scan_newline()
			if nl.len >= 1 {
				this.pos--
				return this.token(.nl, nl)
			}

			sp := this.scan_whitespace()
			if sp.len >= 1 {
				this.pos--
				return this.token(.whitespace, sp)
			}

			nb := this.scan_number()
			if nb.len >= 1 {
				this.pos--
				return this.token(.number, nb)
			}

			id := this.scan_identifier()
			if id.len >= 1 {
				this.pos--
				return match id {
					'true', 'false' {
						this.token(.bool, id)
					}
					'type' {
						this.keyword(.type)
					}
					'print' {
						this.keyword(.print)
					}
					'scan' {
						this.keyword(.scan)
					}
					'if' {
						this.keyword(.if)
					}
					'for' {
						this.keyword(.for)
					}
					'else' {
						this.keyword(.else)
					}
					else {
						this.token(.name, id)
					}
				}
			}
		}
	}

	return this.token(.unknown, c.ascii_str())
}

fn (mut this Scanner) eat(type TokenType) ?string {
	lexeme := token_to_str(type)
	return if this.eat_lexeme(lexeme) {
		lexeme
	} else {
		none
	}
}

fn (mut this Scanner) eat_lexeme(lexeme string) bool {
	runes := lexeme.runes()
	mut pos := 0
	mut line := 0
	mut col := 0
	for pos < runes.len {
		if this.peek_n_u8(pos) != runes[pos] {
			return false
		}
		if runes[pos] == `\n` {
			line++
			col = 0
		} else {
			line++
		}
		pos++
	}
	this.pos += pos
	this.line += line
	this.col += col
	return true
}

fn (mut this Scanner) scan_string(delimiter int) !string {
	this.col++
	this.next()
	mut v := ''
	mut end := false

	for (this.pos < this.ilen) {
		if this.current() == delimiter && this.peek_back() != `\\` {
			end = true
			break
		}
		if this.current() == `\\` {
			v += match this.peek_u8() {
				`n` {
					'\n'
				}
				`r` {
					'\r'
				}
				`t` {
					'\t'
				}
				`\\` {
					'\\'
				}
				u8(delimiter) {
					u8(delimiter).ascii_str()
				}
				else {
					return scanner_error('Cannot escape ${this.peek_u8().ascii_str()}', this.position())
				}
			}

			this.col += 2
			this.next()
			this.next()
			continue
		}
		if this.current_is_new_line() {
			this.line++
			this.col = 1
		} else {
			this.col++
		}
		v += this.current_str()
		this.next()
	}

	if this.peek() == -1 && this.current() == delimiter {
		end = true
		this.next()
	}

	if !end {
		return scanner_error('End of string ${u8(delimiter).ascii_str()} expected', this.position())
	}

	return v
}

fn (mut this Scanner) scan_newline() string {
	mut w := ''

	for (this.pos < this.ilen || this.peek() != -1) && this.current_is_new_line() {
		this.line++
		this.col = 1
		w += this.current_str()
		this.next()
	}

	return w
}

fn (mut this Scanner) scan_whitespace() string {
	mut w := ''

	for (this.pos < this.ilen || this.peek() != -1) && this.current_is_space()
		&& !this.current_is_new_line() {
		w += this.current_str()
		this.col++
		this.next()
	}

	return w
}

fn (mut this Scanner) scan_number() string {
	mut nb := ''

	if this.current_is_digit() || (this.current_is_dot() && this.peek_is_digit()) {
		nb += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1) && this.current_is_digit() {
			nb += this.current_str()
			this.col++
			this.next()
		}
	}

	if !nb.contains('.') && this.current_is_dot() && this.peek_is_digit() {
		nb += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1) && this.current_is_digit() {
			nb += this.current_str()
			this.col++
			this.next()
		}
	}

	return nb
}

fn (mut this Scanner) scan_identifier() string {
	mut id := ''

	if this.current_is_underscore() || this.current_is_letter()
		|| (this.current_is_dollar() && this.peek_is_letter()) {
		id += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1)
			&& (this.current_is_digit() || this.current_is_underscore()
				|| this.current_is_letter()) {
			id += this.current_str()
			this.col++
			this.next()
		}
	}

	return id
}

fn (mut this Scanner) current_u8() u8 {
	return u8(this.current())
}

fn (mut this Scanner) current_str() string {
	return this.current_u8().ascii_str()
}

fn (mut this Scanner) current_is_space() bool {
	return this.current_u8().is_space()
}

fn (mut this Scanner) current_is_digit() bool {
	return this.current_u8().is_digit()
}

fn (mut this Scanner) current_is_letter() bool {
	return this.current_u8().is_letter()
}

fn (mut this Scanner) current_is_dollar() bool {
	return this.current_u8() == `$`
}

fn (mut this Scanner) current_is_new_line() bool {
	return this.current_u8() == `\n`
}

fn (mut this Scanner) current_is_dot() bool {
	return this.current_u8() == `.`
}

fn (mut this Scanner) current_is_underscore() bool {
	return this.current_u8() == `_`
}

fn (mut this Scanner) peek_str() string {
	return this.peek_u8().ascii_str()
}

fn (mut this Scanner) peek_is_space() bool {
	return this.peek_u8().is_space()
}

fn (mut this Scanner) peek_is_digit() bool {
	return this.peek_u8().is_digit()
}

fn (mut this Scanner) peek_is_letter() bool {
	return this.peek_u8().is_letter()
}

fn (mut this Scanner) peek_is_dollar() bool {
	return this.peek_u8() == `$`
}

fn (mut this Scanner) peek_is_new_line() bool {
	return this.peek_u8() == `\n`
}

fn (mut this Scanner) position() Position {
	return this.position_n(0)
}

fn (mut this Scanner) position_n(n int) Position {
	return Position.new(
		file: this.file
		offset: this.pos
		line: this.line
		column: this.col - n
	)
}

fn (mut this Scanner) token(type TokenType, value string) Token {
	return new_token(type, value, this.position_n(value.len))
}

fn (mut this Scanner) keyword(keyword TokenType) Token {
	return new_keyword(keyword, this.position_n(token_to_str(keyword).len))
}
