#!/bin/bash

source "../jobs/common.env.sh"
source "$1" # cluster node environment
source "../jobs/common.conf.sh"
printenv
