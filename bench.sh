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

[ -z "$repo" ] && repo="http://jhs.iriscouch.com/slow_couchdb"
[ -z "$host" ] && host="localhost"
[ -z "$port" ] && port="5984"
[ -z "$docs" ] && docs="50000"
[ -z "$batch" ] && batch="10000"
[ -z "$db"   ] && db="db1"

if [ -t 1 ]; then
  log="trial.$$"
  "$0" "$@" 2>&1 | tee "$log"
  if [ $? = 0 ]; then
    echo "Reporting your trial. ^C to cancel (you have 1 second)."
    sleep 1
    ( /bin/echo -n '{ "trial": "'
      cat "$log" | perl -pe 's|\n|\\n|g; s|"|\\"|g'
      /bin/echo    '"}'
    ) | curl --silent --include -Hcontent-type:application/json -X POST --data-binary @- "$repo"
  fi
  rm -f "$log"
  exit 0
fi

soc="seatoncouch.rb"
couch="http://$host:$port"
URL="$couch/$db"
ddoc="$URL/_design/foo"

echo "Me: $(whoami) on $(hostname)"

disks=$( diskutil list 2> /dev/null | grep ^/dev/ )
if [ $? = 0 -a "$disks" ]; then
  for disk in $disks; do
    echo "Disk: $disk"
    diskutil info "$disk" | egrep 'Media Name|Solid State'
    echo
  done
fi

curl --silent --include "$couch" | egrep '^Server:|"Welcome"'
echo

curl --silent -X PUT "$couch/_config/couchdb/file_compression" -d '"none"'

echo "Testing $docs of $template in batches of $batch"
cd seatoncouch
ruby "$soc" --dbs 1 --host "$host" --port "$port" --users 0 \
            --db-start-id 0 --db-prefix "$db" --recreate-dbs \
            --docs "$docs" --bulk-batch "$batch" --doc-tpl "../$template"
result="$?"

cd ..
[ "$result" = 0 ] || exit $?

curl --silent --fail -s "$ddoc" -X PUT \
     -d '{"views":{"bar":{"map":"function(doc) {emit(doc.number, doc.number);}"}}}' > /dev/null
if [ $? != 0 ]; then
  echo "Failed to create design document"
  exit $?
fi

echo "Building view."
time curl --silent --fail "$ddoc/_view/bar?limit=1&descending=true"
exit $?
