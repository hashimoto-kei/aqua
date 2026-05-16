#!/bin/bash

RED='\033[031m'
GREEN='\033[032m'
RESET='\033[0m'

for x in test/script/*.aq
do
    name=$(basename "$x" .aq)
    [ $name == 'built_in' ] && option='' || option='-v'
    diff -u "test/expected/$name.txt" <(./aqua $option $x)
    [ $? == 0 ] && txt="${GREEN}pass${RESET}" || txt="${RED}fail${RESET}"
    printf "${txt}: ${x}\n"
done
