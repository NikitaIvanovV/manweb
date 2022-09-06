#!/bin/sh

git show "$1":"$2" | ./manhtml.sh > "$3"
