#!/bin/sh -ex

COUCH_SOURCE=/Users/jan/Work/couchdb

usage() {
    echo "Usage: ./runner.sh R14B04 1.2.x small_docs.tpl"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

erlang=$1

if [ -z "$2" ]; then
    usage
fi

couch=$2

if [ -z "$3" ]; then
    usage
fi

bench_tpl=$3

# select Erlang version
brew switch erlang $erlang

# start CouchDB version
BENCH_PWD=`pwd`
cd $COUCH_SOURCE
  git checkout $couchdb
  git clean -fdx
  ./bootstrap
  ./configure
  make -j6
  make dev
  ./utils/run -b
  sleep 3
  curl -sX PUT http://127.0.0.1:5984/_config/log/level -d '"none"'
cd $BENCH_PWD

# run test
./bench.sh $bench_tpl

# stop couch
cd $COUCH_SOURCE
  ./utils/run -d
cd $BENCH_PWD
