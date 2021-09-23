#!/bin/bash
CONFIG=`cat ppa-config.json`
repos=`echo "${CONFIG}" | jq -r ".repos[]"`
distros=`echo "${CONFIG}" | jq -c ".distros[]"`

if [[ -n "${repos}" ]]; then
	for repo in $repos; do
		echo "https://api.github.com/repos/${repo}/releases/latest"
		release=`curl -sL https://api.github.com/repos/${repo}/releases/latest`
		assets=`echo "${release}" | jq -c ".assets[]"`
		if [[ -n "${assets}" ]]; then
			for asset in $assets; do
				name=`echo "${asset}"| jq -r ".name"`
				url=`echo "${asset}"| jq -r ".browser_download_url"`
				echo "name: ${name}"
				echo "url: ${url}"
				if [[ -n "${distros}" ]]; then
					for distro in $distros; do
						echo "distro ${distro}"
						folder=`echo "${distro}" | jq -r ".[0]"`
						exts=(`echo "${distro}" | jq -r ".[1:][]"`)
						echo "folder: ${folder}"
						echo "extentions: ${exts[@]}"
						if [[ -n "${exts}" ]]; then
							for extention in $exts; do
								if [[ $name == $extention ]]; then
									if [ ! -d $folder ]; then mkdir $folder; fi
									cd $folder
									if [ -f $name ]; then rm $name; fi
									wget $url
									cd ..
								fi
							done
						fi
					done
				fi
			done
		fi
	done
fi