#!/usr/bin/env zsh
# shellcheck shell=bash enable=all disable=SC2034
# shellcheck disable=SC3006,SC3010,SC3024,SC3030,SC3034,SC3046

migrate-to-lib-caches-destructive() (
  set -eu
  cd ~/
  dotname=$1
  if [[ -L $dotname ]]; then
    echo "$dotname is already a symlink; skipping"
    return
  fi

  set -xo noclobber
  rm -rf "$dotname"
  mkdir -p Library/Caches/"$dotname"
  ln -sf Library/Caches/"$dotname" ./
)

migrate-to-lib-appsup-nondestructive() (
  set -eu
  cd ~/
  dotname=$1
  if [[ -L $dotname ]]; then
    echo "$dotname is already a symlink; skipping"
    return
  fi
  if [[ -e Library/Application\ Support/$dotname ]]; then
    echo "Library/Application\ Support/$dotname exists; stopping"
    return 1
  fi

  set -xo noclobber
  mv "$dotname" Library/Application\ Support/
  ln -sf Library/Application\ Support/"$dotname" .
)

migrate-to-lib-appsup-nondestructive .config
migrate-to-lib-appsup-nondestructive .local
migrate-to-lib-caches-destructive .cache
