%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data = getLipidDistribution(model,lipidNames,chains)
%
% Benjam�n J. S�nchez. Last update: 2017-12-13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = getLipidDistribution(model,lipidNames,chains)

%Simulate model:
sol = simulateGrowth(model);

%Find growth:
posG = strcmp(model.rxnNames,'D-glucose exchange');
posX = strcmp(model.rxnNames,'growth');
mu   = sol.x(posX);

for i = 1:length(chains)
    chains{i} = ['C' chains{i} ' chain [cytoplasm]'];
end

composition = zeros(length(lipidNames),length(chains));

%Go through all SLIME rxns to find abundances:
SLIMEpos = find(~cellfun(@isempty,strfind(model.rxnNames,'SLIME rxn')));
for i = 1:length(SLIMEpos)
    %Find flux and all metabolites produced in each SLIME rxn:
    flux      = sol.x(SLIMEpos(i));
    metPos    = model.S(:,SLIMEpos(i)) > 0;
    metNames  = model.metNames(metPos);
    metStoich = model.S(metPos,SLIMEpos(i));
    
    %Find lipid species:
    pos_i = [];
    for j = 1:length(lipidNames)
        lipidPos = ~cellfun(@isempty,strfind(model.metNames(metPos),lipidNames{j}));
        if sum(lipidPos) > 0
            pos_i = j;
        end
    end
    
    %Find chains produced:
    for j = 1:length(chains)
        chainPos = strcmp(metNames,chains{j});
        if sum(chainPos) > 0
            composition(pos_i,j) = composition(pos_i,j) + flux*metStoich(chainPos)/mu;
        end
    end
end

%Fix glucose and biomass:
model = changeRxnBounds(model,model.rxns(posG),-1.001,'l');
model = changeRxnBounds(model,model.rxns(posX),mu,'l');

%Find variability:
variability = cell(size(composition));
for i = 1:length(lipidNames)
    for j = 1:length(chains)
        [minVal,maxVal] = lipidFVA(model,lipidNames{i},chains{j});
        variability{i,j} = [minVal,maxVal]/mu;
        disp(['Computing composition and variability: ' lipidNames{i} ' - ' chains{j}])
    end
end

data.composition = composition;
data.variability = variability;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%