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
