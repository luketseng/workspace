# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color)
		PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
		;;
	*)
		#	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
		PS1='\[\033[1;32m\]\u@\h\[\033[00m\]:\[\033[1;33m\]\w\[\033[1;36m\]$(git_info)\[\033[00m\]\$ '
		;;
esac

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
		;;
	*)
		;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#### Handle dirty's Requirements
export EDITOR=vi
export GDFONTPATH="$HOME/share/fonts"
export LANG=zh_TW.UTF-8
export PATH="$PATH:$HOME/bin"

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
	eval "`dircolors -b`"
	alias ls='_ls'
fi
# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -t'

# Standard Aliases
alias cls='clear'
alias cp='cp -i'
alias du='du -h --max-depth=1'
alias h='history | grep'
alias mv='mv -i'
alias rm='_rm'
alias rrm='/bin/rm -i'	# real rm
alias vi='vim'
alias viedit='vim -O'
alias myrm='mv -t ~/trash'
alias bbs='ssh ptt.cc -l bbs' #ssh bbs@ptt.cc
alias tma='tmux at -t 0' # tmux attach -t 0
alias tmd='tmux kill-session -t 0' # tmux kill-session -t 0
alias tmr='tmux-session restore' # /bin/tmux-session restore
#alias scr='screen -D -R'
#alias scrr='screen -D -r'
#alias pjson='python -mjson.tool'

# Personal Aliases
if [ -e $HOME/.alias ]; then
	. $HOME/.alias
fi

# Local Functions and Commands
function git_info {
ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;

now=`date +%s`;
sec=$((now-last_commit));
min=$((sec/60)); hr=$((min/60)); day=$((hr/24)); yr=$((day/365));
if [ $min -lt 60 ]; then
	info="${min}m"
elif [ $hr -lt 24 ]; then
	info="${hr}h$((min%60))m"
elif [ $day -lt 365 ]; then
	info="${day}d$((hr%24))h"
else
	info="${yr}y$((day%365))d"
fi

echo "(${ref#refs/heads/} $info)";
#	echo "(${ref#refs/heads/})";
}

function _ls() {
#LANG=zh_TW.BIG5
#/bin/ls -C --group-directories-first --color=always $@ | /usr/bin/iconv -f big5 -t utf8
/bin/ls -C --group-directories-first --color=always $@
#LANG=zh_TW.UTF-8
}

function old() {
day=$1; shift
find . -maxdepth 1 -mtime +${day} $@
}

function _rm() {
while [ $# -ge 1 ]; do
	mv -f "$1" $HOME/tmp
	echo "$1 deleted."
	shift
done
}

function rmold() {
find . -maxdepth 1 -mtime +$1 -exec rm -rf {} \;
}

source /usr/share/bash-completion/completions/git

# vi:nowrap:sw=4:ts=4

#PATH="/home/lukezeng/perl5/bin${PATH+:}${PATH}"; export PATH;
#PERL5LIB="/home/lukezeng/perl5/lib/perl5${PERL5LIB+:}${PERL5LIB}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/lukezeng/perl5${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/lukezeng/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/lukezeng/perl5"; export PERL_MM_OPT;

# add below text to cbn boardfarm:
#export BFT_CONFIG="../boardfarm-cbn/cbn.json"
#export BFT_OVERLAY="../boardfarm-cbn"
#echo cbn | sudo -S service apparmor disable
#echo cbn | sudo -S systemctl disable apparmor

# spyder lang
#export LANG=en_US.UTF-8
#export LC_ALL=en_US.UTF-8
