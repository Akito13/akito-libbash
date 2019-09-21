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

function truncEmpty {
  ## Remove redundant newlines at EOF.
  ## Leave only a single one.
  local file=$1;
  if [ -s ${file} ]; then
    while [[ $(tail -n 1 ${file}) == "" ]]; do
      truncate -cs -1 ${file};
    done;
  else
    return 1;
  fi;
}

function rmDisused {
  ## Remove string $2 within file $1.
  local file=$1;
  local entry=$2;
  while read -r line; do
    [[ ! $line =~ ${entry} ]] && echo "$line";
  done <${file} > NIYTyOOyTYIN;
  mv NIYTyOOyTYIN ${file};
}

function checkIP {
  ## Checks given IP format.
  ## Soft checking; no IP class matching.
  local ip=$1;
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    return 0;
  elif [[ $ip =~ ^[A-Fa-f0-9:]+ ]]; then
    return 0;
  else
    return 1;
  fi;
}
