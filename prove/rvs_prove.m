function rvs_prove(prover,mdl_name)

% run on gcs unless specified
if nargin<2,
    mdl_name = gcs
end
why_name = sprintf('%s.why',mdl_name);

% build the abstract model
sa = simWhy3Model(mdl_name)
sa.writeToFile(why_name)

% default prover
if nargin<1,
    prover = 'z3';
end

cmd = sprintf('why3 prove -L ../why3lib -P %s -t 10 %s',prover,why_name)
%cmd = sprintf('%s %s %s',which('run_why3.sh'),prover,why_name)

setenv('LD_LIBRARY_PATH')
system(cmd)