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

  __sd_extract_next_part_part="$next_part"
  __sd_extract_next_part_long_path="$new_long_path"
}

# Pull out the rightmost path component (basename) from the long path.
# The rest of the returned long path ends with the separator, (except when no separator appeared
# in the original long_path) because the shortened path would, too.
# Parameters:
#   long_path: the unshortened path
#   separator: string between path components
# Returns: (via global variables)
#   __sd_extract_last_part_part: the rightmost path component
#   __sd_extract_last_part_long_path: the rest of the long path without the component but with its separator
__sd_extract_last_part() {
  local long_path="$1"
  local separator="$2"

  local last_part="${long_path##*"$separator"}"
  local new_long_path="${long_path%"$separator"*}$separator"

  if [[ "$last_part$separator" == "$new_long_path" && "$long_path" != "$separator" ]]; then
    # As above, this happens when separator does not appear in long_path.
    # Not only do we need to check that the patterns have not matched the whole string,
    # we also need to make sure that the long path isn't only a separator. Otherwise,
    # if the path were at the root of the filesystem, we'd strip the separator.

    new_long_path='' # Intentionally do not add the separator since the original string did not have it
  fi

  __sd_extract_last_part_part="$last_part"
  __sd_extract_last_part_long_path="$new_long_path"
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

# Count the length of the string as readline would.
# This means ignoring sequences beginning with "\[" and ending with "\]".
# (Readline expects color codes and other nonprinting characters to be enclosed with those).
# A string with no \[...\] pairs is supported, but strings that have escaped brackets nested
# or unpaired will produce an undefined count (but will not infinitely loop).
__sd_printable_length () {
  local string="$1"

  local length=0
  local uncounted_string="$string"
  while
    local before_bracketed="${uncounted_string%%\\[*}" # before first \[
    local after_bracketed="${uncounted_string#*\[*\\]}" # after first \]
    [[ "$before_bracketed" != "$after_bracketed" ]] # As soon as they're equal, there are no more brackets in the string
  do
    (( length += ${#before_bracketed} ))

    if [[ "$uncounted_string" != "$after_bracketed" ]]; then
      uncounted_string="$after_bracketed"
    else
      # We've hit the potential for an infinite loop. This can happen if $string contains
      # a "\[" with no matching "\]" after it. The best we can do is just count the
      # remaining uncounted string as-is.
      break
    fi
  done

  (( length += ${#uncounted_string} ))
  echo "$length"
}

# Top-level function to shorten a directory string.
# Parameters:
#   total_length: maximum desired length of the shortened string. (optional: default is 1/4 of $COLUMNS)
#   long_path: path to shorten. (optional: default "$PWD")
#   part_length: when shortening a path part, how long to make it. (optional: default "1")
#   part_format: printf-style string to apply to each path part when shortening it.
#                Should include a trailing separator.
#                Printf is passed two additional arguments: part_length and the part string itself.
#                (optional: default '%.*s/' which turns "projects" into "p/")
# Returns: (via echo)
#   The shortened path
__shorten_directory() {
  local exit_status="$?" # Save previous exit status to restore at the end

  local total_length="${1-$((COLUMNS/4))}"
  local long_path="${2-$PWD}"
  local part_length="${3-1}"
  local part_format="${4-%.*s/}"

  local separator='/'

  # Prepare path for shortening
  local long_path_tilde
  long_path_tilde="$(__sd_substitute_tilde "$long_path" "$HOME")"

  __sd_extract_last_part "$long_path_tilde" "$separator"
  local basename="$__sd_extract_last_part_part"
  local long_path_portion="$__sd_extract_last_part_long_path"

  # Take parts off of the beginning of long_path_portion, shorten them, and add them to the end of short_path_portion.
  # Stop when the resulting path will be as short or shorter than total_length.
  # Alternatively, stop if there's nothing left to take out of long_path_portion and the resulting path still isn't short enough.
  # In that case, we've done all we can.

  local short_path_portion=""
  local assembled_path # The final path that will be a candidate to return
  while
    assembled_path="${short_path_portion}${long_path_portion}${basename}"
    [[ "$(__sd_printable_length "${assembled_path}")" -gt "$total_length" && ${#long_path_portion} -gt 0 ]]
  do
    __sd_extract_next_part "$long_path_portion" "$separator"
    local part="$__sd_extract_next_part_part"
    long_path_portion="$__sd_extract_next_part_long_path"

    local shortened_part
    shortened_part="$(__sd_shorten_part "$part" "$part_length" "$part_format")"
    short_path_portion+="$shortened_part"
  done

  echo "$assembled_path"
  return "$exit_status" # Restore previous exit status
}
