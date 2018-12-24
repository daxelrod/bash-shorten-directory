#!/usr/bin/env bats

source share/shorten-directory.bash

@test "__sd_substitute_tilde does nothing if path is not rooted in second argument" {
  result="$(__sd_substitute_tilde '/var/www/foo' '/home/mantrid')"
  [ "$result" == '/var/www/foo' ]
}

@test "__sd_substitute_tilde turns the homedir prefix of path into a tilde" {
  result="$(__sd_substitute_tilde '/home/mantrid/projects' '/home/mantrid')"
  [ "$result" == '~/projects' ]
}

@test "__sd_substitute_tilde does not change homedir substrings after the beginning" {
  result="$(__sd_substitute_tilde '/var/www/home/mantrid/projects' '/home/mantrid')"
  [ "$result" == '/var/www/home/mantrid/projects' ]
}

@test "__sd_extract_next_part finds the next part and shortens the long path" {
  __sd_extract_next_part '~/projects/foo/bar' '/'

  [ "$__sd_extract_next_part_part" == '~' ]
  [ "$__sd_extract_next_part_long_path" == 'projects/foo/bar' ]
}

@test "__sd_extract_next_part considers the next part blank if long path starts with the separator" {
  __sd_extract_next_part '/var/www/foo' '/'

  [ "$__sd_extract_next_part_part" == '' ]
  [ "$__sd_extract_next_part_long_path" == 'var/www/foo' ]
}

@test "__sd_extract_next_part considers the next part blank if long path is only a separator" {
  __sd_extract_next_part '/' '/'

  [ "$__sd_extract_next_part_part" == '' ]
  [ "$__sd_extract_next_part_long_path" == '' ]
}

@test "__sd_extract_next_part considers the rest of the long path blank if long path does not contain a separator" {
  __sd_extract_next_part 'foobar' '/'

  [ "$__sd_extract_next_part_part" == 'foobar' ]
  [ "$__sd_extract_next_part_long_path" == '' ]
}

@test "__sd_extract_last_part finds the last part and shortens the long path" {
  __sd_extract_last_part '~/projects/foo/bar' '/'

  [ "$__sd_extract_last_part_part" == 'bar' ]
  [ "$__sd_extract_last_part_long_path" == '~/projects/foo' ]
}

@test "__sd_extract_last_part considers the last part blank if long path ends with the separator" {
  __sd_extract_last_part '~/projects/foo/bar/' '/'

  [ "$__sd_extract_last_part_part" == '' ]
  [ "$__sd_extract_last_part_long_path" == '~/projects/foo/bar' ]
}

@test "__sd_extract_last_part considers the last part blank if long path is only a separator" {
  __sd_extract_last_part '/' '/'

  [ "$__sd_extract_last_part_part" == '' ]
  [ "$__sd_extract_last_part_long_path" == '' ]
}

@test "__sd_shorten_part applies printf" {
  result="$(__sd_shorten_part 'waffle' 2 '%.*s')"
  [ "$result" == 'wa' ]
}

@test "__sd_shorten_part defaults to a format that shortens and suffixes with a slash" {
  result="$(__sd_shorten_part 'waffle' 2)"
  [ "$result" == 'wa/' ]
}

@test "__sd_shorten_part defaults to a format that doesn't lengthen parts shorter than the length" {
  result="$(__sd_shorten_part 'waffle' 10)"
  [ "$result" == 'waffle/' ]
}

@test "__sd_shorten_part defaults to a length of 1" {
  result="$(__sd_shorten_part 'waffle')"
  [ "$result" == 'w/' ]
}
