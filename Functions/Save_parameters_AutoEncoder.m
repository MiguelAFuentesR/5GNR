function [Parameters] = Save_parameters_AutoEncoder(Parameters)
%Exportar los datos mas relevantes de la simulacion

%Almacenar objetos importantes de configuracion 
Parameters = Variable_Generation(Parameters,'Time_Grid_','',true); % Crea variable Time_Grid_CNN 
Parameters = Variable_Generation(Parameters,'','_rxbits',true); % Crea variable CNN_rxbits

Parameters.estimacionRNA_1 = [];
Parameters.estimacionRNA_2 = [];
Parameters.estimacionRNA_Autoencoder = [];
Parameters.estimacionRNA_Denoising =[];
Parameters.trData  = [];
Parameters.Image = [];


if Parameters.Save_Variables 
    save ('Outputs/AutoEncoder/Autoencoder_'+string(Parameters.AutoEncoder_Model)+'_'+Parameters.Channel+'_Vel_'+string(Parameters.User_Velocity),'Parameters');
end

end