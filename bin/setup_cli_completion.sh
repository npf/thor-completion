_thor_complete() {
  export COMP_LINE COMP_POINT COMP_KEY COMP_TYPE
  local words=$(bin/cli completion)
  COMPREPLY=( $words )
}
complete -F _thor_complete bin/cli

