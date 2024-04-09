function [Est] = Denoising_Estimation_2(Parameters,estimacionRNA)

%% ----------------- Estimacion de Canal Denoising_2 -----------------------
nnInput = cat(4,real(Parameters.interpChannelGrid),imag(Parameters.interpChannelGrid));
size(nnInput);
% Use the neural network to estimate the channel
time_prediction = tic;
Parameters.Denoising_2_estChannelGrid = predict(estimacionRNA,nnInput);
Parameters.t_estimation_Denoising_2 = toc(time_prediction);

% Convert results to complex
Parameters.Denoising_2_estChannelGrid = complex(Parameters.Denoising_2_estChannelGrid(:,:,:,1),Parameters.Denoising_2_estChannelGrid(:,:,:,2));

Parameters.Denoising_2_estChannelGrid = Parameters.interpChannelGrid-Parameters.Denoising_2_estChannelGrid;


Parameters.Denoising_2_Mape = mape(double(Parameters.Denoising_2_estChannelGrid(:)), Parameters.Perfect_estChannelGrid(:));
Parameters.Denoising_2_MSE = [Parameters.Denoising_2_MSE immse(Parameters.Perfect_estChannelGrid(:,:,:), double(Parameters.Denoising_2_estChannelGrid(:,:,:)))];

[Denoising_2_pdschRx,Denoising_2_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.Denoising_2_estChannelGrid);
[Parameters.Denoising_2_pdschEq,Denoising_2_csi] = nrEqualizeMMSE(Denoising_2_pdschRx,Denoising_2_pdschHes,Parameters.noiseEst);

[Denoising_2_bits_received,Denoising_2_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Denoising_2_pdschEq,Parameters.noiseEst);
Parameters.Denoising_2_rxbits = [Parameters.Denoising_2_rxbits;Denoising_2_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end