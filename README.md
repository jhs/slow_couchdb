## Prep

    $ git submodule update --init --recursive

Also possibly add gems that seatoncouch needs. They are all in the `gems/` subdirectory.

    $ gem install gems/*

## Usage

1. Start CouchDB. The script assumes defaults from `make dev` (port 5984, etc).
1. Decide which template to use. For now there is only `small_doc.tpl`.
1. Give it to the script: `./bench.sh small_doc.tpl`
