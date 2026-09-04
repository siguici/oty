module core

pub struct Span {
pub:
	start Position
	end   Position
}

pub fn Span.new(start Position, end Position) Span {
	return Span{
		start: start
		end: end
	}
}

pub fn Span.empty() Span {
	return Span.new(Position.new(), Position.new())
}

pub fn (s Span) from_position(p Position) Span {
	return Span.new(p, s.start)
}

pub fn (s Span) to_position(p Position) Span {
	return Span.new(s.end, p)
}

pub fn (s Span) is_empty() bool {
	return s.start.is_empty() && s.end.is_empty()
}

pub fn (s Span) len() int {
	return s.end.offset - s.start.offset
}

pub fn (s Span) merge(other Span) Span {
	return Span.new(min_position(s.start, other.start), max_position(s.end, other.end))
}

pub fn (s Span) contains(pos Position) bool {
	if pos.file != s.start.file || pos.file != s.end.file {
		return false
	}
	return pos >= s.start && pos <= s.end
}

pub fn (a Span) <(b Span) bool {
	return a.start < b.start
}

pub fn (a Span) ==(b Span) bool {
	return a.start == b.start && a.end == b.end
}
