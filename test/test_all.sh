#!/bin/bash

for x in test/script/*.aq
do
    name=$(basename "$x" .aq)
    diff -u "test/expected/$name.txt" <(./aqua $x)
done
