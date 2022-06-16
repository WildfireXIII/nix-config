RPROMPT='[%D{%L:%M:%S %p}]'
# preexec () {
#     zle reset-prompt
# }

# https://stackoverflow.com/questions/12580675/zsh-preexec-command-modification
function update_rprompt_with_date {
    zle reset-prompt
    zle accept-line
}
zle -N update_rprompt_with_date
bindkey '^J' update_rprompt_with_date
bindkey '^M' update_rprompt_with_date

function cd {
    builtin cd "$@" && ls -F
}


# https://stackoverflow.com/questions/13125825/zsh-update-prompt-with-current-time-when-a-command-is-started
# strlen () {
#     FOO=$1
#     local zero='%([BSUbfksu]|([FB]|){*})'
#     LEN=${#${(S%%)FOO//$~zero/}}
#     echo $LEN
# }
#
# # show right prompt with date ONLY when command is executed
# preexec () {
#     DATE=$( date +"[%H:%M:%S]" )
#     local len_right=$( strlen "$DATE" )
#     len_right=$(( $len_right+1 ))
#     local right_start=$(($COLUMNS - $len_right))
#
#     local len_cmd=$( strlen "$@" )
#     local len_prompt=$(strlen "$PROMPT" )
#     local len_left=$(($len_cmd+$len_prompt))
#
#     RDATE="\033[${right_start}C ${DATE}"
#
#     if [ $len_left -lt $right_start ]; then
#         # command does not overwrite right prompt
#         # ok to move up one line
#         echo -e "\033[1A${RDATE}"
#     else
#         echo -e "${RDATE}"
#     fi
#
# }
#