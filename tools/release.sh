#!/bin/bash

# Bash script that helps with releasing new versions of QML Logging
# Revision: 1.0
# @author mkhan3189
#
# Usage:
#        ./release.sh [repo-root] [homepage-repo-root] [new-version] [do-not-ask]

if [ "$1" = "" ];then
  echo
  echo "Usage: $0 [repository-root] [homepage-root] [new-version] [do-not-ask]"
  echo
  exit 1
fi

if [ -f "$1/tools/release.sh" ];then
  [ -d "$2/releases/" ] || mkdir $2/releases/
else
  echo "Invalid repository root"
  exit 1
fi

CURR_VERSION=$(grep 'QmlLogging v' $1/src/qmllogging.h | grep -o '[0-9].[0-9]')
CURR_RELEASE_DATE=$(grep -o '[0-9][0-9]-[0-9][0-9]-201[2-9] [0-9][0-9][0-9][0-9]hrs' $1/src/qmllogging.h)
NEW_RELEASE_DATE=$(date +"%d-%m-%Y %H%Mhrs")
NEW_VERSION=$3
DO_NOT_CONFIRM=$4
if [ "$NEW_VERSION" = "" ]; then
  echo 'Current Version  ' $CURR_VERSION
  echo '** No version provided **'
  exit
fi

echo 'Current Version  ' $CURR_VERSION ' (' $CURR_RELEASE_DATE ')'
echo 'New Version      ' $NEW_VERSION  ' (' $NEW_RELEASE_DATE ')'
if [ "$DO_NOT_CONFIRM" = "y" ]; then
  confirm="y"
else
  echo 'Are you sure you wish to release new version? (y/n)' 
  read confirm
fi

if [ "$confirm" = "y" ]; then
  sed -i "s/QmlLogging v$CURR_VERSION*/QmlLogging v$NEW_VERSION/g" $1/src/qmllogging.h
  sed -i "s/version(void) { return QString(\"$CURR_VERSION\"); }/version(void) { return QString(\"$NEW_VERSION\"); }/g" $1/src/qmllogging.h
  sed -i "s/releaseDate(void) { return QString(\"$CURR_RELEASE_DATE\"); }/releaseDate(void) { return QString(\"$NEW_RELEASE_DATE\"); }/g" $1/src/qmllogging.h
  sed -i "s/ (development \/ unreleased version)//g" $1/src/qmllogging.h
  sed -i "s/\$currentVersion = \"$CURR_VERSION\"*/\$currentVersion = \"$NEW_VERSION\"/g" $2/version.php
  sed -i "s/\$releaseDate = \"$CURR_RELEASE_DATE\"*/\$releaseDate = \"$NEW_RELEASE_DATE\"/g" $2/version.php
  sed -i "s/$CURR_RELEASE_DATE/$NEW_RELEASE_DATE/g" $2/version.php
  sed -i "s/v$CURR_VERSION/v$NEW_VERSION/g" $1/README.md
  sed -i "s/qmllogging_$CURR_VERSION.zip/qmllogging_$NEW_VERSION.zip/g" $1/README.md
  if [ -f "qmllogging_v$NEW_VERSION.zip" ]; then
    rm qmllogging_v$NEW_VERSION.zip
  fi
  if [ -f "qmllogging.zip" ]; then
    rm qmllogging.zip
  fi
  cp $1/src/qmllogging.h .
  zip qmllogging_v$NEW_VERSION.zip qmllogging.h
  tar -pczf qmllogging_v$NEW_VERSION.tar.gz qmllogging.h
  zip latest.zip qmllogging.h
  mv latest.zip $2/
  mv qmllogging_v$NEW_VERSION.zip $2/releases/
  mv qmllogging_v$NEW_VERSION.tar.gz $2/releases/
  cp $1/doc/RELEASE-NOTES-v$NEW_VERSION $2/release-notes-latest.txt
  cp $1/doc/RELEASE-NOTES-v$NEW_VERSION $2/releases/release-notes-v$NEW_VERSION.txt
  rm qmllogging.h
fi
