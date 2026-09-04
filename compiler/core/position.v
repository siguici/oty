module core

pub struct Position {
pub:
	file string
pub mut:
	offset int
	line   int
	column int
}

@[params]
pub struct PositionOptions {
pub:
	file   string
	offset int
	line   int
	column int
}

pub fn Position.new(opts PositionOptions) Position {
	return Position{
		file: opts.file
		offset: opts.offset
		line: opts.line
		column: opts.column
	}
}

pub fn (p Position) is_empty() bool {
	return p.offset == 0
}

pub fn (mut p Position) next_line() Position {
	p.offset++
	p.line++
	p.column = 0
	return p
}

pub fn (mut p Position) next_line_n(n int) Position {
	p.offset += n
	p.line += n
	p.column = 0
	return p
}

pub fn (mut p Position) next_column() Position {
	p.offset++
	p.column++
	return p
}

pub fn (mut p Position) next_column_n(n int) Position {
	p.offset += n
	p.column += n
	return p
}

pub fn max_position(a Position, b Position) Position {
	if a.file != b.file {
		return if a.offset > b.offset { a } else { b }
	}
	if a.line != b.line {
		return if a.line > b.line { a } else { b }
	}
	if a.column != b.column {
		return if a.column > b.column { a } else { b }
	}
	return if a.offset > b.offset { a } else { b }
}

pub fn min_position(a Position, b Position) Position {
	if a.file != b.file {
		return if a.offset < b.offset { a } else { b }
	}
	if a.line != b.line {
		return if a.line < b.line { a } else { b }
	}
	if a.column != b.column {
		return if a.column < b.column { a } else { b }
	}
	return if a.offset < b.offset { a } else { b }
}

pub fn (a Position) +(b Position) Position {
	return max_position(a, b)
}

pub fn (a Position) -(b Position) Position {
	return min_position(a, b)
}

pub fn (a Position) <(b Position) bool {
	if a.file != b.file {
		return false
	}
	return a.line < b.line || (a.line == b.line && a.column < b.column)
}

pub fn (a Position) ==(b Position) bool {
	if a.file != b.file {
		return false
	}
	return a.line == b.line && a.column == b.column
}
