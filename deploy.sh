#!/bin/bash

if [[ `whoami` != 'root' ]]; then
	echo 'You must be root to deploy these.'
	exit 127
fi

scriptdir="$(dirname "$0")"
src="$scriptdir/files/"

echo "Copying files from \"${src}\" onto root"

cp --no-preserve=all -r "${src}"* /

echo "Making sure default Vim configuration is not used"
sed -i '/skip_defaults_vim/s/^"//' /etc/vim/vimrc

echo "Making sure vimrc.local is used"

vimmagic="$scriptdir/vimrc_magic"
if grep -q 'MAGIC USED' /etc/vim/vimrc; then
	echo "- Skipped, magic already exists"
else
	linenr=$(sed -n '/filereadable("\/etc\/vim\/vimrc\.local")/=' /etc/vim/vimrc)
	if [[ -z "$linenr" ]]; then
		echo '- Could not find vimrc.local include in vimrc.'
		echo "  You may need to insert magic file \"$vimmagic\" manually."
		exit 126
	fi
	linenr=$(($linenr - 2))
	sed -i "${linenr}r $vimmagic" /etc/vim/vimrc
fi

echo 'Done.'
