#!/bin/bash
PROVER=z3 #alt-ergo #cvc3
why3 prove -P $PROVER -L ../why3lib addsub.why
why3 prove -P $PROVER -L ../why3lib mult.why
why3 prove -P $PROVER -L ../why3lib delay.why
why3 prove -P $PROVER -L ../why3lib quad.why
why3 prove -P $PROVER -L ../why3lib feedback.why
why3 prove -P $PROVER -L ../why3lib lyap.why
