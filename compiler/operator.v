module compiler

struct OperatorInfo {
	prec  int = -1 // precedence
	assoc string = 'left' // associativity 'left' or 'right'
}

@[params]
pub struct OperatorOptions {
	OperatorInfo
	tok TokenType
}

pub struct Operator {
	OperatorInfo
	tok TokenType
}

pub fn Operator.new(tok TokenType) Operator {
	return Operator{OperatorInfo{Operator.precedence(tok), Operator.associativity(tok)}, tok}
}

pub fn new_op(tok TokenType) Operator {
	return Operator.new(tok)
}

pub fn Operator.precedence(tok TokenType) int {
	return match tok {
		.lpar, .lcbr, .lsbr { 18 }
		.dot { 17 }
		.power { 16 }
		.mul, .div, .mod { 15 }
		.plus, .minus { 14 }
		.left_shift, .right_shift, .unsigned_right_shift { 13 }
		.lt, .le, .gt, .ge { 12 }
		.eq, .ne { 11 }
		.amp { 10 }
		.xor { 9 }
		.pipe { 8 }
		.and { 7 }
		.logical_or { 6 }
		.question { 5 }
		.plus_assign, .minus_assign, .mul_assign, .div_assign, .mod_assign { 4 }
		.and_assign, .or_assign, .xor_assign { 3 }
		.left_shift_assign, .right_shift_assign, .unsigned_right_shift_assign { 2 }
		.boolean_and_assign, .boolean_or_assign { 1 }
		.comma { 0 }
		else { -1 }
	}
}

pub fn Operator.associativity(tok TokenType) string {
	return match tok {
		.power, .question, .plus_assign, .minus_assign, .mul_assign, .div_assign, .mod_assign, .and_assign, .or_assign, .xor_assign, .left_shift_assign, .right_shift_assign, .unsigned_right_shift_assign, .boolean_and_assign, .boolean_or_assign {
			'right'
		}
		else {
			'left'
		}
	}
}

pub fn Operator.is_prefix(tok TokenType) bool {
	return match tok {
		.inc, .dec { true }
		else { false }
	}
}

pub fn Operator.is_assign(tok TokenType) bool {
	return match tok {
		.eq, .decl_assign, .plus_assign, .minus_assign, .mul_assign, .div_assign, .mod_assign, .and_assign, .or_assign, .xor_assign, .boolean_and_assign, .boolean_or_assign, .left_shift_assign, .right_shift_assign, .unsigned_right_shift_assign {
			true
		}
		else {
			false
		}
	}
}

pub fn Operator.is_postfix(tok TokenType) bool {
	return tok in [.inc, .dec]
}

pub fn Operator.is_unary(tok TokenType) bool {
	return tok in [.plus, .minus, .not, .bit_not]
}

pub fn Operator.is_binary(tok TokenType) bool {
	return tok in [.plus, .minus, .not, .bit_not]
}

pub fn Operator.is_ternary(tok TokenType) bool {
	return tok == .question
}

pub fn Operator.is_opening(tok TokenType) bool {
	return tok in [
		.lpar,
		.lcbr,
		.lsbr,
		.ltag,
		.ldoc,
	]
}

pub fn (this Operator) close(tok TokenType) bool {
	return match tok {
		.rpar {
			tok == .lpar
		}
		.rcbr {
			tok == .lcbr
		}
		.rsbr {
			tok == .lsbr
		}
		.rtag {
			tok == .ltag
		}
		.rdoc {
			tok == .ldoc
		}
		else {
			false
		}
	}
}
