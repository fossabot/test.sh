#!/usr/bin/env bash

TESTS_RAN=0
PASSED=0
FAILED=()

function expect() {
    (( TESTS_RAN++ ))
		CALLING=${FUNCNAME[1]}
		EXPECTED="${@:${#}}"

		if [ $(type -t ${1}) ]; then
			ARGS=(${@:2:${#}-2})
			RESULT=$($1 $ARGS)
			if [[ "$RESULT" -eq "$EXPECTED" ]]; then
					(( PASSED++ ))
					PASSED+=("$CALLING" "$1" "${ARGS[@]}" "$EXPECTED" "$RESULT")
			else
					CALLER=($(caller))
					LINE_NO=${CALLER[0]}
					FILENAME=$(echo ${CALLER[1]} | rev | cut -d'/' -f1 | rev)
					FAILED+=("\t$FILENAME: ($CALLING:$LINE_NO) \"$1\" returned $RESULT, expected $EXPECTED")
			fi
		else
			# Assume it's a plain equality check
			# in this case we will only have two args: Expected and Result
			if [[ "$1" -eq "$2" ]] || [[ "$1" == "$2" ]]; then
					(( PASSED++ ))
			else
					# Where did the test fail?
					CALLER=($(caller))
					LINE_NO=${CALLER[0]}
					FILENAME=$(echo ${CALLER[1]} | rev | cut -d'/' -f1 | rev)
					FAILED+=("\t$FILENAME: ($CALLING:$LINE_NO) $1 is not equal to "$EXPECTED"")
			fi
		fi	
}

function test-end() {
    # create a report
    FAILED_TESTS=${#FAILED[@]}
    echo -e "$1 suite results:\n"
    echo "Ran ${TESTS_RAN} tests - ${FAILED_TESTS}/${TESTS_RAN} failed, ${PASSED}/${TESTS_RAN} passed"

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
