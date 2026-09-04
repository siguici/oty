module compiler

import os
import json2
import net.http

const version = '0.1.0'
const repo = 'siguici/oty'

struct ReleaseAsset {
	name                 string
	browser_download_url string
}

struct Release {
	tag_name string
	assets   []ReleaseAsset
}

pub fn do_release() {
	v := os.real_path(os.getenv_opt('VEXE') or { @VEXE })
	os.system('${v} retry v -prod -d version=\$(git describe --tags) .')
}

pub fn self_upgrade_to(version string) {
	// TODO
	eprintln('Not implemented.')
	println('Upgrading to ${version}')
}

pub fn self_update() {
	println('🔎 Updates verification...')

	resp := http.get('https://api.github.com/repos/${repo}/releases/latest') or {
		eprintln('❌ Unable to access GitHub: ${err}')
		return
	}

	release := json2.decode[Release](resp.body) or {
		eprintln('❌ JSON error: ${err}')
		return
	}

	os_name := os.user_os().to_lower()
	/*
	 * TODO: Get by arch
	arch := match os.user_arch() {
		.amd64 {
			'amd64'
		}
		.arm64 {
			'arm64'
		}
		else {
			eprintln('❌ Architecture not supported: ${os.arch()}')
			return
		}
	}
	asset_name := 'oty-${os_name}-${arch}' + if os_name == 'windows' { '.exe' } else { '' }
	*/
	arch := ''
	asset_name := 'oty-${os_name}' + if os_name == 'windows' { '.exe' } else { '' }

	mut download_url := ''
	for a in release.assets {
		if a.name == asset_name {
			download_url = a.browser_download_url
			break
		}
	}
	if download_url == '' {
		eprintln('❌ Unable to find binary for ${os_name}/${arch}')
		return
	}

	println('⬇️ Downloading ${asset_name} from ${download_url}')

	new_bin := os.join_path(os.temp_dir(), asset_name)
	http.download_file(download_url, new_bin) or {
		eprintln('❌ Download failed: ${err}')
		return
	}

	current := os.executable()
	os.mv(new_bin, current) or {
		eprintln('❌ Unable to replace the current binary: ${err}')
		return
	}
	os.chmod(current, 0o755) or {}

	println('✅ Updated successfuly to ${release.tag_name}')
}

pub fn self_upgrade() {
	println('🔄 Full Oty upgrade...')

	self_update()

	// TODO: update all Oty modules/dependencies
	println('⬆️ Updating Oty modules...')

	// os.system("oty modules upgrade")
	// os.system("oty templates update")

	println('✅ Global upgrade terminated.')
}
