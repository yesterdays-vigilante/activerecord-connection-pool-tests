# Connection test

A simple mock-up of the comparative efficiency of database connection pooling techniques in Rails

This came out of an issue my team had where our application (which does significant out-of-database
processing and barely any in-database processing) started running out of database connections when
we had a spike in usage. This happened because ActiveRecord will, by default, checkout a connection
then keep it for each request thread, until that thread dies.

The test consists of two rails apps, one of which (`without-checkouts`) works the default ActiveRecord
way (one connection will be reserved per thread). The other (`with-checkouts`) manually manages the pool
itself; it checks out a connection separately for each database action.

## TLDR

If there are more available connections in your pool than simultaneous requests, either way will work fine.
The 'checkout/checkin' *will* incur *very* slight overhead.

On the other hand, if there are less available connections than simultaneous requests:
 * If the database is fast and the app is fast, the results will be much the same as above.
 * If the app is slower than the database, checking out and checking in allows threads to share the database
 connection, which makes requests significantly faster.
 * If the database is slow, the two approaches will be basically equivalently slow.
 * if the overall request time is longer than the pool timeout, the 'peristent-checkout' approach will start dropping
 requests, where the 'checkout/checkin' approach will only do this when any individual database command takes
 longer than the pool timeout

This means for a given size of database box (which is generally the hardest thing to scale), and an app which
does any amount of work outside the database, you can scale out to significantly more web/app boxen since they
are able to share database connections more effectively.

## Running

You'll probably have to go into one of the Rails apps and set up the database in the usual way, including
seeds. After that, you should be able to run the `run_test.sh` shell script in the root directory of
the repo. It's a fairly basic hacky script, but it has a bunch of moving parts, so I guarantee no
consistency of operation.

## Results

From running locally on my development laptop (with Puma configured to go up to 16 request threads),
I got roughly the following results:

### Baseline 'sanity' test with a single stream of requests

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

### Baseline test with four simultaneous requests

         | Current model | With Checkouts
---------|---------------|----------------|
 Maximum | 209ms         | 75ms
 Minimum | 9ms           | 11ms
 Mean    | 33.23ms       | 38.20ms
 Median  | 31ms          | 38ms

These were *very* random. I had to increase the sample size a lot in order to get any consistency at all.
The median/mean/minimum are still pretty close (though slightly *less* close), but the maximum times are
way out, presumably because one request got *really* unlucky and had to wait several times for resource.

### Test with application wait and four simultaneous requests

         | Current model | With Checkouts
---------|---------------|----------------
 Maximum | 2.03s         | 1.04s
 Minimum | 1.02s         | 1.01s
 Mean    | 1.92s         | 1.03s
 Median  | 2.02s         | 1.03s

This was the situation my team had; with a couple of expensive operations or external waits, really whenever
the bottleneck is not the database, the checkout/checkin approach waits much less.

### Test with long (two 3s) database waits and four simultaneous requests

         | Current model | With Checkouts
---------|---------------|----------------
 Maximum | 5.01s         | 12.00s
 Minimum | 7.01s         | 9.02s
 Mean    | 5.90s         | 11.72s
 Median  | 6.01s         | 12.02s
 Dropped | 10            | 0

This was another case I thought would be interesting. The checkout/checkin approach is much slower on average
when there are two long database waits, but this is just because the database, by default, won't wait more than
5s for a connection; all the requests to the connection-per-thread model which didn't get a connection straight
away timed out (hence the 5.0xs responses). An extreme example, but interesting anyway. If the wait is made shorter,
the wait times are equivalent between the two styles.
