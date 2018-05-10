#!/usr/bin/env bash

TESTS_RAN=0
PASSED=0
FAILED=()

function test-start() {
	START_TIME="$(date +%s%N)"
	echo "started \"$1\" test suite"
}

function contains() {
    [[ "$1" != *"$2"* ]] && echo 1 || :
    expect $? 0
}

function expect() {
    (( TESTS_RAN++ ))
    CALLING=${FUNCNAME[1]}
    EXPECTED="${@:${#}}"

    if [ $(type -t "${1}") ]; then
        if [ ${#} -le 2 ]; then
            EXPECTED=0
            ARGS=$2
        else
            ARGS=(${@:2:${#}-2})
        fi
        RESULT=$($1 "$ARGS")
        RESULT_EXIT_CODE=$?
        if [[ "$RESULT_EXIT_CODE" -eq "$EXPECTED" ]]; then
                (( PASSED++ ))
                printf .
        else
                CALLER=($(caller))
                LINE_NO=${CALLER[0]}
                FILENAME=$(echo ${CALLER[1]} | rev | cut -d'/' -f1 | rev)
                FAILED+=("\t$FILENAME: ($CALLING:$LINE_NO) \"$1\" returned $RESULT_EXIT_CODE, expected $EXPECTED")
                printf F
        fi
    else
        if [ ${#} -eq 1 ]; then
            EXPECTED=''
        fi
        # Assume it's a plain equality check
        # in this case we will only have two args: Expected and Result
        if [ "$1" -eq "$2" ] 2>/dev/null|| [ "$1" = "$2" ] 2>/dev/null; then
                (( PASSED++ ))
                printf .
        else
                # Where did the test fail?
                CALLER=($(caller))
                LINE_NO=${CALLER[0]}
                FILENAME=$(echo ${CALLER[1]} | rev | cut -d'/' -f1 | rev)
                FAILED+=("\t$FILENAME: ($CALLING:$LINE_NO) \"$1\" is not equal to \"$EXPECTED\"")
                printf F
        fi
    fi
}

function test-end() {
    END_TIME="$(date +%s%N)"
    # required visible decimal place for seconds (leading zeros if needed)
    TEST_TIME=$(printf "%010d" "$(( ${END_TIME/%N/000000000} - ${START_TIME/%N/000000000} ))") # in ns
    TIME="${TEST_TIME:0:${#TEST_TIME}-9}.${TEST_TIME:${#TEST_TIME}-9:3}s"

    # create a report
    FAILED_TESTS=${#FAILED[@]}
    echo -e "\ncompleted in $TIME\n\"$1\" test suite results\n"
    echo "Ran ${TESTS_RAN} tests - ${FAILED_TESTS}/${TESTS_RAN} failed, ${PASSED}/${TESTS_RAN} passed"

    # Print trace of failed tests
    if [ ${FAILED_TESTS} -gt 0 ]; then
				echo -e "Failed tests:\n"
        for ERROR in "${FAILED[@]}"; do
            echo -e "$ERROR"
        done
				exit 1
    else
        echo "All tests in \"$1\" suite passed =D"
				exit 0
    fi
}
