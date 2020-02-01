#!/bin/bash
#########################################################################
# Copyright (C) 2020 Akito <the@akito.ooo>                              #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################
## BASH library with common utils.

#################################   Boilerplate of the Boilerplate   ####################################################
# Coloured Echoes                                                                                                       #
function red_echo      { echo -e "\033[31m$@\033[0m";   }                                                               #
function green_echo    { echo -e "\033[32m$@\033[0m";   }                                                               #
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }                                                               #
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }                                                               #
# Coloured Printfs                                                                                                      #
function red_printf    { printf "\033[31m$@\033[0m";    }                                                               #
function green_printf  { printf "\033[32m$@\033[0m";    }                                                               #
function yellow_printf { printf "\033[33m$@\033[0m";    }                                                               #
function white_printf  { printf "\033[1;37m$@\033[0m";  }                                                               #
# Debugging Outputs                                                                                                     #
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]"; }                      #
function echoInfo   { local args="$@"; white_brackets $(green_printf "INFO") && echo " ${args}"; }                      #
function echoWarn   { local args="$@";  echo "$(white_brackets "$(yellow_printf "WARN")" && echo " ${args}";)" 1>&2; }  #
function echoError  { local args="$@"; echo "$(white_brackets "$(red_printf    "ERROR")" && echo " ${args}";)" 1>&2; }  #
# Silences commands' STDOUT as well as STDERR.                                                                          #
function silence { local args="$@"; ${args} &>/dev/null; }                                                              #
# Check your privilege.                                                                                                 #
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi;  }                     #
# Returns 0 if script is sourced, returns 1 if script is run in a subshell.                                             #
function checkSrc { (return 0 2>/dev/null); if [[ "$?" == 0 ]]; then return 0; else return 1; fi; }                     #
# Prints directory the script is run from. Useful for local imports of BASH modules.                                    #
# This only works if this function is defined in the actual script. So copy pasting is needed.                          #
function whereAmI { printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";   }                     #
# Alternatively, this alias works in the sourcing script, but you need to enable alias expansion.                       #
alias whereIsMe='printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'                            #
#########################################################################################################################

function mergeEmptyLines {
  ## Merge each set of
  ## multiple consecutive 
  ## empty lines into a single
  ## empty line within the
  ## provided text file.
  local file="$1"
  sed -in '$!N; /^\(.*\)\n\1$/!P; D' ${file}
}

function truncEmptyLines {
  ## Remove redundant newlines at EOF.
  ## Leave only a single one.
  local file="$1";
  if [ -s ${file} ]; then
    while [[ $(tail -n 1 ${file}) == "" ]] && [[ -s ${file} ]]; do
      truncate -cs -1 ${file};
    done;
  else
    return 1;
  fi;
}

function rmTheseLines {
  ## Remove variable amount of strings
  ## provided after the first argument
  ## within file provided as the first
  ## argument.
  local file="$1"
  local tmp_file="$(mktemp -p "/tmp" -t apt-sources.XXXXXXXXXXXXXXXXXX)"
  declare -a ENTRIES
  ENTRIES=( "$@" )
  for entry in "${ENTRIES[@]:1}"; do
    while read -r line; do
      [[ ! ${line} =~ ${entry} ]] && echo "${line}";
    done <${file} >> ${tmp_file};
  done
  mv ${tmp_file} ${file};
}

function checkIP {
  ## Checks given IP format.
  ## Soft checking; no IP class matching.
  local ip="$1";
  if [[ $ip =~ ^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$ ]]; then
    return 0;
  elif [[ $ip =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
    return 0;
  else
    return 1;
  fi;
}

function checkPort {
  local port="$1"
  if [[ ${port} =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$|(/tcp|/udp)$ ]]; then
    return 0
  else
    return 1
  fi
}

function path {
  ## Linux PATH manager.
  ##
  ####  Usage
  ##
  ## path this # Adds current working dir to PATH.
  ##
  ## path /usr/special # Adds '/usr/special' to PATH.
  ##
  ## path remove this # Removes current working dir from PATH.
  ##
  ## path remove /usr/special # Removes '/usr/special' from PATH.
  ##
  ## path exists this # Shows if current working dir is part of PATH.
  ##
  ## path exists /usr/special # Shows if '/usr/special' is in PATH.
  function format_PATH {
    echo -e "${PATH//:/\\n}"
  }
  function dup_warn {
    echoError "Path is already in PATH. Not adding a duplicate."
  }
  function path_exists {
    echoInfo "Path exists."
  }
  function path_exists_not {
    echoInfo "Path does not exist."
  }
  function export_current_path {
    export PATH="${PATH}:${PWD}"
  }
  function export_custom_path {
    local customPath="$1"
    export PATH="${PATH}:${customPath}"
  }
  function remove_custom_path {
    local unnecessaryPath="$1"
    export PATH=$(echo "${PATH}" | sed "s|:${unnecessaryPath}||")
  }
  function does_path_exist {
    local testPath="$1"
    if echo "${PATH}" | grep -q ":${testPath}:"; then
      return 0
    elif echo ":$(format_PATH | tail -n1):" | grep -q ":${testPath}:"; then
      return 0
    else
      return 1
    fi
  }
  if [[ "$1" == "this" ]]; then
    local testPath="${PWD}"
    if does_path_exist "${testPath}"; then
      dup_warn
    else
      export_custom_path "${testPath}"
    fi
  elif [[ "$1" == "remove" && "$2" != "this" ]]; then
    local unnecessaryPath="$2"
    if does_path_exist "${unnecessaryPath}"; then
      remove_custom_path "${unnecessaryPath}"
      return 0
    else
      path_exists_not
      return 1
    fi
  elif [[ "$1" == "remove" && "$2" == "this" ]]; then
    local unnecessaryPath="${PWD}"
    if does_path_exist "${unnecessaryPath}"; then
      remove_custom_path "${unnecessaryPath}"
      return 0
    else
      path_exists_not
      return 1
    fi
  elif [[ "$1" == "exists" && "$2" != "this" ]]; then
    local testPath="$2"
    if does_path_exist "${testPath}"; then
      path_exists
      return 0
    else
      path_exists_not
      return 1
    fi
  elif [[ "$1" == "exists" && "$2" == "this" ]]; then
    local testPath="${PWD}"
    if does_path_exist "${testPath}"; then
      path_exists
      return 0
    else
      path_exists_not
      return 1
    fi
  else
    local newPath="$1"
    if [[ "${newPath}" =~ ^[/] ]]; then
      if does_path_exist "${newPath}"; then
        dup_warn
      else
        export_custom_path "${newPath}"
      fi
    else
      echoError "Provided path does not begin with a path separator."
      yellow_echo "Have you provided a correct asolute path?"
    fi
  fi
  unset -f dup_warn
  unset -f path_exists
  unset -f path_exists_not
  unset -f export_custom_path
  unset -f remove_custom_path
  unset -f does_path_exist
  unset -f format_PATH
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

function pure_eval {
  ## Sanitizes input before evaluation.
  ## Extended version of
  ## https://stackoverflow.com/a/52538533/7061105
  local args=( "$@" )
  function token_quote {
   local quoted=()
   for token; do
     quoted+=( "$(printf '%q' "$token")" )
   done
   printf '%s\n' "${quoted[*]}"
  }
  eval "$(token_quote "${args[@]}")"
  unset -f token_quote
}

return
