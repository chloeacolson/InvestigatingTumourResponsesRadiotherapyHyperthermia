%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: - Code used to compare the efficacy of the different RT, HT and
%             RT + HT schedules considered in the paper, and to determine
%             the most effective treatment and dosing regimen for each 
%             tumour in each regime 
%           - Assume that the file in location 'file_path' contains the
%           parameters values that define the tumours of interest, i.e., 
%           the oxygen consumption rates, q1 and q3, the vascular volume,
%           V0, and the steady state tumour volume and oxygen
%           concentration,T0 and c0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Step Ia
% Compare the efficacy of comparable RT, HT and RT+HT treatment schedules
% considered in the paper

% 'data' is a table containing the following columns (at a minimum):
%   - ID                (tumour ID)
%   - q1                (oxygen consumption rate for maintenance)
%   - q3                (oxygen consumption rate for proliferation)
%   - regime            (growth regime of each tumour: NL, SL and/or BS)
%   - N_{frac}          (number of weekly RT fractions)
%   - R                 (RT dose rate)
%   - beta              (high HT dose rate)
%   - Delta_viable_HR   (reduction in viable volume for RT+HT)
%   - Delta_total_HR    (reduction in total volume for RT+HT)
%   - Delta_V_H         (reduction in vascular volume for RT+HT)
%   - Delta_viable_H    (reduction in viable volume for HT)
%   - Delta_total_H     (reduction in total  volume for HT)  
%   - Delta_V_H         (reduction in vascular volume for HT)
%   - Delta_viable_R    (reduction in viable volume for RT)
%   - Delta_total_R     (reduction in total  volume for RT)
%   - Delta_V_R         (reduction in vascular  volume for RT - this is 0)


% Assume that kappa_0 and the order and delay between RT and HT during
% combined treatment are fixed for the data in 'data'

% 'P' is the percent increase the reductions in viable and total tumour 
% volume obtained by combining RT and HT needed for RT+HT to be considered 
% more effective than RT and HT
P = 10; 

% 'regions' is a string ranking comparable RT, HT and RT+HT treatments for
% each tumour, such that negative treatments are excluded from
% consideration
regions = strings(size(data,1),1);
for i = 1:size(data,1)
    if (data.Delta_V_HR(i) > 0) && (data.Delta_V_H(i) > 0) % HT and RT+HT have negative effect due to vascular growth
        if (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) % RT has a positive effect
            regions(i) = "$\mathrm{RT}$";
        else % RT has a negative effect
            regions(i)= "No treatment";
        end
    elseif (data.Delta_V_HR(i) > 0) &&  (data.Delta_V_H(i) < 0) % RT+HT has a negative effect due to vascular growth but HT reduces vascular volume
        if (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
           ((data.Delta_total_H(i) > 0) || (data.Delta_viable_H(i) > 0)) % HT has a negative effect due to increasing tumour volume
           regions(i) = "$\mathrm{RT}$"; 
        elseif (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) && ... % HT has a positive effect
                ((data.Delta_total_R(i) > 0) || (data.Delta_viable_R(i) > 0)) % RT has a negative effect 
           regions(i) = "$\mathrm{HT}$"; 
        elseif ((data.Delta_total_H(i) > 0) || (data.Delta_viable_H(i) > 0)) && ... % HT has a negative effect 
                ((data.Delta_total_R(i) > 0) || (data.Delta_viable_R(i) > 0)) % RT has a negative effect 
           regions(i) = "No treatment";
        elseif (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % RT+HT have a positive effects
            if (data.Delta_total_R(i) + data.Delta_viable_R(i) < data.Delta_total_H(i) + data.Delta_viable_H(i))
                regions(i) = "$\mathrm{RT} > \mathrm{HT}$";
            else 
                regions(i) = "$\mathrm{HT} > \mathrm{RT}$";
            end
        end 
      elseif (data.Delta_V_HR(i) < 0) &&  (data.Delta_V_H(i) > 0) % HT has a negative effect due to vascular growth but RT+HT reduces vascular volume
        if (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
           ((data.Delta_total_HR(i) > 0) || (data.Delta_viable_HR(i) > 0)) % RT+HT has a negative effect due to increasing tumour volume
           regions(i) = "$\mathrm{RT}$"; 
        elseif ((data.Delta_total_HR(i) > 0) || (data.Delta_viable_HR(i) > 0)) && ... % RT+HT has a negative effect due to increasing tumour volume
               ((data.Delta_total_R(i) > 0) || (data.Delta_viable_R(i) > 0)) % RT has a negative effect due to increasing tumour volume
           regions(i) = "No treatment"; 
        elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
                ((data.Delta_total_R(i) > 0) || (data.Delta_viable_R(i) > 0))% RT has a negative effect due to increasing tumour volume
           regions(i) = "$\mathrm{HT}+\mathrm{RT}$"; 
        elseif (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
                (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) % RT+HT has a positive effect
            if (data.Delta_total_R(i) + P < data.Delta_total_HR(i)) || (data.Delta_viable_R(i) + P < data.Delta_viable_HR(i)) % RT+HT is not significantly more effective than RT
                regions(i) = "$\mathrm{RT} > \mathrm{HT}+\mathrm{RT}$";  
            else % RT+HT is significantly more effective than RT     
                regions(i) = "$\mathrm{HT}+\mathrm{RT} > \mathrm{RT}$";
            end
        end 
    elseif   (data.Delta_V_HR(i) < 0) &&  (data.Delta_V_H(i) < 0) % HT and RT+HT reduce vascular volume
        if  (data.Delta_total_HR(i) + P < data.Delta_total_R(i)) && ...
            (data.Delta_viable_HR(i) + P < data.Delta_viable_R(i)) &&...
            (data.Delta_total_HR(i) + P < data.Delta_total_H(i)) && ...
            (data.Delta_viable_HR(i) + P < data.Delta_viable_H(i)) % RT+HT is significantly more effective than RT and HT
            if (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
               (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
               (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect
                if (data.Delta_total_R(i) + data.Delta_viable_R(i) < data.Delta_total_H(i) + data.Delta_viable_H(i))
                    regions(i) = "$\mathrm{HT}+\mathrm{RT} > \mathrm{RT} > \mathrm{HT}$";
                else 
                    regions(i) = "$\mathrm{HT}+\mathrm{RT} > \mathrm{HT} > \mathrm{RT}$";
                end  
            elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
                   (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) % RT has a positive effect (HT has a negative effect)
               regions(i) = "$\mathrm{HT}+\mathrm{RT} > \mathrm{RT}$";
            elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT has a positive effect
                   (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect (RT has a negative effect)
               regions(i) = "$\mathrm{HT}+\mathrm{RT} > \mathrm{HT}$";
            elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0)  % RT+HT has a positive effect (RT and HT have a negative effect)
               regions(i) = "$\mathrm{HT}+\mathrm{RT}$";
            else % RT+HT, RT and HT have a negative effect
                regions(i) = "No treatment";
            end
        elseif (data.Delta_total_HR(i) + P < data.Delta_total_R(i)) && ...
               (data.Delta_viable_HR(i) + P < data.Delta_viable_R(i)) && ...
               ((data.Delta_total_HR(i) + P > data.Delta_total_H(i)) || ...
               (data.Delta_viable_HR(i) + P > data.Delta_viable_H(i)) || ...
               (data.Delta_V_HR(i) > data.Delta_V_H(i))) % RT+HT is significantly more effective than RT, but not HT
            if (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
               (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
               (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect
                regions(i) = "$\mathrm{HT} > \mathrm{HT}+\mathrm{RT} > \mathrm{RT}$";
            elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
                    (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect (RT has a negative effect)
                regions(i) = "$\mathrm{HT} > \mathrm{HT}+\mathrm{RT}$";
            elseif (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect (RT and RT+HT have a negative effect)
                regions(i) = "$\mathrm{HT}$";
            else % RT+HT, RT and HT have a negative effect
                regions(i) = "No treatment";
            end 
        elseif (data.Delta_total_HR(i) + P < data.Delta_total_H(i)) && ...
               (data.Delta_viable_HR(i) + P < data.Delta_viable_H(i)) &&...
               (data.Delta_V_HR(i) < data.Delta_V_H(i)) && ...
               ((data.Delta_total_HR(i) + P > data.Delta_total_R(i)) || ...
               (data.Delta_viable_HR(i) + P > data.Delta_viable_R(i))) % RT+HT is significantly more effective than HT, but not RT
            if (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
               (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
               (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect
                regions(i) = "$\mathrm{RT} > \mathrm{HT}+\mathrm{RT} > \mathrm{HT}$";
            elseif (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ...  % RT+HT has a positive effect
                    (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) % RT has a positive effect (HT has a negative effect)
                regions(i) = "$\mathrm{RT} > \mathrm{HT}+\mathrm{RT}";
            elseif (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0)  % RT has a positive effect (HT and RT+HT have a negative effect)
                regions(i) = "$\mathrm{RT}$";
            else % RT+HT, RT and HT have a negative effect
                regions(i) = "No treatment";
            end 
        elseif ((data.Delta_total_HR(i) + P > data.Delta_total_H(i)) || ...
               (data.Delta_viable_HR(i) + P > data.Delta_viable_H(i)) || ...
               (data.Delta_V_HR(i) > data.Delta_V_H(i))) && ...
               ((data.Delta_total_HR(i) + P > data.Delta_total_R(i)) || ...
               (data.Delta_viable_HR(i) + P > data.Delta_viable_R(i))) % RT+HT is not significantly more effective than RT or HT
            if (data.Delta_total_HR(i) < 0) && (data.Delta_viable_HR(i) < 0) && ... % RT+HT has a positive effect
               (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
               (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect
                if (data.Delta_total_R(i) + data.Delta_viable_R(i) < data.Delta_total_H(i) + data.Delta_viable_H(i))
                    regions(i) = "$\mathrm{RT} > \mathrm{HT} > \mathrm{HT}+\mathrm{RT}$";
                else 
                    regions(i) = "$\mathrm{HT} > \mathrm{RT} > \mathrm{HT}+\mathrm{RT}$";
                end 
            elseif (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) && ... % RT has a positive effect
                   (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect (RT+HT has a negative effect)
                if (data.Delta_total_R(i) + data.Delta_viable_R(i) < data.Delta_total_H(i) + data.Delta_viable_H(i))
                    regions(i) = "$\mathrm{RT} > \mathrm{HT}$";
                else 
                    regions(i) = "$\mathrm{HT} > \mathrm{RT}$";
                end 
            elseif (data.Delta_total_R(i) < 0) && (data.Delta_viable_R(i) < 0) % RT has a positive effect (RT+HT and HT have a negative effect)
                regions(i) = "$\mathrm{RT}$";
            elseif (data.Delta_total_H(i) < 0) && (data.Delta_viable_H(i) < 0) % HT has a positive effect (RT+HT and RT have a negative effect)
                regions(i) = "$\mathrm{HT}$";
            else
                regions(i) = "No treatment";
            end
            
         end        
    end 
end

% Append 'regions' to 'data'
data.regions = regions;

%% Step Ib 

% Using 'regions', for each tumour, determine the best treatment of RT, HT 
% and RT+HT across all comparable schedules and extract the reductions in
% viable and total tumour volumes and the vascular volume for these
% optimal treatments

best_trt = strings(size(data,1),1);
    for i = 1:size(data,1)
        if (data.regions(i) == "$\mathrm{HT} > \mathrm{HT}+\mathrm{RT} > \mathrm{RT}$") || ...
           (data.regions(i) == "$\mathrm{HT} > \mathrm{HT}+\mathrm{RT}$") || ...
           (data.regions(i) == "$\mathrm{HT} > \mathrm{RT} > \mathrm{HT}+\mathrm{RT}$") || ...
           (data.regions(i) == "$\mathrm{HT}$") 
           
            best_trt(i) = "HT";
        elseif (data.regions(i) == "$\mathrm{HT}+\mathrm{RT} > \mathrm{HT} > \mathrm{RT}$") || ...
               (data.regions(i) == "$\mathrm{HT}+\mathrm{RT} > \mathrm{HT}$") || ...
               (data.regions(i) == "$\mathrm{HT}+\mathrm{RT} > \mathrm{RT} > \mathrm{HT}$")|| ...
               (data.regions(i) == "$\mathrm{HT}+\mathrm{RT} > \mathrm{RT}$")
           best_trt(i) = "$\mathrm{HT}+\mathrm{RT}$";
        elseif data.regions(i) == "No treatment"
           best_trt(i) = "No treatment";
        else
            best_trt(i) = "RT";
        end
    end
    
    % Append 'best_trt' to 'data'
    data.best_trt = best_trt;
    
    groupData= [];
    for i = 1:size(data,1)
        if best_trt(i) == "HT"
            groupData = vertcat(groupData,table2array(data(i,["FREQ","ID","q1","q3","R","beta",...
                                    "Delta_viable_H","Delta_total_H","Delta_V_H","regime","trt"])));
        elseif best_trt(i) == "RT"
            groupData = vertcat(groupData,table2array(data(i,["FREQ","ID","q1","q3","R","beta",...
                                    "Delta_viable_R","Delta_total_R","Delta_V_R","regime","trt"])));
        elseif best_trt(i) == "No treatment"
            groupData = vertcat(groupData,table2array(data(i,["FREQ","ID","q1","q3","R","beta",...
                                    "Delta_viable_R","Delta_total_R","Delta_V_R","regime","trt"])));
            groupData(end,7) = 0;
            groupData(end,8) = 0;
            groupData(end,9) = 0;
        else
            groupData = vertcat(groupData,table2array(data(i,["FREQ","ID","q1","q3","R","beta",...
                                    "Delta_viable_HR","Delta_total_HR","Delta_V_HR","regime","trt"])));
        end
        
    end 
    
   optimal_schedules =  array2table(groupData, 'VariableNames',{'FREQ','ID','q1','q3','R','beta',...
    'Delta_viable','Delta_total','Delta_V','regime','trt'});

   
   % Ensure all numeric variables are in the correct format for further 
   % analysis 
   optimal_schedules.FREQ = double(optimal_schedules.FREQ);
   optimal_schedules.ID = double(optimal_schedules.ID);
   optimal_schedules.q1 = double(optimal_schedules.q1);
   optimal_schedules.q3 = double(optimal_schedules.q3);
   optimal_schedules.beta = double(optimal_schedules.beta);
   optimal_schedules.R = double(optimal_schedules.R);
   optimal_schedules.Delta_viable = double(optimal_schedules.Delta_viable);
   optimal_schedules.Delta_total = double(optimal_schedules.Delta_total);
   optimal_schedules.Delta_V = double(optimal_schedules.Delta_V);

   %% Step 2 - Example for the NL cohort
  
   Regime = "NL";

   % Optimal schedules for the NL cohort only
   temp = optimal_schedules(optimal_schedules.regime == Regime,:);

   % Define beta_total = beta*N_wks 
   temp.beta_total = (ceil((floor(80./(temp.R*10))./temp.FREQ)).*temp.beta);

   % Filter for schedules that satisfy beta_total <= b_max := 0.08
   temp = temp(temp.beta_total <= 0.08,:);
  
   % Table of best schedules for each tumour in the cohort
   best_schedules = [];
   for i = 1:250
      
      % subset of the data for tumour i
      temp_i = temp(double(temp.ID) == i,:);
      % create a vector of Delta_viable + Delta_total for every schedule
      temp_i.Sum_Deltas = temp_i.Delta_total + temp_i.Delta_viable;
      % sort the data in ascending order of Delta_viable + Delta_total
      temp_i = sortrows(temp_i,"Sum_Deltas","ascend");
      
      % RT or HT is best
      if (temp_i(1,:).trt == "RT") || (temp_i(1,:).trt == "HT") 
           best_schedules = vertcat(best_schedules,temp_i(1,:));
      % RT+HT is ranked best, but we need to check that it is significantly 
      % better than the next best RT or HT schedule
      elseif temp_i(1,:).trt == "$\mathrm{HT}+\mathrm{RT}$"
          
           viable_best = temp_i(1,:).Delta_viable; 
           total_best = temp_i(1,:).Delta_total; 
           V_best = temp_i(1,:).Delta_V; 
           
           % list of HT schedules that are more effective than the best
           % RT+HT schedule according to the rules set out in the paper           
           ht_rt_best = temp_i((temp_i.trt == "HT" |  temp_i.trt == "RT") & ...
                              (temp_i.Delta_total - total_best < 10 | ...
                              temp_i.Delta_viable - viable_best < 10),:);
          % If there is a more effective RT or HT treatment schedule, then 
          % it is best. Otherwise, RT+HT remains best.    
          if isempty(ht_rt_best)==0       
              ht_rt_best = sortrows(ht_rt_best,"Sum_Deltas","ascend");
              best_schedules = vertcat(best_schedules,ht_rt_best(1,:));          
          else 
              best_schedules = vertcat(best_schedules,temp_i(1,:));
          end 
          
      end
      
  end    
