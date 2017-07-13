mdl_name = gcs;
why_name = sprintf('%s.why',mdl_name);

% build the abstract model
sa = simWhy3Model(mdl_name)
sa.writeToFile(why_name)

setenv('LD_LIBRARY_PATH')
prover = 'cvc3';
prover = 'z3';

cmd = sprintf('why3 prove -L ../why3lib -P %s -t 10 %s',prover,why_name)
%cmd = sprintf('%s %s %s',which('run_why3.sh'),prover,why_name)
system(cmd)