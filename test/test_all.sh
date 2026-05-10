#!/bin/bash

for x in test/*.aq
do
    diff -u "${x%.*}.txt" <(./aqua $x)
done
