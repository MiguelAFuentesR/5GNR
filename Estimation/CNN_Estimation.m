function [Est] = CNN_Estimation(Parameters,estimacionRNA)

%% ----------------- Estimacion de Canal CNN -----------------------
nnInput = cat(4,real(Parameters.interpChannelGrid),imag(Parameters.interpChannelGrid));
size(nnInput);
% Use the neural network to estimate the channel
time_prediction = tic;
Parameters.CNN_estChannelGrid = predict(estimacionRNA,nnInput);
Parameters.t_estimation = toc(time_prediction);
% Convert results to complex
Parameters.CNN_estChannelGrid = complex(Parameters.CNN_estChannelGrid(:,:,:,1),Parameters.CNN_estChannelGrid(:,:,:,2));
Parameters.CNN_Mape = mape(double(Parameters.CNN_estChannelGrid(:)), Parameters.Perfect_estChannelGrid(:));
Parameters.CNN_MSE = [Parameters.CNN_MSE immse(Parameters.Perfect_estChannelGrid(:,:,:), double(Parameters.CNN_estChannelGrid(:,:,:)))];

[CNN_pdschRx,CNN_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.CNN_estChannelGrid);
[Parameters.CNN_pdschEq,CNN_csi] = nrEqualizeMMSE(CNN_pdschRx,CNN_pdschHes,Parameters.noiseEst);

[CNN_bits_received,CNN_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.CNN_pdschEq,Parameters.noiseEst);
Parameters.CNN_rxbits = [Parameters.CNN_rxbits;CNN_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end