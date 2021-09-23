# Debian/Arch PPA Template
This is a template of a ppa that watches the specified repositorues for releases and adds any `.deb` or `.pkg.gz` files it finds to the ppa.
## Requirements
* `gpg` - [debian](https://packages.debian.org/stable/gnupg), [arch](https://archlinux.org/packages/core/x86_64/gnupg/)
* `dpkg-dev` - [debian (`dpkg-dev`)](https://packages.debian.org/stable/dpkg-dev), [arch (`dpkg`)](https://archlinux.org/packages/community/x86_64/dpkg/)
## How to Setup
1. First start by [using this template](https://github.com/tumble1999/ppa-template/generate) and then clone it to your PC.
1. Then run `SETUP_PPA.sh` parameters including `name`, `email`, `url`.
	* `name` - Name of the PPA taht you'd like.
	* `email` - Email to sign the debain ppa
	* `url` - url of the ppa
		* *to find out the url go to the repository settings > Pages > (set source to master/main) and /(root), and then click save and it will show you the url*)

```bash
./SETUP_PPA.sh example-ppa foo@example.com "https://octocat.github.io/example-ppa"
```
3. copy the contents of `debian/keys/(ppa-name).private.key` into a GitHub Actions Secret called `GPG_KEY` - [Creating encrypted secrets for a repository](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
1. edit `ppa-config.json` and add strings to github repos that you have releases on in the format of `"username/repo"`
1. Commit and push back to your repo and the Github Actions should do it's work.
