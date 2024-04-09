function [Parameters] = Variable_Generation(Parameters,Complement1,Complement2,arreglo) 
%Generate variable kind of  Complement1_NomModel_Complement2
for i = 1 : length(Parameters.models)
    if arreglo 
        Parameters.( genvarname([Complement1,Parameters.models{1,i},Complement2])) = [];
    else 
        Parameters.( genvarname([Complement1,Parameters.models{1,i},Complement2])) = 0;
    end
end

end