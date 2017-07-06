classdef simWhy3Model < simAbstractSyntax
    
    properties(Constant=true)
        known_masks = {'rvsAdd','rvsSubtract'};
    end
    
    methods
        
        function obj=simWhy3Model(mdl_name)
            obj=obj@simAbstractSyntax(mdl_name);
        end
        
        function toWhy3(obj,fid)
            % by default, print to screen
            if ~exist('fid','var'),
                fid=1;
            end
            if isempty(fid),
                fid=1;
            end           
            % write header
            fprintf(fid, 'theory T_%s\n\nuse import rvs_matrix.Matrix\n\n',obj.mdl_name)
            % list signals
            for ii=1:obj.num_signals,
                fprintf(fid, 'function %s int : matrix\n', simWhy3Model.fix_name(obj.signals{ii}.local_matlab_name));
            end
            % start with the easily cloned blocks
            for ii=1:obj.num_blocks,
                if any(strcmp(obj.blocks{ii}.mask_type,obj.known_masks)),
                    obj.clone_block(fid,ii)
                elseif strcmp(obj.blocks{ii}.mask_type,'rvsEquiv'),
                    % do nothing for now - will do all goals at the end
                else,
                    warning(sprintf('Cannot convert block: %s',obj.blocks{ii}.matlab_name))
                end
            end
            % do the goals last
            for ii=1:obj.num_blocks,
                if strcmp(obj.blocks{ii}.mask_type,'rvsEquiv'),
                    obj.goal_equiv(fid,ii)
                end
            end
            % and close the theory
            fprintf(fid, '\nend\n');
        end
        
        function disp(obj)
            % dump why3 to screen
            obj.toWhy3(1);
        end
        
        function writeToFile(obj,fname)
            if ~exist('fname','var'),
                fname = sprintf('%s.why',obj.mdl_name);
            end
            fid = fopen(fname,'w');
            if fid==-1,
                error('Problem opening file')
            end
            obj.toWhy3(fid);
            fclose(fid);
        end
        
        function clone_block(obj,fid,ii)
            fprintf(fid, '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name));
            fprintf(fid, '  clone rvs_simulink.T_%s with', obj.blocks{ii}.mask_type);
            for jj=1:obj.blocks{ii}.num_inputs,
                if jj>1,
                    fprintf(fid,',');
                end
                fprintf(fid,' function in%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.inputs{jj}.matlab_name));
            end
            for jj=1:obj.blocks{ii}.num_outputs,
                if jj>1,
                    fprintf(fid,',');
                elseif obj.blocks{ii}.num_inputs>0,
                    fprintf(fid,',');
                end
                fprintf(fid,' function out%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.outputs{jj}.matlab_name));
            end
            fprintf(fid, '\nend\n');
        end
        
        function goal_equiv(obj,fid,ii)
            assert(obj.blocks{ii}.num_inputs==2)
            fprintf(fid, '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name));
            fprintf(fid, '  goal G_%s: forall k: int. ', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name));
            fprintf(fid,' %s k = ',simWhy3Model.fix_name(obj.blocks{ii}.inputs{1}.matlab_name));
            fprintf(fid,' %s k',simWhy3Model.fix_name(obj.blocks{ii}.inputs{2}.matlab_name));
            fprintf(fid, '\nend\n');
        end

    end
    
    methods(Static)
        
        function why3_name = fix_name(matlab_name)
            why3_name = strrep(matlab_name,'/','_');
        end
        
    end
    
end