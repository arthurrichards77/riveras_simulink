#!/bin/bash
why3 prove -P cvc3 rvs_matrix.why | GREP_COLOR='1;32' grep -E --color "Valid|$"
