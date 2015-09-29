# Connection test

A simple mock-up of the comparative efficiency of database connection pooling techniques in Rails

The test consists of two rails apps, one of which (`without-checkouts`) works the default ActiveRecord
way (one connection will be reserved per thread). The other (`with-checkouts`) manually manages the pool
itself; it checks out a connection separately for each database action.

## Running

You'll probably have to go into one of the Rails apps and set up the database in the usual way, including
seeds. After that, you should be able to run the `run_test.sh` shell script in the root directory of
the repo. It's a fairly basic hacky script, but it has a bunch of moving parts, so I guarantee no 
consistency of operation.
