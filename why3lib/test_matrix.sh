#!/bin/bash
why3 prove -P cvc3 rvs_matrix.why | grep --color=always -E "Unknown|Timeout|$"
#why3 prove -P cvc3 rvs_matrix.why | grep --color=always -E "Unknown|Timeout|$" | GREP_COLOR='01;32' grep --color -E "Valid|$"
#why3 prove -P z3 rvs_matrix.why | grep --color=always -E "Unknown|Timeout|$"
