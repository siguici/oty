module main

import os

const vexe = os.real_path(os.getenv_opt('VEXE') or { @VEXE })

fn test_examples() {
	r := os.execute('${vexe} run . examples/test')
	assert r.exit_code == 0
	assert r.output.ends_with('Enjoy Phi!\n')
}
