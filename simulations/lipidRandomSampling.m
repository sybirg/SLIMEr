%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% abundance = lipidRandomSampling(model,data,Nsim)
%
% Benjam�n J. S�nchez. Last update: 2018-03-31
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function abundance = lipidRandomSampling(model,data,Nsim)

%Simulate a flux distribution with the corresponding model:
[sol,model] = simulateGrowth(model,data.fluxData);
posX          = strcmp(model.rxnNames,'growth');
muS           = sol.x(posX);

%Get a number of simulations from random sampling:
model_r = ravenCobraWrapper(model);
disp('Initializing random sampling...')
samples = randomSampling(model_r,Nsim);

%Find matching positions for each species and compute predicted abundance:
abundance = zeros(length(data.metNames),Nsim);
isSLIME   = contains(model.rxnNames,'SLIME rxn');
for j = 1:length(data.metNames)
    pos = matchToModel(model,data.metNames{j});
    if sum(pos) > 0
        %Get MW for each met:
        MWs = getMWfromFormula(model.metFormulas(pos));     %g/mmol
        
        %Get fluxes in which each met gets consumed for the SLIME rxn:
        isSub   = model.S(pos,:) < 0;
        fluxPos = isSub.*isSLIME';
        fluxes  = fluxPos*samples;
        
        %Compute abundance predicted by model:
        abundance(j,:) = sum(fluxes.*MWs,1)/muS*1000;	%mg/gDW
    end
end

%Compute error:


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%