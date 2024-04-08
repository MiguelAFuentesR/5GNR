function [Parameters] = Save_parameters_CNN_vel(Parameters)
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
    save ('Outputs/CNN/Vel/CNN_'+string(Parameters.CNNmodel_1)+'_'+Parameters.Channel+'_SNR_'+string(Parameters.SNR_lin),'Parameters');
end

end