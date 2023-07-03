#!/bin/bash

for branch_slug in "$@"
do
    echo "deb http://omar.knut.univention.de/build2/git/${branch_slug} git main" >> /etc/apt/sources.list.d/15_ucs-dev-sources.list
done
