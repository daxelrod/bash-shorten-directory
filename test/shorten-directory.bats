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
  [ "$__sd_extract_last_part_long_path" == '~/projects/foo/' ]
}

@test "__sd_extract_last_part considers the last part blank if long path ends with the separator" {
  __sd_extract_last_part '~/projects/foo/bar/' '/'

  [ "$__sd_extract_last_part_part" == '' ]
  [ "$__sd_extract_last_part_long_path" == '~/projects/foo/bar/' ]
}

@test "__sd_extract_last_part considers both parts blank if long path is only a separator" {
  __sd_extract_last_part '/' '/'

  [ "$__sd_extract_last_part_part" == '' ]
  [ "$__sd_extract_last_part_long_path" == '/' ]
}

@test "__sd_extract_last_part considers the new long path blank if long path has no separator" {
  __sd_extract_last_part 'foobar' '/'

  [ "$__sd_extract_last_part_part" == 'foobar' ]
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

@test "__sd_printable_length correctly handles a string with one bracket pair" {
  result="$(__sd_printable_length '1\[abc\]23')"
  [ "$result" -eq 3 ]
}

@test "__sd_printable_length correctly handles a string with multiple bracket pairs" {
  result="$(__sd_printable_length '1\[abc\]23\[def\]45')"
  [ "$result" -eq 5 ]
}

@test "__sd_printable_length correctly handles a string with no bracket pairs" {
  result="$(__sd_printable_length '1234')"
  [ "$result" -eq 4 ]
}

@test "__sd_printable_length correctly handles a string starting with a bracket pair" {
  result="$(__sd_printable_length '\[abc\]1234')"
  [ "$result" -eq 4 ]
}

@test "__sd_printable_length correctly handles a string ending with a bracket pair" {
  result="$(__sd_printable_length '1234\[abc\]')"
  [ "$result" -eq 4 ]
}

@test "__sd_printable_length doesn't infinitely loop when the string has an unmatched opening \[ (count unspecified)" {
  result="$(__sd_printable_length '1234\[abc\]56\[789')"
  true
}

@test "__sd_printable_length doesn't infinitely loop when the string has an unmatched opening \] (count unspecified)" {
  result="$(__sd_printable_length '1234\[abc\]56\]789')"
  true
}

@test "__sd_printable_length isn't fooled by unescaped brackets outside of escaped brackets" {
  result="$(__sd_printable_length '1\[a\][][567]9')"
  [ "$result" -eq 9 ]
}

@test "__sd_printable_length isn't fooled by unescaped brackets inside escaped brackets" {
  result="$(__sd_printable_length '1\[a]\]23')"
  [ "$result" -eq 3 ]
}

@test "__sd_printable_length isn't fooled by unescaped brackets with no escaped brackets" {
  result="$(__sd_printable_length '1[3]5')"
  [ "$result" -eq 5 ]
}

@test "__shorten_directory leaves the path untouched if the length is longer than the long path" {
  result="$(__shorten_directory 100 '/var/www/home/mantrid/projects')"
  [ "$result" == '/var/www/home/mantrid/projects' ]
}

@test "__shorten_directory shortens just the first element if necessary" {
  expected='/v/www/home/mantrid/projects'
  result="$(__shorten_directory "${#expected}" '/var/www/home/mantrid/projects')"
  [ "$result" == "$expected" ]
}

@test "__shorten_directory shortens the first and second elements if necessary" {
  expected='/v/www/home/mantrid/projects'
  result="$(__shorten_directory "${#expected}" '/var/www/home/mantrid/projects')"
  [ "$result" == "$expected" ]
}

@test "__shorten_directory shortens everything but the last two elements if necessary" {
  expected='/v/w/h/mantrid/projects'
  result="$(__shorten_directory "${#expected}" '/var/www/home/mantrid/projects')"
  [ "$result" == "$expected" ]
}

@test "__shorten_directory shortens everything except basename when given a length shorter than the completely shortened path" {
  result="$(__shorten_directory 1 '/var/www/home/mantrid/projects')"
  [ "$result" == '/v/w/h/m/projects' ]
}

@test "__shorten_directory handles just a basename by returning the basename" {
  result="$(__shorten_directory 1 'projects')"
  [ "$result" == 'projects' ]
}

@test "__shorten_directory handles just a slash by returning the slash" {
  result="$(__shorten_directory 1 '/')"
  [ "$result" == '/' ]
}

@test "__shorten_directory handles just the home by returning a tilde" {
  result="$(HOME='/home/mantrid' __shorten_directory 1 '/home/mantrid')"
  [ "$result" == '~' ]
}

@test "__shorten_directory handles format strings that apply color codes" {
  before='\[\033[1;34m\]'
  after='\[\033[0m\]'
  # "/v/www/foo" is 10 characters
  result="$(__shorten_directory 10 '/var/www/foo' 1 '\\[\\033[1;34m\\]%.*s/\\[\\033[0m\\]')"
  [ "$result" == "${before}/${after}${before}v/${after}www/foo" ]
}
