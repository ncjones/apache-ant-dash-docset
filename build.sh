#!/bin/sh

BASE_DIR=$(cd $(dirname $0) && pwd)
RES_DIR=$BASE_DIR/apache-ant.docset/Contents/Resources
DOCS_DIR=$RES_DIR/Documents
rm -rf $RES_DIR
mkdir -p $DOCS_DIR
cp -r $BASE_DIR/apache-ant/manual/* \
      $BASE_DIR/apache-ant.docset/Contents/Resources/Documents
sqlite3 $BASE_DIR/apache-ant.docset/Contents/Resources/docSet.dsidx <<SQL
  CREATE TABLE searchIndex(
    id INTEGER PRIMARY KEY,
    name TEXT,
    type TEXT,
    path TEXT
  );
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
SQL

