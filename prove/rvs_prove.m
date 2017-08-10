function sa = rvs_prove(prover,mdl_name)

% run on gcs unless specified
if nargin<2,
    mdl_name = gcs
end

% chop off everything after any first slash
first_delimit = find(mdl_name=='/',1,'first');
if ~isempty(first_delimit),
    mdl_name = mdl_name(1:(first_delimit-1));
    warning('Working from top level of the model')
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

% path messing abaht: MATLAB sets something that conflicts with why3
setenv('LD_LIBRARY_PATH')

% run it
system(cmd)