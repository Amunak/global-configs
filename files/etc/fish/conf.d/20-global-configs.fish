# System-wide fish config for interactive shells.

status is-interactive; or return

set -gx EDITOR /usr/bin/vim
set -gx GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

set -gx LS_OPTIONS --human-readable --group-directories-first --time-style=long-iso

if test -x /usr/bin/dircolors
    set -a LS_OPTIONS --color=auto

    function grep
        command grep --color=auto $argv
    end

    function fgrep
        command fgrep --color=auto $argv
    end

    function egrep
        command egrep --color=auto $argv
    end
end

function s
    systemctl $argv
end

function j
    journalctl $argv
end

function ls
    command ls $LS_OPTIONS $argv
end

function ll
    command ls $LS_OPTIONS --all -l $argv
end

function li
    command ls $LS_OPTIONS --all -li $argv
end

function l
    ll $argv
end

function la
    ll $argv
end

function gc
    git commit $argv
end

function gca
    git commit --amend $argv
end

function gi
    git add -i $argv
end

function gl
    git log --graph --decorate --abbrev-commit --date=relative \
        --format="format:%C(bold blue)%h%C(reset) - %C(cyan)%an%C(reset) %C(bold green)%ar%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset)%C(dim white)%<(50,trunc)% b%C(reset)" \
        --all $argv
end
