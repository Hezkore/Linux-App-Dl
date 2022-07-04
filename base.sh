#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: t; tab-width: 4 -*-

mkdir -p "$HOME/.cache"
clear

echo "=== Download & Install $1 ==="
echo "App: $1"
echo "User: $(whoami)"

# Figure out base distro (do this better!)
DISTRO='unknown'
if [ -f "/etc/debian_version" ]; then
   DISTRO='debian'
fi

# Is distro valid?
if [ $DISTRO = 'unknown' ]; then
	echo "Not a valid distro"
	exit
else
	echo "Distro: $DISTRO"
	echo $(uname -a)
	echo
fi

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

echo Please enter your user password to install $1
ask_pass
while ! check_pass; do
	if (( $SUDO_STATUS == 1 )); then
		sudo -Sp '' echo -e 'Installing...' <<<${SUDO_ASKPASS}
		clear
		
		echo "Fetching install script for $1..."
		wget -qO "$HOME/.cache/y.ins" https://raw.githubusercontent.com/Hezkore/Linux-App-Dl/master/${DISTRO}/${1}.sh |
		zenity --progress --width=400 --height=100 --title="Preparing to install ${1}" --text "Downloading..." --auto-close --pulsate
		
		echo "Installing $1..."
		source "$HOME/.cache/y.ins" |
		#source "./${DISTRO}/${1}.sh"
		zenity --progress --width=400 --height=100 --title="Installing ${1}" --text "Installing..." --auto-close --pulsate
		
		rm -r "$HOME/.cache/y.ins"
		APP=$(cat "$HOME/.cache/y.run")
		rm -r "$HOME/.cache/y.run"
		clear
		echo "Starting $APP..."
		setsid "${APP}"
		sleep 1
		exit
	else
		echo "Wrong Password!"
		ask_pass
    fi
done
exit