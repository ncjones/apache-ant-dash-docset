#!/bin/sh

BASE_DIR=$(cd $(dirname $0) && pwd)
DOCS_DIR=$BASE_DIR/apache-ant.docset/Contents/Resources/Documents
rm -rf $DOCS_DIR
mkdir -p $DOCS_DIR
cp -r $BASE_DIR/apache-ant/manual/* \
      $BASE_DIR/apache-ant.docset/Contents/Resources/Documents


