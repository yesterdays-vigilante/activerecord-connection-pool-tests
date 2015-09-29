#!/bin/bash

function hit_service() {
    echo -n  > "output/${1}"

    # The first request tends to be really slow because the DB doesn't have the query cached yet; remove this outlier
    curl localhost:3000 > /dev/null 2>&1
    for i in `seq 1 ${2}`
    do
        curl --fail -o /dev/null -w "%{time_total}\n" localhost:3000/${3} >> "output/${1}" 2> /dev/null

        if [ $? != 0 ]
        then
            echo "CONNECTION DIED!"
        fi
    done
}

function hit_service_threaded() {
    for i in `seq 1 ${1}`
    do
        hit_service ${2} ${3} ${4} &
        wait_pids="$wait_pids  $!"
    done

    for pid in $wait_pids
    do
        wait $pid
    done

    unset wait_pids
}

mkdir -p output
export SECRET_KEY_BASE='whocares'

###################################
# TESTS FOR THE EXISTING PARADIGM #
###################################

echo "TESTING EXISTING PARADIGM"

cd without-checkouts
RAILS_ENV=production rails s > /dev/null 2>&1 &
sleep 2
RAILS_PID=$!

cd ..

echo "  RUNNING SINGLE THREADED BASELINE TEST"

hit_service baseline-without-checkouts-1 100

echo "  RUNNING TEST WITH FOUR THREADS"

hit_service_threaded 4 baseline-without-checkouts-4 25

echo "  RUNNING TEST WITH FOUR THREADS AND AN APP WAIT OF 1s"

hit_service_threaded 4 app-wait-without-checkouts-4 5 'app_wait?time=0.5'

echo "  RUNNING TEST WITH FOUR THREADS AND A DB WAIT OF 6s"

hit_service_threaded 4 db-wait-without-checkouts-4 5 'db_wait?time=3'

kill $RAILS_PID
sleep 1

#################################
# TESTS WITH EXPLICIT CHECKOUTS #
#################################

echo "TESTING EXPLICIT CHECKOUTS"

cd with-checkouts
RAILS_ENV=production rails s > /dev/null 2>&1 &
RAILS_PID=$!
sleep 2
cd ..

echo "  RUNNING SINGLE THREADED BASELINE TEST"

hit_service baseline-with-checkouts-1 100

echo "  RUNNING TEST WITH FOUR THREADS"

hit_service_threaded 4 baseline-with-checkouts-4 25

echo "  RUNNING TEST WITH FOUR THREADS AND AN APP WAIT OF 1s"

hit_service_threaded 4 app-wait-with-checkouts-4 5 'app_wait?time=0.5'

echo "  RUNNING TEST WITH FOUR THREADS AND A DB WAIT OF 6s"

hit_service_threaded 4 db-wait-with-checkouts-4 5 'db_wait?time=3'

kill $RAILS_PID
sleep 1
