#!/bin/bash

source "../jobs/common.env"
source "$1" # cluster node environment
source "../jobs/common.conf.sh"
printenv
