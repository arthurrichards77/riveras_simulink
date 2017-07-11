#!/bin/bash
why3 prove -P cvc3 -L ../why3lib rvs_test.why
why3 prove -P cvc3 -L ../why3lib mult.why
why3 prove -P cvc3 -L ../why3lib mult2.why
why3 prove -P cvc3 -L ../why3lib delay.why
#why3 prove -P cvc3 -L ../why3lib feedback.why
