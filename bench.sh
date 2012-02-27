#!/bin/sh

template="$1"
if [ -z "$template" ]; then
  echo "Usage: $0 <template file>" >&2
  echo '  Optionally export $host, $port, $docs, and $batch' >&2
  exit 1
elif [ ! -f "$template" ]; then
  echo "Usage: $0 <template file> (which actually exists)" >&2
  echo '  Optionally export $host, $port, $docs, and $batch' >&2
  exit 1
fi

[ -z "$host" ] && host="localhost"
[ -z "$port" ] && port="5984"
[ -z "$docs" ] && docs="50000"
[ -z "$batch" ] && batch="10000"
[ -z "$db"   ] && db="db1"

soc="seatoncouch.rb"
couch="http://$host:$port"
URL="$couch/$db"
ddoc="$URL/_design/foo"

cd seatoncouch
ruby "$soc" --dbs 1 --host "$host" --port "$port" --users 0 \
            --db-start-id 0 --db-prefix "$db" --recreate-dbs \
            --docs "$docs" --bulk-batch "$batch" --doc-tpl "../$template"
cd ..

[ $? = 0 ] || exit $?

curl --fail -s "$ddoc" -X PUT -d '{"views":{"bar":{"map":"function(doc) {emit(doc.number, doc.number);}"}}}' > /dev/null
if [ $? != 0 ]; then
  echo "Failed to create design document"
  exit $?
fi

curl -I "$ddoc"

echo "Building view."
time curl "$ddoc/_view/bar?limit=1"
