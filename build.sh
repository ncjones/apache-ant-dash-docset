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

insert_all () {
  dir=$1
  idx_type=$2
  for file_name in `ls $dir`; do
	  insert $(basename $file_name .html) \
	         $idx_type \
		 $(basename $dir)/$file_name
  done
}

insert_all $DOCS_DIR/Tasks Command
insert_all $DOCS_DIR/Types Type

tar -cvzf apache-ant.tgz apache-ant.docset > /dev/null

