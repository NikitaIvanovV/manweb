#!/bin/sh

# Params:
# 1 - branch
# 2 - man page
# 3 - html output

pull() {
	ret=1

	branch="$(git branch --show-current)"

	if git stash -q; then
		if git checkout -q "$1"; then
			git pull && ret=0

			git checkout -q "$branch"
		fi

		git stash pop -q
	fi

	return "$ret"
}

commit() {
	git add "$1" &&
		git commit --no-edit --message='Update man page'
}

pull "$1" && ./updateindex.sh "$@" && commit "$3"
