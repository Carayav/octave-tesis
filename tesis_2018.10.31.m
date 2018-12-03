close all

start_path= "/home/cl/Documents/2018-02/Tesis/octave";
chemin1= '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice= 1;unite=0;porte=1;
cd(start_path)


[SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte);%  

##########################################################################################
## SIG2 = Matriz de tamaño Nt x nb_receptor x nb_emission x índice x dirección
## fe = freq ech (20 MHz para AZA)
## f0 = frecuencia central
## data = estructura de los parámetros generales de las adquisiciones.
## temps = vector de tiempo asociado con señales adquiridas
## Relación señal RSS a saturación (2048) nb_receptor x nb_emission x índice x dirección
## Relación señal / ruido SNR (2048) número_receptor x número_misión x índice x dirección
##############################################################################################


## ts: Tiempo de Sampĺing en [µs]
ts = 1/fe; 

## p: Espacio entre sensores [mm]
p = 0.8; 

## Nt: Numero de puntos de tiempo
Nt = size(SIG2,1); 

## NR: Numero de receptores
NR = size(SIG2, 2); 

## NE: Numero de Emisores
NE = size(SIG2, 3); 

## s: Señal s en tiempo s(t)
s = squeeze(SIG2(:,:,:,1,1));

## t: arreglo de tiempos [µs]
t =[0:Nt-1]*ts;

## x: arreglo de posiciones [mm]
x = [0:NR-1]*p;

## Nf: Numero de frecuencias
Nf = 2048;

## Nk: Numero de ¿K?

NK = 256;

## f: Arreglo de frecuencias 
f = [0:Nf-1]*fe/Nf;

## f: Arreglo de k
#k = [0:Nk-1];


## s → S 
S = fft(s,Nf);
U = zeros(Nf,NK,NE);

for nf=1:Nf
  [u, s, v] = svd(squeeze(S(nf,:,:)), NE);
  U(nf,:,:) = fft(u,NK);
  
endfor

printf("\nNf: %d Nr: %d Ne: %d\n", Nf, NR, NE);


sizeS = size(S);
g=sprintf('%d ', sizeS);
fprintf('Size S: %s\n', g)

sizeU = size(U);
g=sprintf('%d ', sizeU);
fprintf('Size U: %s\n', g)


##figure;
##imagesc(abs( U(1:200,:,2) ).'.^2 )




figure;

for ne=1:NE
subplot(2,3,ne)

imagesc(abs( U(1:200,:,ne) ).'.^2 )
title(ne)
pause(0.5)
end
subplot(2,3,6)
suma = sum( abs( U(1:200,:,:) ).^2 ,3 );
imagesc(suma.')


figure;

for ne=1:NE
subplot(2,3,ne)

imagesc(sum(abs( U(1:200,:,1:ne) ).^2,3).' )
colormap(jet)
title(ne)
pause(0.5)
end
subplot(2,3,6)
suma = sum( abs( U(1:200,:,:) ).^2 ,3 );
imagesc(suma.')








#imagesc(f,)




##figure;
##for nr=1:NR
##  plot(t,nr+s(:,nr)/10, 'k')
##  hold on
##  title(nr)
##  %%pause(0.3)
##end

