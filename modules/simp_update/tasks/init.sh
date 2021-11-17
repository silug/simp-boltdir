#!/bin/bash
#
# Puppet Task Name: simp_update

set -e
>&2-

if [ ! -d "$PT_path" ] ; then
    git clone "$PT_url" "$PT_path"
fi

cd "$PT_path"
if [ -n "$PT_parent" ] ; then
    if [ -z "$( git remote -v | grep '^parent\>' )" ] ; then
        git remote add parent "$PT_parent"
    fi
fi
git fetch
git pull --all --ff-only || :
