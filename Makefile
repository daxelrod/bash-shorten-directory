.PHONY: check lint bats test

check: lint bats

test: bats

bats:
	bats test/*.bats

lint:
	shellcheck -s bash share/*
