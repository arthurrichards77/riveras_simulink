#!/bin/bash
PROVER=z3 #z3 #alt-ergo #cvc3
why3 prove -P $PROVER -L ../why3lib addsub.why | grep --color -E "Timeout|Unknown|$"
why3 prove -P $PROVER -L ../why3lib mult.why | grep --color -E "Timeout|Unknown|$"
why3 prove -P $PROVER -L ../why3lib delay.why | grep --color -E "Timeout|Unknown|$"
why3 prove -P $PROVER -L ../why3lib quad.why | grep --color -E "Timeout|Unknown|$"
why3 prove -P $PROVER -L ../why3lib feedback.why | grep --color -E "Timeout|Unknown|$"
why3 prove -P $PROVER -L ../why3lib lyap.why | grep --color -E "Timeout|Unknown|$"
