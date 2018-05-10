#!/usr/bin/env bash

TESTS_RAN=0
PASSED=0
FAILED=()

function test-start() {
	STARTTIME="$(date +%s%N)"
	echo "started \"$1\" test suite"
}

function expect() {
    (( TESTS_RAN++ ))
		CALLING=${FUNCNAME[1]}
		EXPECTED="${@:${#}}"

		if [ $(type -t ${1}) ]; then
			if [ ${#} -le 2 ]; then
				EXPECTED=0
				ARGS=$2
			else
				ARGS=(${@:2:${#}-2})
			fi
			RESULT=$($1 $ARGS)
			RESULT_EXIT_CODE=$?	
			if [[ "$RESULT_EXIT_CODE" -eq "$EXPECTED" ]]; then
					(( PASSED++ ))
					printf .
					PASSED+=("$CALLING" "$1" "${ARGS[@]}" "$EXPECTED" "$RESULT_EXIT_CODE")
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
		ENDTIME="$(date +%s%N)"
    # required visible decimal place for seconds (leading zeros if needed)
    local tests_time="$( \
        printf "%010d" "$(( ${ENDTIME/%N/000000000} 
                            - ${STARTTIME/%N/000000000} ))")"  # in ns
		TIME="${tests_time:0:${#tests_time}-9}.${tests_time:${#tests_time}-9:3}s"
    # create a report
    FAILED_TESTS=${#FAILED[@]}
    echo -e "\ncompleted in $TIME\n\"$1\" test suite results\n"
    echo "Ran ${TESTS_RAN} tests - ${FAILED_TESTS}/${TESTS_RAN} failed, ${PASSED}/${TESTS_RAN} passed"

    # Print trace of failed tests
    if [ ${FAILED_TESTS} -gt 0 ]; then
				echo -e "Failed tests:\n"
        for i in "${FAILED[@]}"; do
            echo -e $i
        done
				exit 1
    else
        echo "All tests in \"$1\" suite passed =D"
				exit 0
    fi
}
