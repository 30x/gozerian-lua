#!/bin/bash
echo events
./tests/bustedjit ./tests/index.lua
echo c
./tests/bustedjit ./tests/lua2go.lua