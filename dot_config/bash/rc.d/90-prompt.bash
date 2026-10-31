# [user@host over SSH] ~/path branch
# ❯ (red after a failed command)

# git's own prompt helper, shipped with the Command Line Tools' git.
# Markers: * unstaged, + staged, % untracked; also REBASE, MERGING, etc.
git_prompt=/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
# shellcheck disable=SC2034 # the GIT_PS1_* settings are read by __git_ps1
if [[ -r $git_prompt ]]; then
  source "$git_prompt"
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
else
  __git_ps1() { :; }
fi
unset git_prompt

# Red when the last command failed; __prompt_status is set in 05-env.bash.
__prompt_symbol() {
  if [[ ${__prompt_status:-0} == 0 ]]; then
    printf '❯'
  else
    printf '\001\033[31m\002❯\001\033[0m\002'
  fi
}

PS1="\[\033[36m\]\w\[\033[0m\]\$(__git_ps1 ' \[\033[34m\]%s\[\033[0m\]')\n\$(__prompt_symbol) "
if [[ -n ${SSH_CONNECTION-} ]]; then
  PS1="\[\033[32m\]\u@\h\[\033[0m\] $PS1"
fi
