module eval

type Value = int | f64 | string | bool | Nil

type BinaryValue = int | string

struct Nil {}

@[inline]
fn (v Value) is_bool() bool {
	return if v is bool {
		true
	} else {
		false
	}
}

@[inline]
fn (v Value) is_int() bool {
	return if v is int {
		true
	} else {
		false
	}
}

@[inline]
fn (v Value) is_float() bool {
	return if v is f64 {
		true
	} else {
		false
	}
}

@[inline]
fn (v Value) is_string() bool {
	return if v is string {
		true
	} else {
		false
	}
}

@[inline]
fn (v Value) is_nil() bool {
	return if v is Nil {
		true
	} else {
		false
	}
}

@[inline]
fn (v Value) to_int() int {
	return match v {
		string {
			v.int()
		}
		int {
			v
		}
		f64 {
			int(v)
		}
		bool {
			return if v {
				1
			} else {
				0
			}
		}
		Nil {
			return 0
		}
	}
}

@[inline]
fn (v Value) to_float() f64 {
	return match v {
		string {
			v.f64()
		}
		int {
			f64(v)
		}
		f64 {
			v
		}
		bool {
			return if v {
				1.0
			} else {
				0.0
			}
		}
		Nil {
			return 0.0
		}
	}
}

@[inline]
fn (v Value) to_str() string {
	return match v {
		string {
			v
		}
		f64, int, bool {
			v.str()
		}
		Nil {
			''
		}
	}
}

@[inline]
fn (v Value) to_bool() bool {
	return match v {
		string {
			v != '0' && v.len > 0
		}
		int {
			v != 0
		}
		f64 {
			v != 0.0
		}
		bool {
			v
		}
		Nil {
			false
		}
	}
}
