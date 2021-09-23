#!/bin/bash
if [ -f .ppa-setup ]; then
	echo PPA has already been setup
fi
PPA_NAME=$1
PPA_EMAIL=$2
PPA_URL=$3
if [[ -z "$PPA_NAME" ]] || [[ -z "$PPA_EMAIL" ]] || [[ -z "$PPA_URL" ]] ; then
	echo "syntax: $0 [name] [email] [url]"
	exit 1;
fi

echo Name: ${PPA_NAME}
echo Email: ${PPA_EMAIL}

echo
echo "-- Creating '${PPA_NAME}' PPA for ${PPA_EMAIL}"

function prepare_key() {
	if [ -z $1 ] || [ -z $2 ]; then
		echo "usage: $0 [key] [output file]"
		exit 1
	fi
	if [ ! -d keys ]; then mkdir keys; fi
	cd keys
	if [ -f $1.key ]
	then
		rm $1.key
	fi
	if [ -f $1.private.key ]
	then
		rm $1.private.key
	fi
	gpg --export -a $1 > $2.key
	gpg --export-secret-keys $1 | base64 > $2.private.key
	if [ -f $2.key ]
	then
		gpg --no-default-keyring --keyring ./$2_keyring.gpg --import $2.key
	fi
	if [ -f $2_keyring.gpg ]
	then
		gpg --no-default-keyring --keyring ./$2_keyring.gpg --export > $2.gpg
	fi
	cd ..
}

cp README.md README-SETUP.md
echo "# ${PPA_NAME}

## Install

### Debian

Download [${PPA_NAME}.deb](/debian/${PPA_NAME}.deb) and then install it with the \`dpkg\` command.

### Arch

Add this to /etc/pacman.conf

\`\`\`
[${PPA_NAME}]
Server = ${PPA_URL}/arch
\`\`\`">README.md
cp _config.yml _config.yml.bak
cp arch/update.sh arch/update.sh.bak
cp debian/update.sh debian/update.sh.bak
sed -i s/PPA_NAME/${PPA_NAME}/g */update.sh _config.yml
sed -i s/PPA_EMAIL/${PPA_EMAIL}/g */update.sh _config.yml



cd debian
if [ -n `ls ${PPA_NAME}*` ]; then rm -r ${PPA_NAME}*; fi
PKG_ROOT=./${PPA_NAME}
mkdir -p ${PKG_ROOT}

mkdir -p ${PKG_ROOT}/DEBIAN
echo "-- Creating ${PKG_ROOT}/DEBIAN/control"
echo "Package: ${PPA_NAME}
Version: 0.1.0
Section: development
Priority: required
Architecture: all
Maintainer: ${PPA_EMAIL}
Description: Debian PPA for ${PPA_NAME}
"> ${PKG_ROOT}/DEBIAN/control
echo "-- Creating ${PKG_ROOT}/DEBIAN/postinst"
echo "#!/bin/sh
sudo apt update
"> ${PKG_ROOT}/DEBIAN/postinst
chmod +x ${PKG_ROOT}/DEBIAN/postinst


cat >key-setup <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 4096
    Name-Real: ${PPA_NAME}
    Name-Email: ${PPA_EMAIL}
    Expire-Date: 0
	%no-ask-passphrase
	%no-protection
    # Do a commit here, so that we can later print "done" :-)
    %commit
    %echo done
EOF
gpg --batch --generate-key key-setup
rm key-setup
prepare_key $PPA_EMAIL $PPA_NAME
GPG_PATH=./keys/$PPA_NAME.gpg


if [ -f $GPG_PATH ]
then
	echo "-- Creating ${PKG_ROOT}/etc/apt/trusted.gpg.d/${PPA_NAME}.gpg"
	mkdir -p $PKG_ROOT/etc/apt/trusted.gpg.d
	tee "${PKG_ROOT}/etc/apt/trusted.gpg.d/${PPA_NAME}.gpg" < $GPG_PATH > /dev/null
fi

echo "-- Creating ${PKG_ROOT}/etc/apt/sources.list.d/${PPA_NAME}.list"
mkdir -p ${PKG_ROOT}/etc/apt/sources.list.d
echo "deb ${PPA_URL} ./">${PKG_ROOT}/etc/apt/sources.list.d/${PPA_NAME}.list

dpkg-deb --build $PPA_NAME




echo "------------------------------------------------------------"
echo "PLEASE COPY THE CONTENTS OF /debian/keys/${PPA_NAME}.private.key"
echo "AND PASTE IT TO A GH ACTIONS SECRET CALLED 'GPG_KEY'"
echo "------------------------------------------------------------"
