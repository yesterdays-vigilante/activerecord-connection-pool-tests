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

## Results

From running locally on my development laptop, I got roughly the following results:

### Baseline 'sanity' test (single-threaded)

         | Current model | With Checkouts
---------|---------------|----------------
 Maximum | 32ms          | 27ms
 Minimum | 8ms           | 9ms
 Mean    | 9.81s         | 12.14ms
 Median  | 9ms           | 11ms

This test is pretty trivial (hence the tiny numbers). There's ten database accesses in there, but since the
database I'm connecting to is local, there's very little latency. You can see that the version with checkouts
around each use of the database is slightly slower at this point; this makes sense, because it's going through
the checkout/checkin process nine more times than the current model.

### Baseline test with four threads

         | Current model | With Checkouts
---------|---------------|----------------|
 Maximum | 209ms         | 75ms
 Minimum | 9ms           | 11ms
 Mean    | 33.23ms       | 38.20ms
 Median  | 31ms          | 38ms

These were *very* random. I had to increase the sample size a lot in order to get any consistency at all.
The median/mean/minimum are still pretty close (though slightly *less* close), but the maximum times are
way out, presumably because one request got *really* unlucky and had to wait several times for resource.

### Test with application wait and four threads

         | Current model | With Checkouts
---------|---------------|----------------
 Maximum | 1.02s         | 1.01s
 Minimum | 2.03s         | 1.04s
 Mean    | 1.92s         | 1.03s
 Median  | 2.02s         | 1.03s

This was the situation my team had; with a couple of expensive operations or external waits, really whenever
the bottleneck is not the database, the checkout/checkin approach waits much less.

### Test with long (two 3s) database waits and four threads

         | Current model | With Checkouts
---------|---------------|----------------
 Maximum | 7.01s         | 9.02s
 Minimum | 5.01s         | 12.00s
 Mean    | 5.90s         | 11.72s
 Median  | 6.01s         | 12.02s

This was another case I thought would be interesting. The checkout/checkin approach is much slower on average
when there are two long database waits, but this is just because the database, by default, won't wait more than
5s for a connection and therefore all the threads in the current model which didn't get a connection straight
away timed out (hence the 5.0xs responses). An extreme example, but interesting anyway.
