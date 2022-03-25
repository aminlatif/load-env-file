#!/bin/bash

source ./load-env-file.sh

loadEnvFile "sample.env" "debug"

printenv | grep "LOAD_ENV_SAMPLE_*" | sort