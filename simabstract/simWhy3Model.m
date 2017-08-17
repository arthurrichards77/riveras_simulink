classdef simWhy3Model < simAbstractSyntax
    
    properties(Constant=true)
        known_masks = {'rvsAdd','rvsSubtract','rvsMult','rvsDelay','rvsTranspose'};
        known_blocks = {'Constant'};
        ignore_blocks = {'Inport','Outport','Scope','From','Goto'};
    end
    
    properties
        functions = {};
        axioms = {};
        lemmas = {};
        goals = {};
    end
    
    methods
        
        function obj=simWhy3Model(mdl_name)
            obj=obj@simAbstractSyntax(mdl_name);
            obj.toWhy3()
        end
        
        function disp(obj)
            % dump why3 to screen
            obj.fprintWhy3(1);
        end
        
        function writeToFile(obj,fname)
            if ~exist('fname','var'),
                fname = sprintf('%s.why',obj.mdl_name);
            end
            fid = fopen(fname,'w');
            if fid==-1,
                error('Problem opening file')
            end
            obj.fprintWhy3(fid);
            fclose(fid);
        end
        
        function fprintWhy3(obj,fid)            
            % write header
            fprintf(fid, 'theory T_%s\n\nuse import rvs_matrix.Matrix\nuse import int.Int\n\n',obj.mdl_name)
            % list signals
            for ii=1:obj.num_signals,
                fprintf(fid, '%s',obj.functions{ii});
            end
            % axioms
            for ii=1:numel(obj.axioms),
                fprintf(fid, '%s',obj.axioms{ii});
            end
            % lemmas
            for ii=1:numel(obj.lemmas),
                fprintf(fid, '%s',obj.lemmas{ii});
            end
            % goals
            for ii=1:numel(obj.goals),
                fprintf(fid, '%s',obj.goals{ii});
            end
            % and close the theory
            fprintf(fid, '\nend\n');
        end
        
        function toWhy3(obj)
            % list signals
            for ii=1:obj.num_signals,
                obj.add_function(sprintf('function %s int : matrix\n', simWhy3Model.fix_name(obj.signals{ii}.local_matlab_name)))
            end
            % start with the easily cloned blocks
            for ii=1:obj.num_blocks,
                if strcmp(obj.blocks{ii}.mask_type,'rvsCut'),
                    % special mask - do nothing
                elseif (numel(obj.blocks{ii}.mask_type)==0)&&(numel(obj.blocks{ii}.block_type)==0),
                    % means is top level - do nothing
                elseif strcmp(obj.blocks{ii}.mask_type,'rvsEquiv'),
                    obj.goal_equiv(ii)
                elseif strcmp(obj.blocks{ii}.mask_type,'rvsEquivLemma'),
                    obj.lemma_equiv(ii)
                elseif strcmp(obj.blocks{ii}.mask_type,'rvsConstant'),
                    obj.goal_constant(ii)
                elseif any(strcmp(obj.blocks{ii}.mask_type,obj.known_masks)),
                    obj.clone_mask(ii)
                elseif any(strcmp(obj.blocks{ii}.block_type,obj.known_blocks)),
                    obj.clone_block(ii)
                elseif any(strcmp(obj.blocks{ii}.block_type,obj.ignore_blocks)),
                    % do nothing - blocks intended to be skipped
                else
                    warning(sprintf('Cannot convert block: %s (Mask type: %s ; Block type: %s)',obj.blocks{ii}.matlab_name,obj.blocks{ii}.mask_type,obj.blocks{ii}.block_type))
                end
            end
        end
        
        function add_function(obj,str)
            obj.functions = {obj.functions{:},str};
        end
        
        function add_axiom(obj,str)
            obj.axioms = {obj.axioms{:},str};
        end
        
        function add_lemma(obj,str)
            obj.lemmas = {obj.lemmas{:},str};
        end
        
        function add_goal(obj,str)
            obj.goals = {obj.goals{:},str};
        end
        
        function clone_mask(obj,ii)
            s = '';
            s = [s sprintf( '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf( '  clone rvs_simulink.T_%s with', obj.blocks{ii}.mask_type)];
            for jj=1:obj.blocks{ii}.num_inputs,
                if jj>1,
                    s = [s sprintf(',')];
                end
                s = [s sprintf(' function in%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.inputs{jj}.matlab_name))];
            end
            for jj=1:obj.blocks{ii}.num_outputs,
                if jj>1,
                    s = [s sprintf(',')];
                elseif obj.blocks{ii}.num_inputs>0,
                    s = [s sprintf(',')];
                end
                s = [s sprintf(' function out%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.outputs{jj}.matlab_name))];
            end
            s = [s sprintf( '\nend\n')];
            obj.add_axiom(s)
        end
        
        function clone_block(obj,ii)
            s = '';
            s = [s sprintf( '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf( '  clone rvs_simulink.T_%s with', obj.blocks{ii}.block_type)];
            for jj=1:obj.blocks{ii}.num_inputs,
                if jj>1,
                    s = [s sprintf(',')];
                end
                s = [s sprintf(' function in%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.inputs{jj}.matlab_name))];
            end
            for jj=1:obj.blocks{ii}.num_outputs,
                if jj>1,
                    s = [s sprintf(',')];
                elseif obj.blocks{ii}.num_inputs>0,
                    s = [s sprintf(',')];
                end
                s = [s sprintf(' function out%d = %s',jj,simWhy3Model.fix_name(obj.blocks{ii}.outputs{jj}.matlab_name))];
            end
            s = [s sprintf( '\nend\n')];
            obj.add_axiom(s)
        end
        
        function goal_equiv(obj,ii)
            assert(obj.blocks{ii}.num_inputs==2)
            s = '';
            s = [s sprintf( '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf( '  goal G_%s: forall k: int. ', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf(' %s k = ',simWhy3Model.fix_name(obj.blocks{ii}.inputs{1}.matlab_name))];
            s = [s sprintf(' %s k',simWhy3Model.fix_name(obj.blocks{ii}.inputs{2}.matlab_name))];
            s = [s sprintf( '\nend\n')];
            obj.add_goal(s);
        end
        
        function lemma_equiv(obj,ii)
            assert(obj.blocks{ii}.num_inputs==2)
            s = '';
            s = [s sprintf( '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf( '  lemma G_%s: forall k: int. ', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf(' %s k = ',simWhy3Model.fix_name(obj.blocks{ii}.inputs{1}.matlab_name))];
            s = [s sprintf(' %s k',simWhy3Model.fix_name(obj.blocks{ii}.inputs{2}.matlab_name))];
            s = [s sprintf( '\nend\n')];
            obj.add_lemma(s);
        end
        
        function goal_constant(obj,ii)
            assert(obj.blocks{ii}.num_inputs==1)
            s = '';
            s = [s sprintf( '\nnamespace NS_%s\n', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf( '  lemma G_%s: forall k: int. ', simWhy3Model.fix_name(obj.blocks{ii}.matlab_name))];
            s = [s sprintf(' %s k = ',simWhy3Model.fix_name(obj.blocks{ii}.inputs{1}.matlab_name))];
            s = [s sprintf(' %s (k-1)',simWhy3Model.fix_name(obj.blocks{ii}.inputs{1}.matlab_name))];
            s = [s sprintf( '\nend\n')];
            obj.add_lemma(s);
        end
        
    end
    
    methods(Static)
        
        function why3_name = fix_name(matlab_name)
            why3_name = strrep(matlab_name,'/','_');
            why3_name = strrep(why3_name,' ','_');
            why3_name = strrep(why3_name,sprintf('\n'),'_');
            why3_name = strrep(why3_name,sprintf('\r'),'_');
        end
        
    end
    
end