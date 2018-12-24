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
# If the long path does not contain the separator, consider the next part to be the whole path,
# and the new long bath to be the empty string.
# Parameters:
#   long_path: the remaining unshortened path
#   separator: string between path components
# Returns: (via global variables)
#   __sd_extract_next_part_part: the leftmost path component
#   __sd_extract_next_part_long_path: the rest of the long path without the component or its separator
__sd_extract_next_part () {
  local long_path="$1"
  local separator="$2"

  local next_part="${long_path%%"$separator"*}"
  local new_long_path="${long_path#*"$separator"}"

  if [[ "$next_part" == "$new_long_path" ]]; then
    # This happens when the separator does not appear in long_path
    # and the two patterns match the whole string from the start and the back

    new_long_path=''
  fi

  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_next_part_part="$next_part"
  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_next_part_long_path="$new_long_path"
}

# Pull out the rightmost path component (basename) from the long path.
# The rest of the returned long path ends with the separator, because the shortened path would, too.
# Parameters:
#   long_path: the unshortened path
#   separator: string between path components
# Returns: (via global variables)
#   __sd_extract_last_part_part: the rightmost path component
#   __sd_extract_last_part_long_path: the rest of the long path without the component but with its separator
__sd_extract_last_part() {
  local long_path="$1"
  local separator="$2"

  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_last_part_part="${long_path##*"$separator"}"
  # shellcheck disable=SC2034 # TODO use these in a calling function
  __sd_extract_last_part_long_path="${long_path%"$separator"*}$separator"
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


