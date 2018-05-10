#!/usr/bin/env bash

TESTS_RAN=0
PASSED=()
FAILED=()

function expect() {
    (( TESTS_RAN++ ))
		ARGS=(${@:2:${#}-2})
    RESULT=$($1 $ARGS)
    CALLING=${FUNCNAME[1]}
		EXPECTED="${@:${#}}"

    if [[ "$RESULT" -eq "$EXPECTED" ]]; then
        PASSED+=("$CALLING" "$1" "${ARGS[@]}" "$EXPECTED" "$RESULT")
    else
				ARGS_PP=$(echo "${ARGS[*]}" | sed 's/ /, /g')
        FAILED+=("\tTEST FUNCTION: $CALLING:\n\t  function $1( $ARGS_PP ) returned "$RESULT" but expected "$EXPECTED"")
    fi
}

function test-end() {
    # create a report
    PASSED_TESTS=$((${#PASSED[@]} / 5 ))
    FAILED_TESTS=${#FAILED[@]}
    echo -e "$1 suite results:\n"
    echo "Ran ${TESTS_RAN} tests - ${FAILED_TESTS}/${TESTS_RAN} failed, ${PASSED_TESTS}/${TESTS_RAN} passed"

    # Print trace of failed tests
    if [ ${FAILED_TESTS} -gt 0 ]; then
				echo -e "Failed tests:\n"
        for i in "${FAILED[@]}"; do
            echo -e $i
        done
				exit 1
    else
        echo "All tests in $1 suite passed =D"
				exit 0
    fi
}
