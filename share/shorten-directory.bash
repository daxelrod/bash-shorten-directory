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
  __sd_extract_next_part_long_path="${long_path#*"$separator"}"
}

# Shorten an individual long path part.
# By default, this will result in a single letter shortened part followed by a slash
# Parameters:
#   part: a long path part string, with no separators
#   length: how long the short part should be, not including separator (optional; default "1")
#   format: a printf format string. It's passed the length and the part. (optional; default "%.*s"/)
#           The format is expected to add whatever trailing separator is appropriate for the shortened path.
# Returns: (via echo)
#   The shortened path part
__sd_shorten_part () {
  local part="$1"
  local length="${2-1}"
  local format="${3-%.*s/}"

  # shellcheck disable=SC2059 # We want a printf format pattern in a variable
  printf "$format" "$length" "$part"
}


