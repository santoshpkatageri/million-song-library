#!/bin/bash

#See if Java 8 is installed, if not, give it a shot
#Useful if we're applying MSL to a bare Amazon Linux AMI instead of
# an AMI we built

date > /tmp/msl-install.log

if [ -a /usr/bin/java8 ]; then
  echo "Java8 already installed" | tee -a /tmp/msl-install.log
else
    yum install java-1.8.0-openjdk | tee -a /tmp/msl-install.log
fi
