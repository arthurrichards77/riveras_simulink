#!/bin/bash
why3 prove -L ../why3lib rvs_test.why
why3 prove -P cvc3 -L ../why3lib rvs_test.why
