#!/bin/bash
# shellcheck disable=SC2009
set -e

if [ -f .env ]; then
    # shellcheck disable=SC2046
    export $(grep -v '^#' .env | xargs)
fi
