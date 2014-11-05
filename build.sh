#!/bin/sh

BASE_DIR=$(cd $(dirname $0) && pwd)
RES_DIR=$BASE_DIR/apache-ant.docset/Contents/Resources
DOCS_DIR=$RES_DIR/Documents
IDX_FILE=$BASE_DIR/apache-ant.docset/Contents/Resources/docSet.dsidx 
rm -rf $RES_DIR
mkdir -p $DOCS_DIR
cp -r $BASE_DIR/apache-ant/manual/* \
      $BASE_DIR/apache-ant.docset/Contents/Resources/Documents

sqlite3 $IDX_FILE <<SQL
  CREATE TABLE searchIndex(
    id INTEGER PRIMARY KEY,
    name TEXT,
    type TEXT,
    path TEXT
  );
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
SQL

insert () {
  idx_name=$1
  idx_type=$2
  idx_path=$3
  echo insert $idx_type $idx_name \($idx_path\)
  sqlite3 $IDX_FILE "\
    INSERT OR IGNORE\
      INTO searchIndex(name, type, path)\
      VALUES ('$idx_name', '$idx_type', '$idx_path');\
  "
}

for file_name in `ls $DOCS_DIR/Tasks`; do
  insert $(basename $file_name .html) Command Tasks/$file_name
done

tar -cvzf apache-ant.tgz apache-ant.docset > /dev/null

