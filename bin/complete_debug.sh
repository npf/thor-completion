_complete_debug() {
#set -x
  cat <<EOF 1>&2

COMP_LINE=$COMP_LINE"
COMP_POINT=$COMP_POINT"
COMP_KEY=$COMP_KEY"
COMP_TYPE=$COMP_TYPE"
COMP_WORDS=${COMP_WORDS[@]}"
COMP_CWORD=$COMP_CWORD"
EOF
#set +x
}
complete -F _complete_debug ./cli

