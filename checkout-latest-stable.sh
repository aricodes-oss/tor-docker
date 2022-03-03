#!/bin/sh

export LATEST_TAG="$(git tag | grep -v alpha | grep -v rc | grep -v dev | tail -n 1)"

git checkout "$LATEST_TAG"
