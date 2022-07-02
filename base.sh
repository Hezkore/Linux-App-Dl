#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: t; tab-width: 4 -*-

notify-send "Installing ${1}"

wget -O - https://github.com/Hezkore/Linux-App-Dl/tree/master/Debian/${1}.sh | bash -