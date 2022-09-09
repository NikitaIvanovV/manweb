#!/bin/sh

set -e

tmpd="$(mktemp -d --tmpdir 'XXX')"
trap 'rm -rf "$tmpd"' EXIT

newf() {
	mktemp --tmpdir="$tmpd" 'XXX'
}

# Make paragraphs one line so sed can properly process it
norm() {
	sed '
		\|</head>|i\
  <link rel="icon" type="image/x-icon" href="favicon.png">

		/^<p/ {
			:a
			\|</p>|b
			N
			s/\n\s*/ /
			ba
		}
	'
}

html="$(newf)"
cmds="$(newf)"

# Make html version of the manual
mandoc -man -Ostyle=style.css,toc -Thtml -Werror > "$html"

# Get all sections and generate sed commands
# to turn references to them into links
sed -n '
	s/.*<h[1-6] class=".." id="\([^"]\+\)">.*/\1/; Ta
	h
	y/_/ /
	G
	s,\(.*\)\n\(.*\),s|<i>\1</i>|<a href="#\2"><i>\1</i></a>|g,
	p
	b
	:a
	b
' "$html" > "$cmds"

# Run generated commands
norm < "$html" | sed -f "$cmds"
