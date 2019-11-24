#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

## BASH library with common utils.

function checkPriv {
  if [[ "$EUID" != 0 ]]; then
    ## Check your privilege.
    echo "Please run me as root.";
    exit 1;
  fi;
}

# Section Start
# Coloured Echoes
function red_echo { echo -e "\033[31m$@\033[0m"; }
function green_echo { echo -e "\033[32m$@\033[0m"; }
function yellow_echo { echo -e "\033[33m$@\033[0m"; }
# Section End

function mergeEmptyLines {
  ## Merge each set of
  ## multiple consecutive 
  ## empty lines into a single
  ## empty line within the
  ## provided text file.
  local file="$1"
  cat ${file} | \
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' ${file}
}

function truncEmptyLines {
  ## Remove redundant newlines at EOF.
  ## Leave only a single one.
  local file="$1";
  if [ -s ${file} ]; then
    while [[ $(tail -n 1 ${file}) == "" ]]; do
      truncate -cs -1 ${file};
    done;
  else
    return 1;
  fi;
}

function rmDisused {
  ## Remove string "$2" within file "$1".
  local file="$1";
  local entry="$2";
  while read -r line; do
    [[ ! $line =~ ${entry} ]] && echo "$line";
  done <${file} > NIYTyOOyTYIN;
  mv NIYTyOOyTYIN ${file};
}

function checkIP {
  ## Checks given IP format.
  ## Soft checking; no IP class matching.
  local ip="$1";
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    return 0;
  elif [[ $ip =~ ^[A-Fa-f0-9:]+ ]]; then
    return 0;
  else
    return 1;
  fi;
}

function dedupPATH {
  ## Removes duplicate
  ## entries from $PATH.
  ## Modified version of
  ## https://unix.stackexchange.com/a/40973/196626
  if [ -n "${PATH}" ]; then
    old_PATH="${PATH}:";
    PATH="";
    while [ -n "${old_PATH}" ]; do
      x="${old_PATH%%:*}";
      case ${PATH}: in
        *:"$x":*) ;;
        *) PATH="${PATH}:${x}";;
      esac
      old_PATH="${old_PATH#*:}";
    done;
    PATH="${PATH#:}";
    unset old_PATH x;
  fi;
}

function python_switch {
  ## Switches default Python version
  ## between Python2 and Python3.
  python_version="$(python --version 2>&1)";
  if [[ ${python_version} == "Python 2.7"* ]]; then
    sudo update-alternatives --set python /usr/bin/python3;
  elif [[ ${python_version} == "Python 3"* ]]; then
    sudo update-alternatives --set python /usr/bin/python2;
  fi;
}
