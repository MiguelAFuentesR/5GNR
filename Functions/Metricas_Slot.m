function [Est] = Metricas_Slot(Parameters)

release(Parameters.evm);
Parameters.Lineal_EVM_Slot = Parameters.evm(Parameters.Lineal_pdschEq);
Parameters.Lineal_EVM = [Parameters.Lineal_EVM, Parameters.Lineal_EVM_Slot];
Parameters.LinealEVM = mean(Parameters.Lineal_EVM);
Parameters.LinealMSE = mean(Parameters.Lineal_MSE);
Parameters.Lineal_Time =[Parameters.Lineal_Time Parameters.tEnd_Lineal];
Parameters.Time_Grid_Lineal = [Parameters.Time_Grid_Lineal Parameters.interpChannelGrid];



release(Parameters.evm);
Parameters.Perfect_EVM_Slot = Parameters.evm(Parameters.Perfect_pdschEq);
Parameters.PerfectEVM =mean(Parameters.Perfect_EVM);
Parameters.Perfect_EVM = [Parameters.Perfect_EVM, Parameters.Perfect_EVM_Slot];
Parameters.Perfect_Time =[Parameters.Perfect_Time Parameters.tEnd_Perfect];
Parameters.Time_Grid_Perfect = [Parameters.Time_Grid_Perfect Parameters.Perfect_estChannelGrid];



if Parameters.CNNEstimation
    release(Parameters.evm);
    Parameters.CNN_EVM_Slot = Parameters.evm(Parameters.CNN_pdschEq);
    Parameters.CNN_EVM = [Parameters.CNN_EVM, Parameters.CNN_EVM_Slot ];
    Parameters.CNNEVM = mean(Parameters.CNN_EVM);
    Parameters.CNNMSE = mean(Parameters.CNN_MSE);
    Parameters.CNN_Time =[Parameters.CNN_Time Parameters.tEnd_CNN];
    Parameters.Time_Grid_CNN = [Parameters.Time_Grid_CNN Parameters.CNN_estChannelGrid];
end

if Parameters.CNNEstimation_2
    release(Parameters.evm);
    Parameters.CNN_2_EVM_Slot = Parameters.evm(Parameters.CNN_2_pdschEq);
    Parameters.CNN_2_EVM = [Parameters.CNN_2_EVM, Parameters.CNN_2_EVM_Slot ];
    Parameters.CNN_2EVM = mean(Parameters.CNN_2_EVM);
    Parameters.CNN_2MSE = mean(Parameters.CNN_2_MSE);
    Parameters.CNN_2_Time =[Parameters.CNN_2_Time Parameters.tEnd_CNN_2];
    Parameters.Time_Grid_CNN_2 = [Parameters.Time_Grid_CNN_2 Parameters.CNN_2_estChannelGrid];
end

if Parameters.Autoencoder_Estimation
    release(Parameters.evm);
    Parameters.Autoencoder_EVM_Slot = Parameters.evm(Parameters.Autoencoder_pdschEq);
    Parameters.Autoencoder_EVM = [Parameters.Autoencoder_EVM, Parameters.Autoencoder_EVM_Slot ];
    Parameters.AutoencoderEVM = mean(Parameters.Autoencoder_EVM);
    Parameters.AutoencoderMSE = mean(Parameters.Autoencoder_MSE);
    Parameters.Autoencoder_Time =[Parameters.Autoencoder_Time Parameters.tEnd_Autoencoder];
    Parameters.Time_Grid_Autoencoder = [Parameters.Time_Grid_Autoencoder Parameters.Autoencoder_estChannelGrid];
end

if Parameters.Denoising_Estimation
    release(Parameters.evm);
    Parameters.Denoising_EVM_Slot = Parameters.evm(Parameters.Denoising_pdschEq);
    Parameters.Denoising_EVM = [Parameters.Denoising_EVM, Parameters.Denoising_EVM_Slot ];
    Parameters.DenoisingEVM = mean(Parameters.Denoising_EVM);
    Parameters.DenoisingMSE = mean(Parameters.Denoising_MSE);
    Parameters.Denoising_Time =[Parameters.Denoising_Time Parameters.tEnd_Denoising];
    Parameters.Time_Grid_Denoising = [Parameters.Time_Grid_Denoising Parameters.Denoising_estChannelGrid];
end

if Parameters.Denoising_Estimation_resta
    release(Parameters.evm);
    Parameters.Denoising_2_EVM_Slot = Parameters.evm(Parameters.Denoising_2_pdschEq);
    Parameters.Denoising_2_EVM = [Parameters.Denoising_2_EVM, Parameters.Denoising_2_EVM_Slot ];
    Parameters.Denoising_2EVM = mean(Parameters.Denoising_2_EVM);
    Parameters.Denoising_2MSE = mean(Parameters.Denoising_2_MSE);
    Parameters.Denoising_2_Time =[Parameters.Denoising_2_Time Parameters.tEnd_Denoising_2];
    Parameters.Time_Grid_Denoising_2 = [Parameters.Time_Grid_Denoising_2 Parameters.Denoising_2_estChannelGrid];
end

if Parameters.EstimacionPractica
    release(Parameters.evm);
    Parameters.Practical_EVM_Slot = Parameters.evm(Parameters.Practical_pdschEq);
    Parameters.Practical_EVM = [Parameters.Practical_EVM, Parameters.Practical_EVM_Slot];
    Parameters.PracticalEVM = mean(Parameters.Practical_EVM);
    Parameters.PracticalMSE = mean(Parameters.Practical_MSE);
    Parameters.Practical_Time =[Parameters.Practical_Time Parameters.tEnd_Practical];
    Parameters.Time_Grid_Practical = [Parameters.Time_Grid_Practical Parameters.Practical_estChannelGrid];
    
end


Est = Parameters;
end