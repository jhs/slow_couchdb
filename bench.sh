#!/bin/sh

URL="localhost:5984/db1"

curl -s -X DELETE $URL > /dev/null
curl -s -X PUT    $URL > /dev/null

BULK_SIZE=1000
BULK_COUNT=50

BULK='{"docs":['
for I in `seq 1 $BULK_SIZE`
do
    BULK="$BULK {\"number\":$I}"
    if [[ $I -ne $BULK_SIZE ]]; then
        BULK="$BULK,"
    fi
done
BULK="$BULK ]}"

echo "Filling db."
for I in `seq 1 $BULK_COUNT`
do
    curl -s -Hcontent-type:application/json $URL/_bulk_docs -d "$BULK"  > /dev/null
done
echo "done"

curl -s $URL/_design/foo -X PUT -d '{"views":{"bar":{"map":"function(doc) {emit(doc.number, doc.number);}"}}}' > /dev/null

echo "Building view."
time curl -s $URL/_design/foo/_view/bar?limit=10 > /dev/null
echo "done"
