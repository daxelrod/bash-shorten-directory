# Reverse tilde-expansion.
# Substitutes `home` with `~` in `path` if
# `path` starts with `home`.
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
