% build the abstract model
sa = simWhy3Model('rvs_testing')

sa.writeToFile('rvs_test.why')

!why3 prove -L ../why3lib -P cvc3 -t 10 rvs_test.why