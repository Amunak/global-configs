# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


# General

shopt -s checkwinsize
shopt -s extglob
export EDITOR='/usr/bin/vim'

# history
shopt -s histappend
export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL='ignorespace:ignoredups'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Aliases

alias s='systemctl'
alias j='journalctl'

export LS_OPTIONS='--human-readable --group-directories-first --time-style=long-iso'
if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

        export LS_OPTIONS+=' --color=auto'

        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
fi

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS --all -l'
alias li='ls $LS_OPTIONS --all -li'
alias l='ll'
alias la='ll'

alias gc='git commit'
alias gca='git commit --amend'
alias gi='git add -i'
alias gl="git log --graph --decorate --abbrev-commit --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(cyan)%an%C(reset) %C(bold green)%ar%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset)%C(dim white)%<(50,trunc)% b%C(reset)' --all"


# Git Branch
parse_git_branch() {
	if hash git 2>/dev/null; then
		git symbolic-ref HEAD --short 2> /dev/null
	else
		return
	fi
}


# PS1 Username

if [[ `whoami` = 'root' ]]; then
        USER_COLOR="\[\033[0;41;97m\]"
else
        USER_COLOR="\[\033[0;43;30m\]"
fi


# PS1 Hostname

HOSTNAME_FULL=`hostname -f`
HOSTNAME_SHORT=`hostname -s`
if grep -q Microsoft /proc/version; then
	HOSTNAME_DOMAIN='WSL'
else
	HOSTNAME_DOMAIN=`hostname -d`
fi
case "$HOSTNAME_FULL" in
*.sanguine.*)
        HOSTNAME_WCOLOR="\[\033[0;47;30m\] $HOSTNAME_SHORT \[\033[0;100;39m\] $HOSTNAME_DOMAIN";;
sanguine.*)
        HOSTNAME_WCOLOR="\[\033[0;47;30m\] $HOSTNAME_FULL";;
emerald.xcx.cz)
        HOSTNAME_WCOLOR="\[\033[97m\]\[\033[48;5;29m\] $HOSTNAME_FULL";;
fern.|greenland.*)
        HOSTNAME_WCOLOR="\[\033[97m\]\[\033[48;5;64m\] $HOSTNAME_FULL";;
arch.*)
        HOSTNAME_WCOLOR="\[\033[97m\]\[\033[48;5;125m\] $HOSTNAME_FULL";;
*.home.*)
        HOSTNAME_WCOLOR="\[\033[0;104;97m\] $HOSTNAME_FULL";;
*)
        if [[ -z "$HOSTNAME_DOMAIN" ]]; then
                HOSTNAME_WCOLOR="\[\033[0;103;30m\] $HOSTNAME_FULL"
	elif [[ "$HOSTNAME_DOMAIN" = 'WSL' ]]; then
		HOSTNAME_WCOLOR="\[\033[0;103;30m\] $HOSTNAME_SHORT \[\033[0;46;96m\] Windows Subsystem for Linux"
        else
                HOSTNAME_WCOLOR="\[\033[0;103;30m\] $HOSTNAME_SHORT \[\033[0;103;34m\] $HOSTNAME_DOMAIN"
        fi
        ;;
esac


# PS1 assemble

PS1="\
\[\033[0;90m\]\t \
\$(ret=\$?; if [[ \$ret -gt 0 ]]; then printf \"\[\033[0;44;97m\] \$ret \"; else printf \"\[\033[0;44;93m\] \[\342\234\]\223 \"; fi)\
$USER_COLOR \u \
$HOSTNAME_WCOLOR \[\033[0m\]\
\[\033[1;32m\] \w \
\[\033[0m\]\n\
\$(branch=\$(parse_git_branch); if [[ -n \"\$branch\" ]]; then printf \"\[\033[0;92m\][\$branch] \"; fi)\
\[\033[0m\]\
\[\033[1;37m\]\\$ \[\033[0m\]"


# Colored prompt for serial TTY
[ $(tty) = /dev/ttyS0 ] && export TERM=xterm-256color

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@$(hostname -f): ${PWD}\007"'
        ;;
*)
        ;;
esac


# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
        function command_not_found_handle {
                # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
                        /usr/lib/command-not-found -- "$1"
                        return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
                        /usr/share/command-not-found/command-not-found -- "$1"
                        return $?
                else
                        printf "%s: command not found\n" "$1" >&2
                        return 127
                fi
        }
fi

# Save history after each command
 PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
