#!/bin/sh
set -xeu

pwd
git status --short && test "$(git status --short)" = ''

cd '/home/public/workspace/gitlab.com/perobertson/setup'
git status --short && test "$(git status --short)" = ''
