# Overwrite the default svn_dirty_choose which treate '?' as dirty
svn_dirty_choose() {
  if in_svn; then
    local root=$(LANG=C svn info 2> /dev/null | sed -n 's/^Working Copy Root Path: //p')
    if svn status $root 2> /dev/null | command grep -Eq '^\s*[ACDIM!L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

DOCKER_FILE=/.dockerenv
prompt_docker() {
    if [ -f "$DOCKER_FILE" ]; then
        if [ -z "$MYNAME" ]; then
            echo -n "%{$fg[cyan]%}(docker)%{$reset_color%} "
        else
            echo -n "%{$fg[cyan]%}($MYNAME)%{$reset_color%} "
        fi
    fi
}

prompt_svn() {
    local rev branch
    if in_svn; then
        rev=$(svn_get_rev_nr)
        branch=$(svn_get_branch_name)
        if [[ $(svn_dirty_choose_pwd 1 0) -eq 1 ]]; then
            echo -n " %{$ZSH_THEME_SVN_PROMPT_PREFIX%}r$rev@%{$fg[blue]%})%{$fg_bold[yellow]%}$branch%{$reset_color%}%{$(svn_dirty)%}"
        else
            echo -n " $rev@$branch"
        fi
    fi
}


PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+='$(prompt_docker)%{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info)$(prompt_svn)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%} git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

ZSH_THEME_SVN_PROMPT_PREFIX="%{$fg_bold[blue]%}svn:(%{$fg[red]%}"
ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[red]%}✗"
ZSH_THEME_SVN_PROMPT_CLEAN="%{$fg[green]%}"
