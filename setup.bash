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
hereIam="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${hereIam}/bishy.bash"
function setPromptStyle {
  ## Sets the look of the BASH prompt to a cooler one.
  ## Accepts a file as the first argument, where the procedures are pasted into
  ## so the file can be sourced and applied to the current shell.
  ## The file to be used as the first argument should be pretty much always a ~./bashrc or /etc/bash.bashrc file.
  ##
  ## Shows `git branch`.
  ## Shows first 7 characters of git commit hash.
  ## Shows up to first 24 characters of only the git commit title.
  ##
  ## Looks like this, but coloured, if in a Git repository:
  ## $USER@$HOSTNAME:~/src/akito-libbash ~ master:4a7d945~>"Several improvements"$
  ##
  ## If not in a Git repository:
  ## $USER@$HOSTNAME:~/src$
  local bashrcFile="$1"
  if [[ $(grep -q '###startvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###' "$bashrcFile")$? == 0 ]]; then
    sed -in '1,/###startvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###/p;/###endvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###/,$p' ${bashrcFile}
    sed -in '/###startvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###/,/###endvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###/d'      ${bashrcFile}
  fi
  cat >> ${bashrcFile} <<"EOF"
###startvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###
function git_info {
  git status >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    printf " \033[0;36m~ $(git rev-parse --abbrev-ref HEAD 2>/dev/null)\033[00m:\033[49;96m$(git log -1 --format="%H" | cut -c -7)\033[00m~>\033[38;5;50m\"$(git log -1 --oneline --pretty=%B | cut -d$'\n' -f1 | cut -c -24)\"\033[00m"
  else
    :
  fi
}
if [[ "$EUID" != 0 ]]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[1;32m\]\u\[\033[00m\]\[\033[01;33m\]@\[\033[00m\]\[\033[1;32m\]\h\[\033[01;37m\]:\[\033[01;34m\]\w\[\033[00m\]$(git_info)\[\033[01;37m\]\$\[\033[00m\]\n'
else
  PS1='${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\u\[\033[00m\]\[\033[01;33m\]@\[\033[00m\]\[\033[1;31m\]\h\[\033[01;37m\]:\[\033[01;34m\]\w\[\033[00m\]$(git_info)\[\033[01;37m\]\$\[\033[00m\]\n'
fi
###endvzUMjwTuyMofDHhBQSHXPZeWWOljAbxQfcKWmpybkFXyrDAtklSJFNJW###
EOF
}
unset hereIam
return
