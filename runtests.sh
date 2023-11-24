#!/bin/bash

TESTMODULE="auction_test.py"
#TESTMODULE="test_auction2.py"

# arrays to record the results. Elements are appended.
expect=("")
actual=("")

# Target and variants
TARGET=auction.py
if [ -d oracle ]; then
   DIR=oracle
else
   DIR=.
fi
# instrumented auction code (variants)
VARIANT_CODE=$DIR/auction_bugs.py
# Strings to describe test success/failure
PASS="OK"
FAIL="Fail"

drawline( ) {
    echo "----------------------------------------------------------------------"
}

runtests( ) {
    if [ ! -f $VARIANT_CODE ]; then
        echo "No file ${VARIANT_CODE}"
        exit 1
    fi
    # backup student file
    if [ ! -f auction_orig.py ]; then
        cp $TARGET auction_orig.py
    fi
	cp $VARIANT_CODE $TARGET

	for testcase in 1 2 3 4 5 6 7 8; do
        echo ""
        drawline
		expect+=($FAIL)
		case $testcase in
    	1)
			echo "AUCTION CODE 1: All methods work according to specification. Your tests should PASS."
			expect[1]=$PASS
       		;;
		3)
			echo "AUCTION CODE 3: The auction is not rejecting some invalid bids."
			;;
		4 )
			echo "AUCTION CODE 4: The auction is not enforcing state correctly."
			;;
		5)
			echo "AUCTION CODE 5: A problem is being silently ignored."
			;;
		6)
			echo "AUCTION CODE 6: The auction is not setting its state correctly."
			;;
		8)
			echo "AUCTION CODE 8: Two errors in Auction. Do your tests detect BOTH defects?"
			;;
    	*)
			echo "AUCTION CODE ${testcase}: Some error in auction. At least one test should FAIL."
			;;
		esac
        drawline
		export TESTCASE=$testcase
		python3 -m unittest -v $TESTMODULE
		if [ $? -eq 0 ]; then
			actual+=($PASS)
		else
			actual+=($FAIL)
		fi
		# wait til user presses enter?
		#read input
	done
}

showresults() {
    drawline
    echo "Results of Testing All Target Codes"
    drawline
    echo "${PASS}=all tests pass, ${FAIL}=some tests fail"
    echo ""
    echo " Code#   Expected  Actual"
    failures=0

    for testcase in ${!expect[@]}; do
        # didn't use element 0
        if [ $testcase -eq 0 ]; then continue; fi
        printf "%4d      %-4s     %s\n" ${testcase} ${expect[$testcase]} ${actual[$testcase]}
        if [ ${expect[$testcase]} != ${actual[$testcase]} ]; then
            failures=$(($failures+1))
        fi
    done
    correct=$((8-$failures))
    echo "$correct Correct  $failures Incorrect"
    exit $failures
}

runtests
showresults
