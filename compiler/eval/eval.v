module eval

import compiler.ast
import compiler.core { Span, runtime_error }
import compiler.checker { is_bool, is_float, is_int }

pub struct Var {
pub mut:
	type    Type
	value   Value
	mutable bool
}

pub struct Eval {
mut:
	types map[string]Type
	vars  map[string]Var
	ctx   Context
}

pub fn Eval.new() Eval {
	return Eval{}
}

pub fn new_eval() Eval {
	return Eval.new()
}

pub fn eval(nodes []ast.Node) ! {
	mut ev := new_eval()
	ev.eval(nodes)!
}

pub fn (mut this Eval) define_type(name string, type Type, span Span) ! {
	if defined := this.types[name] {
		return runtime_error('Type ${name} as ${defined.str()} is already defined', span: span)
	}
	this.types[name] = type
}

pub fn (mut this Eval) init_var(type Type, name string, value Value, span Span) ! {
	is_valid := if value !is Nil && type is BuiltinType {
		(type.is(.bool) && value.is_bool()) || (type.is(.int) && value.is_int())
			|| (type.is(.float) && value.is_float())
			|| (type.is(.string) && value.is_string())
	} else {
		true
	}
	if !is_valid {
		return runtime_error('Invalid type for variable ${name} (got ${value.type_name()} expected ${type.str()})',
			span: span
		)
	} else {
		this.vars[name] = Var{
			type: type
			value: value
			mutable: name.starts_with('\$')
		}
	}
}

pub fn (mut this Eval) set_var(name string, value Value, span Span) ! {
	if var_def := this.vars[name] {
		if !var_def.mutable {
			return runtime_error('Cannot set constant ${name}. Use \$${name} instead.', span: span)
		}
		this.vars[name].value = value
	} else {
		return runtime_error('Cannot set variable ${name}. Define it before.', span: span)
	}
}

pub fn (this Eval) get_var(name string, span Span) !Value {
	if var_def := this.vars[name] {
		return var_def.value
	} else {
		kind := if name.starts_with('\$') { 'variable' } else { 'constant' }
		return runtime_error('Undefined ${kind} ${name}', span: span)
	}
}

pub fn (mut this Eval) eval(nodes []ast.Node) ! {
	for node in nodes {
		this.eval_node(node)!
	}
}

pub fn (mut this Eval) eval_node(n ast.Node) ! {
	match n {
		ast.Block {
			this.eval_block(n)!
		}
		ast.Stmt {
			this.eval_stmt(n)!
		}
		ast.EmptyNode {
			this.eval_empty(n)
		}
	}
}
