function [Est] = CNN_2_Estimation(Parameters,estimacionRNA)

%% ----------------- Estimacion de Canal CNN_2 -----------------------
nnInput = cat(4,real(Parameters.interpChannelGrid),imag(Parameters.interpChannelGrid));
size(nnInput);
% Use the neural network to estimate the channel
time_prediction = tic;
Parameters.CNN_2_estChannelGrid = predict(estimacionRNA,nnInput);
Parameters.t_estimation = toc(time_prediction);
% Convert results to complex
Parameters.CNN_2_estChannelGrid = complex(Parameters.CNN_2_estChannelGrid(:,:,:,1),Parameters.CNN_2_estChannelGrid(:,:,:,2));
Parameters.CNN_2_Mape = mape(double(Parameters.CNN_2_estChannelGrid(:)), Parameters.Perfect_estChannelGrid(:));
Parameters.CNN_2_MSE = [Parameters.CNN_2_MSE immse(Parameters.Perfect_estChannelGrid(:,:,:), double(Parameters.CNN_2_estChannelGrid(:,:,:)))];

[CNN_2_pdschRx,CNN_2_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.CNN_2_estChannelGrid);
[Parameters.CNN_2_pdschEq,CNN_2_csi] = nrEqualizeMMSE(CNN_2_pdschRx,CNN_2_pdschHes,Parameters.noiseEst);

[CNN_2_bits_received,CNN_2_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.CNN_2_pdschEq,Parameters.noiseEst);
Parameters.CNN_2_rxbits = [Parameters.CNN_2_rxbits;CNN_2_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end