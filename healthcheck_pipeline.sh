#!/bin/bash
docker ps | grep -F "(healthy)" | awk '{print} END {if(NR == 3) print "pass"; else print "fail"}' | grep pass
