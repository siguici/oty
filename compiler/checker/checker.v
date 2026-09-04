module checker

import compiler.ast

pub fn check(node ast.Node) bool {
	return true
}

pub fn is_bool[T](v T) bool {
	return $if v is bool { true } $else { false }
}

pub fn is_nil[T](v T) bool {
	return isnil(v)
}

pub fn is_true(v bool) bool {
	return v
}

pub fn is_false(v bool) bool {
	return !v
}

pub fn is_int[T](v T) bool {
	return $if v is $int { true } $else { false }
}

pub fn is_float[T](v T) bool {
	return $if v is $float { true } $else { false }
}

pub fn is_num[T](v T) bool {
	return $if v is $int || v is $float { true } $else { false }
}

pub fn is_str[T](v T) bool {
	return $if v is $string { true } $else { false }
}
