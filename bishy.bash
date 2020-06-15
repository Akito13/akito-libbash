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
function echoDebug  { local args="$@"; if [[ ${debug_flag} == true ]]; then                                             #
white_brackets "$(white_printf   "DEBUG")" && echo " ${args}"; fi; }                                                    #
function echoInfo   { local args="$@"; white_brackets "$(green_printf  "INFO" )"  && echo " ${args}"; }                 #
function echoWarn   { local args="$@"; white_brackets "$(yellow_printf "WARN" )"  && echo " ${args}"; 1>&2; }           #
function echoError  { local args="$@"; white_brackets "$(red_printf    "ERROR")"  && echo " ${args}"; 1>&2; }           #
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
debug_flag=false                                                                                                        #
#########################################################################################################################

function mergeEmptyLines {
  ## Merge each set of
  ## multiple consecutive 
  ## empty lines into a single
  ## empty line within the
  ## provided text file.
  ##
  ## If only a file is provided
  ## as the first argument, then
  ## redundant linebreaks are
  ## merged as well as lines
  ## containing any number of
  ## spaces.
  ## If the first argument is
  ## "strict" and the second
  ## a filename, then only
  ## linebreaks will be merged,
  ## keeping lines with spaces
  ## untouched.
  if [[ "$1" == "strict" ]]; then
    local file="$2"
    sed -in '$!N; /^\(.*\)\n\1$/!P; D' ${file}
  else
    local file="$1"
    sed -in -e '$!N; /^\(.*\)\n\1$/!P; D' \
            -e '/^\s*$/d' ${file}
  fi
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
  local tmp_file="$(mktemp -p "/tmp" -t lines.XXXXXXXXXXXXXXXXXX)"
  local -a entries=( "$@" )
  for entry in "${entries[@]:1}"; do
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
  ## Any Port in the technical Port range is accepted.
  ## Currently Ports like "5111/tcp" are accepted as well
  ## and I don't see a need to make it stricter.
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
    local dup_path="$1"
    echoWarn "${dup_path} is already in PATH. Not adding a duplicate."
  }
  function path_exists {
    local path="$1"
    echoInfo "${path} does exist."
  }
  function path_exists_not {
    local path="$1"
    echoInfo "${path} does not exist."
  }
  function export_custom_path {
    local IFS=":"
    export PATH="${PATH}:$(printf "$*")"
    unset IFS
  }
  function remove_custom_path {
    ## This complicated function is needed to
    ## 1. Remove ONLY the paths you want to remove so in case you are trying to remove /usr
    ## then /usr/bin will not get unintentionally deleted.
    ## 2. Work with paths containing spaces! This is needed on WSL systems, as the Windows-native
    ## paths are automatically added to the PATH within WSL.
    ## This means, that WSL's PATH will always contain paths with spaces in it, because Windows is so "amazing".
    #
    ## IFS change needed, to properly add the elements to the array, otherwise the array would split each element
    ## by using the space character as a delimiter, which would lead to a path containing spaces resulting in
    ## more than a single element.
    local -a unnecessaryPaths=( "$@" )
    IFS='"'
    # Splitting the PATH into an array by using a double quote as the delimiter.
    local split_path=( $(printf "${PATH}" | sed -e '0,/^/ s//"/g' -e 's/:/"/g' -e '$ s/$/"/g') )
    ## Declaration of temporary split path, where I will add back the original PATH delimiters, i.e. colons,
    ## when the split_path array will be joined back together, after the unnecessaryPaths have been removed.
    local -a temp_split_path
    ## Declaration of the final path that will result into the new and shiny clean PATH.
    local joined_path
    for entry in "${unnecessaryPaths[@]}"; do
      ## Iterates through each element of the array consisting of unwanted paths.
      ## Each iteration the split_path is iterated to search for occurances of the unwanted paths,
      ## so they can be individually unset. This means that the index containing the unwanted path
      ## will remain, but the value itself will be set to `null`.
      local unnecessaryPath="${entry}"
      for ((i=0; i < ${#split_path[@]}; i++)); do
        ## This for loop iterates over each element of PATH as an array, by index.
        ## Using actual for loop for compatability reasons. Not sure anymore if it is still needed, but there
        ## is no significant difference in using either, if both work. So no need to change/test if a foreach
        ## loop could work, as well.
        #
        ## Because making the code more human readable is pretty much always better.
        local counter=$i
        ## The actual value of the current element in the array, retrieved by index.
        local entry="${split_path[$i]}"
        if [[ "${entry}" == "${unnecessaryPath}" ]]; then
          ## Triggers if the current element of the PATH array equals to the unwanted provided path.
          ## Setting the value of the current element by index to `null`.
          unset "split_path[$counter]"
        fi
      done
    done
    for entry in "${split_path[@]}"; do
      ## This foreach loop iterates over the new split_path's elements, containing only the paths wanted.
      ## It adds them to a new array, with a colon as a prefix, to ready it for further processing.
      temp_split_path+=( "$( printf ":${entry}")" )
    done
    ## Finally, this is the joined path, that represents the new PATH as a single string, instead of an array.
    joined_path="$( echo "${temp_split_path[@]}" | sed -r -e 's/[[:space:]]+:/:/g' -e 's/:://' )"
    ## Exporting the temporary modified PATH to the actual PATH.
    export PATH=${joined_path}
    ## Setting IFS back to default value.
    unset IFS
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
    local -a unnecessaryPaths=( "${@:2}" )
    for entry in "${unnecessaryPaths[@]}"; do
      if does_path_exist "${entry}"; then
        remove_custom_path "${entry}"
      else
        path_exists_not
      fi
    done
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
    local newPaths=( "${@}" )
    local verifiedPaths=( )
    for entry in "${newPaths[@]}"; do
      if [[ "${entry}" =~ ^[/] ]]; then
        if does_path_exist "${entry}"; then
          dup_warn "${entry}"
          continue
        else
          verifiedPaths+=( "${entry}" )
          continue
        fi
      else
        echoError "Provided path does not begin with a path separator."
        yellow_echo "Have you provided a correct asolute path?"
      fi
    done
    if   [[ "${#verifiedPaths[@]}" > 0 ]]; then
      export_custom_path "${verifiedPaths[@]}"
    elif [[ "${#verifiedPaths[@]}" == 0 ]]; then
      echoInfo "PATH already contains all paths provided."
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

function show_args {
  ## Reliable way of showing the
  ## number of arguments given.
  ## Useful for debugging Bash behaviour.
  printf "%d args:" "$#"
  printf " <%s>" "$@"
  echo
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

function prepend_text {
  ## Prepends provided text to a text file.
  ## May break if input files are too large.
  ## By default adds a single \n to the prepending text.
  ## Run without arguments to get usage information.
  local funcname="${FUNCNAME[0]}"
  local prepending_text
  local prepending_text_file
  local original_text_file
  local merged_text
  local newlines_count=1
  local newlines='\n'
  local arg_count="$#"
  local e=false
  local p=false
  local o=false
  local n=false
  local OPTIND
  function usage {
    ## Usage info output.
    local indent='    '
    white_echo "Usage"
    echo
    yellow_echo "${indent}${funcname} -e <PREPENDING_TEXT>      -o <ORIGINAL_TEXT_FILE> [-n NEWLINES_AFTER_PREP_TEXT_COUNT]"
    yellow_echo "${indent}${funcname} -p <PREPENDING_TEXT_FILE> -o <ORIGINAL_TEXT_FILE> [-n NEWLINES_AFTER_PREP_TEXT_COUNT]"
    echo
    echo "${indent}Default amount of newlines after prepended text is ${newlines_count}."
    echo "${indent}Does not change contents of provided text. Literal \n won't be interpreted."
    echo
    white_echo "Examples"
    echo
    yellow_echo "${indent}${funcname} -e \"This sentence will be prepended.\" -o \"myfile.txt\" -n 3"
    echo
    echo "${indent}Prepend 'This sentence will be prepended.' to file 'myfile.txt'."
    echo "${indent}3 newlines will be added to the end of the prepended text."
    echo
    echo
    echo
    yellow_echo "${indent}${funcname} -p \"prepend.txt\" -o \"targetfile.txt\" -n 5"
    echo
    echo "${indent}Prepend the content of 'prepend.txt' to file 'targetfile.txt'."
    echo "${indent}5 newlines will be added to the end of the prepended text."
    echo
    echo
  }
  if [[ "${arg_count}" == 0 ]] || [[ "$1" =~ help|--help|-h ]]; then
    echoError "Invalid argument."
    usage
    return 1
  fi
  while getopts ":e:p:o:n:" opt; do
    case "${opt}" in
      e) e=true; prepending_text="${OPTARG}";
         [[ -n "${prepending_text}" ]] || { echoError "Must provide $(yellow_printf PREPENDING_TEXT) to option." && usage; return 1; }
         ;;
      p) p=true; prepending_text_file="${OPTARG}";
         [[ -f "${prepending_text_file}" ]] || { echoError "$(yellow_printf PREPENDING_TEXT_FILE) unavailable."     && usage; return 1; }
         [[ -r "${prepending_text_file}" ]] || { echoError "$(yellow_printf PREPENDING_TEXT_FILE) is not readable." && usage; return 1; }
         ;;
      o) o=true; original_text_file="${OPTARG}";
         [[ -f "${original_text_file}" ]] || { echoError "$(yellow_printf ORIGINAL_TEXT_FILE) unavailable."     && usage; return 1; }
         [[ -w "${original_text_file}" ]] || { echoError "$(yellow_printf ORIGINAL_TEXT_FILE) is not writable." && usage; return 1; }
         ;;
      n) n=true; newlines_count="${OPTARG}";
         [[ ${newlines_count} =~ ^[0-9]$ ]] || { echoError "$(yellow_printf NEWLINES_AFTER_PREP_TEXT_COUNT) must be a number." && usage; return 1; }
         ;;
      *) echoError "Not a valid option."; usage; return 1;;
    esac
  done
  if [[ $e == true ]] && [[ $p == true ]]; then
    echoError "Can only provide either $(yellow_printf PREPENDING_TEXT) or $(yellow_printf PREPENDING_TEXT_FILE). Not both."
    usage
    return 1
  elif [[ $e == true ]] && ! [[ -n ${prepending_text} ]]; then
    echoError "Must provide $(yellow_printf PREPENDING_TEXT)."
    usage
    return 1
  elif [[ $p == true ]] && ! [[ -f ${prepending_text_file} ]]; then
    echoError "Must provide $(yellow_printf PREPENDING_TEXT_FILE)."
    usage
    return 1
  fi
  if ! [[ -f ${original_text_file} ]]; then
    echoError "Must provide $(yellow_printf ORIGINAL_TEXT_FILE)."
    usage
    return 1
  fi
  if   [[ ${newlines_count} == 0 ]]; then
    newlines=''
  elif [[ ${newlines_count} != 0 ]]; then
    for (( i=1; i<${newlines_count}; i++ )) do
      newlines+='\n'
    done
  fi
  if   [[ -r "${prepending_text_file}" ]]; then
    merged_text="$(printf '%s%b%s' "$(<"${prepending_text_file}")" "${newlines}" "$(<"${original_text_file}")")"
    printf '%s' "${merged_text}" > "${original_text_file}"
  elif [[ -n "${prepending_text}" ]]; then
    merged_text="$(printf '%s%b%s' "${prepending_text}" "${newlines}" "$(<"${original_text_file}")")"
    printf '%s' "${merged_text}" > "${original_text_file}"
  fi
  unset -f usage
}

return
