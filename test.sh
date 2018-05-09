#!/usr/bin/env bash

TESTS_RAN=0
PASSED=()
FAILED=()

function err() {
    echo "Expected ${1} to eq ${2}"
    exit 1
}

function expect() {
    (( TESTS_RAN++ ))
    RESULT=$($1 $2)
    CALLING=${FUNCNAME[1]}

    if [[ "$RESULT" -eq "$3" ]]; then
        PASSED+=("$CALLING" "$1" "$2" "$3" "$RESULT")
    else
        FAILED+=("$CALLING" "$1" "$2" "$3" "$RESULT")
    fi
}

function test-end() {
    # create a report

    PASSED_TESTS=$((${#PASSED[@]} / 5 ))
    FAILED_TESTS=$((${#FAILED[@]} / 5 ))
    echo -e "$1 suite results:\n"
    echo "Ran ${TESTS_RAN} tests - ${FAILED_TESTS}/${TESTS_RAN} failed, ${PASSED_TESTS}/${TESTS_RAN} passed"
    # Print trace of failed tests
    if [ ${FAILED_TESTS} -gt 0 ]; then
        for i in $(seq 0 $((${FAILED_TESTS} - 1))); do
            INDEX=$(($i * 4))
            TEST_CMD=${FAILED[$INDEX]}
            CMD=${FAILED[$(($INDEX + 1))]}
            ARGS=${FAILED[$(($INDEX + 2))]}
            EXPECTED=${FAILED[$(($INDEX + 3))]}
            RES=${FAILED[$(($INDEX + 4))]}
            echo ${TEST_CMD} failed:
            echo ${CMD} with args \"${ARGS}\" expected exit code ${EXPECTED} but got ${RES}
        done
    else
        echo "All tests in $1 suite passed =D"
    fi
}