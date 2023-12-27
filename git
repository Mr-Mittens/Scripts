#!/bin/bash

if [[ -d .git ]]; then
	git add .

	echo -n "Enter the commit : "
	read commit_message

	current_branch$(git rev-parse --abbrev-ref HEAD)

	git commit -m "$commit_message"

	git push origin $current_branch
else
	echo "not a git repo"
fi
