module core

@[params]
pub struct ErrorOptions {
pub:
	pos  Position
	span Span
}

struct CompilerError {
	Error
	type string @[required]
	msg  string
	span Span
	pos  Position
}

fn compiler_error(type string, msg string, opts ErrorOptions) CompilerError {
	return CompilerError{
		type: type
		msg: msg
		pos: opts.pos
		span: opts.span
	}
}

pub fn scanner_error(msg string, pos Position) CompilerError {
	return compiler_error('scanner', msg, pos: pos)
}

pub fn parser_error(msg string, span Span) CompilerError {
	return compiler_error('parser', msg, span: span)
}

pub fn runtime_error(msg string, opts ErrorOptions) CompilerError {
	return compiler_error('runtime', msg, opts)
}

pub fn (e CompilerError) msg() string {
	mut msg := 'Compiler ${e.type} error: ${e.msg}'
	mut span := e.span

	if span.is_empty() {
		mut p := e.pos
		if e.pos.file.len > 0 {
			msg += ' in ${e.pos.file}'
		}
		msg += ' on line ${p.line}:${p.column}'
	} else {
		mut start := span.start
		mut end := span.end
		if start.file.len > 0 {
			msg += ' in ${start.file}'
		}
		if end.is_empty() {
			msg += ' on line ${start.line}:${start.column}'
		} else {
			if end.line < start.line || (end.line == start.line && end.column < start.column) {
				start, end = end, start
			}
			msg += ' from line ${start.line}:${start.column} to ${end.line}:${end.column}'
		}
	}

	return msg
}
