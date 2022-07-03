#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: t; tab-width: 4 -*-

clear
mkdir -p "$HOME/.cache"

DISTRO='Debian'

function ask_pass {
  SUDO_ASKPASS=$(zenity --password --title=Authentication)
}

function check_pass {
	# No password/cancel
	if [[ ${?} != 0 || -z ${SUDO_ASKPASS} ]]; then
		SUDO_STATUS=0
		return 0
	fi
	# Wrong password
	if ! sudo -kSp '' [ 1 ] <<<${SUDO_ASKPASS} 2>/dev/null; then
		SUDO_STATUS=2
		return 2
	fi
	# Correct password
	SUDO_STATUS=1
	return 1
}

function end_with {
	echo -e $1 > "$HOME/.cache/y.run"
}

echo Please enter your password to install $1
ask_pass
echo Installing $1
while ! check_pass; do
	if (( $SUDO_STATUS == 1 )); then
		sudo -Sp '' echo -e 'Installing...' <<<${SUDO_ASKPASS}
		clear
		echo "Fetching install script..."
		wget -qO "$HOME/.cache/y.ins" https://raw.githubusercontent.com/Hezkore/Linux-App-Dl/master/${DISTRO}/${1}.sh
		source "$HOME/.cache/y.ins" |
		#source "./Debian/htop.sh"
		zenity --progress --width=400 --height=100 --title="Installing ${1}" --text "Installing..." --auto-close --pulsate
		clear
		rm -r "$HOME/.cache/y.ins"
		APP=$(cat "$HOME/.cache/y.run")
		echo Launching $APP
		rm -r "$HOME/.cache/y.run"
		$APP
		exit
	else
		echo "Wrong Password!"
		ask_pass
    fi
done
exit
