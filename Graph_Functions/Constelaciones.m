function [] = Constelaciones(Parameters)
drawnow

subplot(4,2,1)
plot(Parameters.Perfect_pdschEq,'.')
hold on
title("Constelacion Est Perfecta")
plot(Parameters.refSymbols,'+')
grid on
xlabel('In-Phase')
ylabel('Quadrature')
drawnow;
hold off
%///////////////////////////////////////////
subplot(4,2,2)
plot(Parameters.Lineal_pdschEq,'.')
hold on
plot(Parameters.refSymbols,'+')
title("Constelacion Est Lineal")
grid on
xlabel('In-Phase')
ylabel('Quadrature')
drawnow;
hold off
%///////////////////////////////////////////
subplot(4,2,3)
plot(Parameters.CNN_pdschEq,'.')
hold on
plot(Parameters.refSymbols,'+')
title("Constelacion Est CNN")
grid on
xlabel('In-Phase')
ylabel('Quadrature')
drawnow;
hold off


%///////////////////////////////////////////
subplot(4,2,4)
plot(Parameters.Practical_pdschEq_sin,'.')
hold on
plot(Parameters.refSymbols,'+')
title("Constelacion Est CNN sin comp")
grid on
xlabel('In-Phase')
ylabel('Quadrature')
drawnow;
hold off

%///////////////////////////////////////////
subplot(4,2,5)
plot(Parameters.Practical_pdschEq,'.')
hold on
plot(Parameters.refSymbols,'+')
title("Constelacion Est Practica")
grid on
xlabel('In-Phase')
ylabel('Quadrature')
drawnow;
hold off


%///////////////////////////////////////////
% subplot(4,2,6)
% plot(Parameters.CNN_2_pdschEq,'.')
% hold on
% plot(Parameters.refSymbols,'+')
% title("Constelacion CNN 2")
% grid on
% xlabel('In-Phase')
% ylabel('Quadrature')
% drawnow;
% hold off

% %///////////////////////////////////////////
% subplot(4,2,7)
% plot(Parameters.Autoencoder_pdschEq,'.')
% hold on
% plot(Parameters.refSymbols,'+')
% title("Constelacion Autoencoder")
% grid on
% xlabel('In-Phase')
% ylabel('Quadrature')
% drawnow;
% hold off
% 
% %///////////////////////////////////////////
% subplot(4,2,8)
% plot(Parameters.Denoising_pdschEq,'.')
% hold on
% plot(Parameters.refSymbols,'+')
% title("Constelacion Denoising")
% grid on
% xlabel('In-Phase')
% ylabel('Quadrature')
% drawnow;
% hold off

end