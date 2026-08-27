module compiler

import os
import sync
import compiler.ast { Node }
import compiler.eval

@[params]
pub struct RuntimeOptions {
pub mut:
	file string
	dir  string
}

pub struct Runtime {
	input string
	file  string
	dir   string
pub mut:
	tokens []Token
	nodes  []Node
}

pub fn Runtime.new(input string, options RuntimeOptions) Runtime {
	return Runtime{
		input: input
		file:  options.file
		dir:   options.dir
	}
}

pub fn new_runtime(input string, options RuntimeOptions) Runtime {
	return Runtime.new(input, options)
}

pub fn (mut r Runtime) execute() ! {
	r.tokens = tokenize(r.input, file: r.file, dir: r.dir)!
	r.parse()!
}

pub fn (mut r Runtime) parse() ! {
	r.nodes = parse(r.tokens)!
	r.eval()!
}

pub fn (r Runtime) eval() ! {
	eval.eval(r.nodes)!
}

pub fn run(code string, options RuntimeOptions) ! {
	mut path := code
	if !os.exists(path) && !path.ends_with('.oty') {
		path += '.oty'
	}

	if os.exists(path) {
		run_path(path)!
	} else {
		run_code(code, options)!
	}
}

pub fn run_path(path string, options RuntimeOptions) ! {
	if os.is_dir(path) {
		for file in os.ls(path) or { []string{} } {
			run_path('${path}/${file}', dir: path)!
		}
	} else {
		run_file(path, options)!
	}
}

pub fn run_file(file string, options RuntimeOptions) ! {
	code := os.read_file(file) or { panic(err) }
	run_code(code, file: file, dir: options.dir)!
}

pub fn run_code(code string, options RuntimeOptions) ! {
	mut r := new_runtime(code, options)
	r.execute()!
}

pub fn run_many(inputs []string, options RuntimeOptions) ! {
	for input in inputs {
		run(input, options)!
	}
}

pub fn run_many_concurrently(inputs []string, options RuntimeOptions) ! {
	mut wg := sync.new_waitgroup()
	wg.add(inputs.len)
	defer {
		wg.done()
	}
	for input in inputs {
		go fn [input, options, mut wg] () ! {
			defer {
				wg.done()
			}
			run(input, options) or {
				wg.done()
				return err
			}
		}()
	}
	wg.wait()
}
