mdl_name = gcs;
why_name = sprintf('%s.why',mdl_name);

% build the abstract model
sa = simWhy3Model(mdl_name)
sa.writeToFile(why_name)

cmd = sprintf('why3 prove -L ../why3lib -P cvc3 -t 10 %s',why_name)
system(cmd)