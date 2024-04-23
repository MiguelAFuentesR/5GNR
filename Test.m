% 1. Define tu vector de datos
datos = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; % Ejemplo de datos

% 2. Obtén los últimos 10 elementos del vector
ultimos_10_datos = datos(end-9:end);

% 3. Grafica los últimos 10 datos
plot(ultimos_10_datos);

% 4. Añade etiquetas y título si es necesario
xlabel('Índice');
ylabel('Valor');
title('Últimos 10 datos del vector');

% 5. Muestra la rejilla si es necesario
grid on;
