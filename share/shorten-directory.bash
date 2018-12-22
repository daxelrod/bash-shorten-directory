# Reverse tilde-expansion.
# Substitutes `home` with `~` in `path` if
# `path` starts with `home`.
# Parameters:
#   path: filesystem path
#   home: prefix to substitute with ~
# Returns: (via echo)
#   The substituted path
__sd_substitute_tilde () {
  local path="$1"
  local home="$2"

  local home_length=${#home}
  local path_prefix="${path:0:$home_length}"

  if [[ "$path_prefix" == "$home" ]]; then
    echo "~${path:$home_length}"
  else
    echo "$path"
  fi
}

# Pull out the leftmost path component from the long path.
# Parameters:
#   long_path: the remaining unshortened path
#   separator: string between path components
# Returns: (via global variables)
#   __sd_extract_next_part_part: the leftmost path component
#   __sd_extract_next_part_long_path: the rest of the long path without the component or its separator
__sd_extract_next_part () {
  local long_path="$1"
  local separator="$2"

  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_next_part_part="${long_path%%"$separator"*}"
  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_next_part_long_path="${long_path#*"$separator"*}"
}
