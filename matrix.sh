#!/bin/sh -e

ERLANGS="\
    R14B04 \
    R15B \
    "

COUCHDBS="\
    1.1.1 \
    1.2.x \
    "

DOCS="\
    small_doc.tpl \
    seatoncouch/default_doc.tpl \
    seatoncouch/templates/wow.tpl \
    seatoncouch/templates/nested_6k.tpl \
    "

for erlang in $ERLANGS; do
    for couchdb in $COUCHDBS; do
        for doc in $DOCS; do
            echo "Running Erlang $erlang  with CouchDB $couchdb and doc $doc"
            ./runner.sh $erlang $couchdb $doc
        done
    done
done
