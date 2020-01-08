#!/bin/bash

if [[ `whoami` != 'root' ]]; then
	echo 'You must be root to deploy these.'
	exit 127
fi

script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")
src="$script_dir/files/"

echo "Copying files from \"${src}\" onto root"

cp --no-preserve=all -r "${src}"* /

if [ -f '/etc/vimrc' ]; then
	vimrc="/etc/vimrc"
else if [ -f '/etc/vim/vimrc' ]; then
	vimrc="/etc/vim/vimrc"
else
    echo "Could not find vimrc."
    exit 30
fi
fi

echo "Making sure default Vim configuration is not used"
sed -i '/skip_defaults_vim/s/^"//' "$vimrc"

echo "Making sure vimrc.local is used"

vimmagic="$script_dir/vimrc_magic"
if grep -q 'MAGIC USED' "$vimrc"; then
	echo "- Skipped, magic already exists"
else
	linenr=$(sed -n '/filereadable("\/etc\/vim\/vimrc\.local")/=' "$vimrc")
	if [[ -z "$linenr" ]]; then
		echo '- Could not find vimrc.local include in vimrc.'
		echo "  You may need to insert magic file \"$vimmagic\" manually."
		exit 126
	fi
	linenr=$(($linenr - 2))
	sed -i "${linenr}r $vimmagic" "$vimrc"
fi

echo 'Done.'
