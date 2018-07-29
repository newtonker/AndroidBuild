#!/bin/bash

# step one  Gradle time 
./gradlew assembleDebug
#Total time: 13.455 secs
# echo ${output} | awk -v FS="(BUILD SUCCESSFUL in |s)" '{print $2}'




# step two  Buck time 
# 1. min 4.7

grep "okbuck" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has okbuck!"
else
   sed -i '' '/dependencies {/a\
        classpath "'"com.uber:okbuck:0.40.0"'"
' build.gradle
fi

grep "jcenter" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has jcenter!"
else
   sed -i '' '/repositories {/a\
        jcenter()
' build.gradle
fi

grep "apply plugin: ''"'com.uber.okbuck'"'" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has app buck!"
else
   sed -i '' '$a\
apply plugin: "'"com.uber.okbuck"'"
'  build.gradle
fi

grep "okbuck { lint { disabled = true } }" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has okbuck lint!"
else
   sed -i '' '$a\
okbuck { lint { disabled = true } }
'  build.gradle
fi


# distributionUrl=https\://services.gradle.org/distributions/gradle-4.6-all.zip
./gradlew clean
./gradlew :buckWrapper
./buckw targets
./buckw install --run //app:bin_debug


# step three  Freeline time
grep "freeline" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has freeline!"
else
   sed -i '' '/dependencies {/a\
        classpath "'"com.antfortune.freeline:gradle:0.8.8"'"
' build.gradle
fi

grep "jcenter" build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has jcenter!"
else
   sed -i '' '/repositories {/a\
        jcenter()
' build.gradle
fi

grep "com.antfortune.freeline" app/build.gradle > /dev/null
if [ $? -eq 0 ]; then
    echo "has app freeline!"
else
   sed -i '' '/android {/i\
apply plugin: "'"com.antfortune.freeline"'"
'  app/build.gradle
fi

grep "android.enableAapt2=false" gradle.properties> /dev/null
if [ $? -eq 0 ]; then
    echo "has disable aapt2!"
else
   sed -i '' '$a\
android.enableAapt2=false
'  gradle.properties
fi

./gradlew clean
./gradlew initFreeline -Pmirror
# ./gradlew initFreeline 
python freeline.py

