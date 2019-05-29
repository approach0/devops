#!/bin/sh
cd $1;
git submodule update --init --recursive
./autogen.sh
./configure && make
make install
