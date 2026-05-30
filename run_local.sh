#!/usr/bin/env bash

set -e

cobc -x src/*.cob
./Activity "$@"
