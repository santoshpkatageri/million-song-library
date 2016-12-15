#!/usr/bin/env bash

UNAME_S=$(uname -s)

# Verify OS
while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        -c|--cassandra)
        path_to_cassandra="$2"
        shift
        ;;
        *)
        echo "No params provided";
        exit 1;
        ;;
    esac
shift
done

function validatePorts {
  allPortsAvailable=true

  if lsof -i:3000; then
    echo "MSL Required Port 3000 in use"
    allPortsAvailable=false
  fi
  if lsof -i:3002; then
    echo "MSL Required Port 3002 in use"
    allPortsAvailable=false
  fi
  if lsof -i:3003; then
    echo "MSL Required Port 3003 in use"
    allPortsAvailable=false
  fi
  if lsof -i:3004; then
    echo "MSL Required Port 3004 in use"
    allPortsAvailable=false
  fi
  if lsof -i:9001; then
    echo "MSL Required Port 9001 in use"
    allPortsAvailable=false
  fi
  if lsof -i:9002; then
    echo "MSL Required Port 9002 in use"
    allPortsAvailable=false
  fi
  if lsof -i:9003; then
    echo "MSL Required Port 9003 in use"
    allPortsAvailable=false
  fi
  if lsof -i:9004; then
    echo "MSL Required Port 9004 in use"
    allPortsAvailable=false
  fi
  if lsof -i:9042; then
    echo "MSL Required Port 9042 for Cassandra in use"
    allPortsAvailable=false
  fi

  if [ "$allPortsAvailable" = true ] ; then
    echo "Ports 3000, 3002, 3003, 3004, 9001, 9002, 9003, 9004 and 9042 are available"
  else
    echo "Quitting MSL installation."
    exit 1
  fi
}

function validateOS {
  if [[ ${UNAME_S} =~ Linux* ]] ; then
    echo "Linux OS"
  elif [[ ${UNAME_S} =~ Darwin* ]] ; then
    version_string=$("sw_vers" -productVersion)
    echo Evaluating OS X machine version ${version_string}
    minVersion=10.11

    if [[ $version_string =~ ([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "10" || ("BASH_REMATCH[1]" == "10" && "BASH_REMATCH[2]" -lt "11") ]]; then
        printf "The version of OS X installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}) (El Capitan). Please install OS X ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "10" || ("BASH_REMATCH[1]" == "10" && "BASH_REMATCH[2]" -gt "11")]]; then
        printf "** The version of OS X installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of OS X, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of OS X that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable OS X version ${version_string}. Cannot verify OS X version."
      echo "Please install OS X ${minVersion} or greater"
      exit 1;
    fi
  else
    echo "Invalid OS"
    exit 1;
  fi
}

function verifyGit {
  minVersion=2.2.x
  if type -p git; then
    echo Found git executable in PATH
    _git=git
  else
    echo "Please install git ${minVersion}"
    exit;
  fi

  if [[ "$_git" ]]; then
    version_string=$("$_git" --version)
    echo Found git version "${version_string}"

    if [[ $version_string =~ git\ version\ ([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -lt "2") ]]; then
        printf "The version of git installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install git ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -gt "2")]]; then
        printf "** The version of git installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of git, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of git that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable git version ${version_string}. Cannot verify git version."
      echo "Please install git ${minVersion} or greater"
      exit 1;
    fi
  fi
}

function verifyNpm {
  minVersion=2.7.x
  if type -p npm; then
    echo Found npm executable in PATH
    _npm=npm
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install npm for you?") ]]; then
      bash basic-dep-setup.sh -npm
    else
      echo "Please install npm ${minVersion} or greater"
      exit 1;
    fi
  fi

  if [[ "$_npm" ]]; then
    version_string=$("$_npm" --version)
    echo Found npm version "$version_string"

    if [[ $version_string =~ ([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -lt "7") ]]; then
        printf "The version of npm installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install npm ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -gt "7")]]; then
        printf "** The version of npm installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of npm, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of npm that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable npm version ${version_string}. Cannot verify npm version."
      echo "Please install npm ${minVersion} or greater"
      exit 1;
    fi
  fi
}

function verifyBower {
  if type -p bower; then
    echo Found bower executable in PATH
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install bower for you?") ]]; then
      bash basic-dep-setup.sh -bower
    else
      echo "please install bower"
      exit 1;
    fi
  fi
}

function verifyGem {
  if type -p gem; then
    echo Found gem executable in PATH
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install gem for you?") ]]; then
      bash basic-dep-setup.sh -gem
    else
      echo "please install gem"
      exit 1;
    fi
  fi
}

function verifyNode {
  minVersion=0.12.x
  if type -p node; then
      echo Found node executable in PATH
      _node=node
  else
      if [[ "yes" == $(askYesOrNo "Would you like us to install node for you?") ]]; then
        bash basic-dep-setup.sh -npm
        verifyBower
        verifyGem
      else
        echo "Please install node version ${minVersion} or greater"
        exit 1;
      fi
  fi

  if [[ "$_node" ]]; then
    version_string=$("$_node" --version)
    echo Found node version "$version_string"

    if [[ $version_string =~ v([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "0" || ("BASH_REMATCH[1]" == "0" && "BASH_REMATCH[2]" -lt "12") ]]; then
        printf "The version of node installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install node ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "0" || ("BASH_REMATCH[1]" == "0" && "BASH_REMATCH[2]" -gt "12")]]; then
        printf "** The version of node installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of node, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of node that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable node version ${version_string}. Cannot verify node version."
      echo "Please install node ${minVersion} or greater"
      exit 1;
    fi
    verifyBower
    verifyGem
  fi
}

function verifyJava {
  minVersion=1.8.x
  if type -p java; then
      echo Found java executable in PATH
      _java=java
  elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
      echo Found java executable in JAVA_HOME
      _java="$JAVA_HOME/bin/java"
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install java 1.8 for you?") ]]; then
        bash basic-dep-setup.sh -java
    else
      echo "Please install Java version ${minVersion} or greater"
      exit 1;
    fi
  fi

  if [[ "$_java" ]]; then
    version_string=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo Found java version "$version_string"

    if [[ $version_string =~ ([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "1" || ("BASH_REMATCH[1]" == "1" && "BASH_REMATCH[2]" -lt "8") ]]; then
        printf "The version of java installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install java ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "1" || ("BASH_REMATCH[1]" == "1" && "BASH_REMATCH[2]" -gt "8")]]; then
        printf "** The version of java installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of java, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of java that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable java version ${version_string}. Cannot verify java version."
      echo "Please install java ${minVersion} or greater"
      exit 1;
    fi
  fi
}

function verifyCassandra {
  minVersion=2.1.11
  echo "Cassandra directory: " ${path_to_cassandra}
  if [[ ${path_to_cassandra} ]]; then
    if [[ ! -d "${path_to_cassandra}/bin" ]]; then
      if [[ ! -d "${path_to_cassandra}bin" ]]; then
        echo "Invalid cassandra directory provided"
        exit 1
      else
        CASSANDRA_BIN="${path_to_cassandra}bin";
      fi
    else
      CASSANDRA_BIN="${path_to_cassandra}/bin";
    fi
  fi

  if type -p cassandra; then
    echo Found cassandra executable in PATH
    _cassandra=cassandra
  elif [[ -n "$CASSANDRA_BIN" ]] && [[ -x "$CASSANDRA_BIN/cassandra" ]];  then
    echo Found cassandra executable in CASSANDRA_BIN
    _cassandra="$CASSANDRA_BIN/cassandra"
  elif [[ -n "$CASSANDRA_HOME" ]] && [[ -x "$CASSANDRA_HOME/bin/cassandra" ]];  then
    echo Found cassandra executable in CASSANDRA_HOME
    _cassandra="$CASSANDRA_HOME/bin/cassandra"
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install cassandra for you?") ]]; then
      bash basic-dep-setup.sh -cassandra
      _cassandra=cassandra
    else
      echo "Please download/install cassandra version ${minVersion}"
      exit 1;
    fi
  fi

  if [[ "$_cassandra" ]]; then
    version_string=$("$_cassandra" -v)
    echo Found cassandra version "$version_string"

    if [[ $version_string =~ ([0-9]+).([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -lt "1") || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" == "1" && "BASH_REMATCH[3]" -lt "11") ]]; then
        printf "The version of cassandra installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install cassandra ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "2" || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" -gt "1") || ("BASH_REMATCH[1]" == "2" && "BASH_REMATCH[2]" == "1" && "BASH_REMATCH[3]" -gt "11") ]]; then
        printf "** The version of cassandra installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of cassandra, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of cassandra that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable cassandra version ${version_string}. Cannot verify cassandra version."
      echo "Please install cassandra ${minVersion} or greater"
      exit 1;
    fi
  fi
}

function verifyMaven {
  minVersion=3.3.9
  if type -p mvn; then
    echo Found mvn executable in PATH
    _mvn=mvn
  else
    if [[ "yes" == $(askYesOrNo "Would you like us to install maven for you?") ]]; then
      bash basic-dep-setup.sh -maven
    else
      echo "Please install maven version ${minVersion} or greater"
      exit 1;
    fi
  fi

  if [[ "$_mvn" ]]; then
    version_string=$("$_mvn" --version)
    echo Found mvn version "$version_string"

    if [[ $version_string =~ ([0-9]+).([0-9]+).([0-9]+) ]]; then
      if [[ "BASH_REMATCH[1]" -lt "3" || ("BASH_REMATCH[1]" == "3" && "BASH_REMATCH[2]" -lt "3") || ("BASH_REMATCH[1]" == "3" && "BASH_REMATCH[2]" == "3" && "BASH_REMATCH[3]" -lt "9") ]]; then
        printf "The version of mvn installed on this machine (${version_string}) is older than the version needed for MSL (${minVersion}). Please install mvn ${minVersion} or greater"
        exit 1
      elif [[ "BASH_REMATCH[1]" -gt "3" || ("BASH_REMATCH[1]" == "3" && "BASH_REMATCH[2]" -gt "3") || ("BASH_REMATCH[1]" == "3" && "BASH_REMATCH[2]" == "3" && "BASH_REMATCH[3]" -gt "9") ]]; then
        printf "** The version of mvn installed on this machine (${version_string}) is newer than the version needed for MSL (${minVersion}). MSL has not been tested using this version of mvn, so you may experience problems. "
        if [[ "no" == $(askYesOrNo "Would you like to continue the installation of MSL using the version of mvn that is currently installed?") ]]; then
          echo "Quitting MSL installation."
          exit 1
        fi
      fi
    else
      echo "Found unparsable mvn version ${version_string}. Cannot verify mvn version."
      echo "Please install mvn ${minVersion} or greater"
      exit 1;
    fi
  fi
}



function verifyNvm {
  if [[ -f ~/.nvm/nvm.sh ]]; then . ~/.nvm/nvm.sh ; fi
  if [[ -f ~/.bashrc ]]; then . ~/.bashrc ; fi
  if [[ -f ~/.profile ]]; then . ~/.profile ; fi
  if [[ -f ~/.zshrc ]]; then . ~/.zshrc ; fi
  
  if type -p nvm; then
      echo Found nvm executable in PATH
  else
    ## not found by path, try looking for it via Homebrew
    if type -p brew; then
      brew ls --versions nvm | grep -e 'nvm\s[0-9]*\.[0-9]*\.[0-9]*'
      if [[ $? -eq 0 ]]; then
        echo Found nvm in Homebrew
      else
        if [[ "yes" == $(askYesOrNo "Would you like us to install nvm for you?") ]]; then
          bash basic-dep-setup.sh -nvm
        else
          echo "Please install nvm"
          exit 1;
        fi
      fi
    else
      echo "Please install nvm"
      exit 1;
    fi
  fi
}

function askYesOrNo() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

function init() {
  verifyNvm
  verifyMaven
  verifyNpm
  validateOS
  verifyJava
  verifyNode
  verifyGit
  validatePorts
  verifyCassandra
  exit 0;
}

echo "Start of Million Song Library validation of required installations script..."
 init
echo "finished Million Song Library validation of required installations."
