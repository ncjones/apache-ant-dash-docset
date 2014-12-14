#!/bin/sh

#    Dash Docset Generator for Apache Ant
#    Copyright (C) 2014  Nathan Jones
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

BASE_DIR=$(cd $(dirname $0) && pwd)
DOCSET_DIR_NAME=apache-ant.docset
DOCSET_DIR=$BASE_DIR/$DOCSET_DIR_NAME
RES_DIR=$DOCSET_DIR/Contents/Resources
DOCS_DIR=$RES_DIR/Documents
IDX_FILE=$BASE_DIR/apache-ant.docset/Contents/Resources/docSet.dsidx
DOCSET_ZIP_FILE=$BASE_DIR/apache-ant.tgz
ANT_DIR=$BASE_DIR/apache-ant
ANT_DIST_DIR=$ANT_DIR/apache-ant-1.9.4/

if [ ! -d $ANT_DIST_DIR ]; then
    ant -f $ANT_DIR/build.xml dist
fi
rm -rf $RES_DIR
rm -f $DOCSET_ZIP_FILE
mkdir -p $DOCS_DIR
cp -r $ANT_DIST_DIR/manual/* \
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

insert_all () {
  dir=$1
  idx_type=$2
  idx_path_map=$(cat $BASE_DIR/$idx_type.properties)
  for file_name in `ls $dir`; do
    idx_name=$(basename $file_name .html)
    idx_path=$(echo "$idx_path_map" | grep "^$idx_name=" | cut -d= -f2)
    if [ -z $idx_path ]; then
      idx_path=$(basename $dir)/$file_name
    fi
    insert $idx_name $idx_type $idx_path
  done
}

insert_all $DOCS_DIR/Tasks Command
insert_all $DOCS_DIR/Types Type

cd $BASE_DIR && tar -cvzf $DOCSET_ZIP_FILE $DOCSET_DIR_NAME > /dev/null

