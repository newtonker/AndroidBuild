#!/bin/bash

# step one  Gradle time 
./gradlew assembleDebug
#Total time: 13.455 secs
# echo ${output} | awk -v FS="(BUILD SUCCESSFUL in |s)" '{print $2}'

# step two  Buck time 
./buckw install --run //app:bin_debug


# step three  Freeline time 
python freeline.py

