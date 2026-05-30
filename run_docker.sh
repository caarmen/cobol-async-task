#!/usr/bin/env bash

set -e

docker build -t cobol-async-task . 
docker run --rm cobol-async-task "$@"
