function [Est] = Autoencoder_Estimation(Parameters,estimacionRNA)

%% ----------------- Estimacion de Canal Autoencoder -----------------------
nnInput = cat(4,real(Parameters.interpChannelGrid),imag(Parameters.interpChannelGrid));
size(nnInput);
% Use the neural network to estimate the channel
time_prediction = tic;
Parameters.Autoencoder_estChannelGrid = predict(estimacionRNA,nnInput);
Parameters.t_estimation = toc(time_prediction);
% Convert results to complex
Parameters.Autoencoder_estChannelGrid = complex(Parameters.Autoencoder_estChannelGrid(:,:,:,1),Parameters.Autoencoder_estChannelGrid(:,:,:,2));
Parameters.Autoencoder_Mape = mape(double(Parameters.Autoencoder_estChannelGrid(:)), Parameters.Perfect_estChannelGrid(:));
Parameters.Autoencoder_MSE = [Parameters.Autoencoder_MSE immse(Parameters.Perfect_estChannelGrid(:,:,:), double(Parameters.Autoencoder_estChannelGrid(:,:,:)))];

[Autoencoder_pdschRx,Autoencoder_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.Autoencoder_estChannelGrid);
[Parameters.Autoencoder_pdschEq,Autoencoder_csi] = nrEqualizeMMSE(Autoencoder_pdschRx,Autoencoder_pdschHes,Parameters.noiseEst);

[Autoencoder_bits_received,Autoencoder_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Autoencoder_pdschEq,Parameters.noiseEst);
Parameters.Autoencoder_rxbits = [Parameters.Autoencoder_rxbits;Autoencoder_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end