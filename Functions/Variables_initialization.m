function [Est] = Variables_initialization(Parameters,snr)

%Declaracion de Variables en cada Transmision a un valor especifico de SNR

Parameters.txbits=[];


Parameters = Variable_Generation(Parameters,'','_rxbits',true); % Crea variable CNN_rxbits

Parameters.SNR_Lineal = 10^(snr/10);
Parameters.block_posicion = 0;
Parameters.step = Parameters.Informacion_Indices_PDSCH.G;
Parameters.End_pos = Parameters.Informacion_Indices_PDSCH.G;
%disp(['SNR de ',num2str(snr),' dB'])



Parameters = Variable_Generation(Parameters,'','EVM',false); % Crea variable PerfectEVM 
Parameters = Variable_Generation(Parameters,'','MSE',false); % Crea variable PerfectMSE 
Parameters = Variable_Generation(Parameters,'','_EVM',true); % Crea variable Perfect_EVM 
Parameters = Variable_Generation(Parameters,'','_MSE',true); % Crea variable Perfect_EVM 
Parameters = Variable_Generation(Parameters,'','_Time',true); % Crea variable Perfect_Time
Parameters = Variable_Generation(Parameters,'','_Mape_mat',true); % Crea variable _Mape_mat

Parameters.CNN_pdschEq_sin = [];




Est = Parameters;
end