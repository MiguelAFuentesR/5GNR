function [Parameters] = Save_parameters(Parameters)
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

Parameters.Denoising_2_estChannelGrid = [];
Parameters.Denoising_estChannelGrid = [];
Parameters.Practical_estChannelGrid = [];
Parameters.Autoencoder_estChannelGrid = [];
Parameters.CNN_2_estChannelGrid = [];
Parameters.CNN_estChannelGrid = [];
Parameters.Perfect_estChannelGrid = [];
Parameters.Lineal_estChannelGrid = [];
Parameters.Practical_estChannelGrid = [];

if Parameters.Save_Variables 
    save ('Outputs/5GNR_'+Parameters.Channel+'_Mod_'+Parameters.Modulation+'_Vel_'+string(Parameters.User_Velocity),'Parameters');
end

end