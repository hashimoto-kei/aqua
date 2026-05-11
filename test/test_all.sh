#!/bin/bash

RED='\033[031m'
GREEN='\033[032m'
RESET='\033[0m'

for x in test/script/*.aq
do
    name=$(basename "$x" .aq)
    diff -u "test/expected/$name.txt" <(./aqua $x)
    [ $? == 0 ] && printf "${GREEN}pass${RESET}: $x\n" || printf "${RED}fail${RESET}: $x\n"
done
