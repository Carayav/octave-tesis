close all
start_path= "/home/cl/Documents/2018-02/tesis/octave";
chemin1= '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice= 1;unite=0;porte=1;
cd(start_path)


[SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte);
##########################################################################################
## SIG2 = Matriz de tamaño Nt x n_receptor x n_emisores x índice x dirección
## fe = freq ech (20 MHz para AZA)
## f0 = frecuencia central
## data = estructura de los parámetros generales de las adquisiciones.
## temps = vector de tiempo asociado con señales adquiridas
## Relación señal RSS a saturación (2048) nb_receptor x nb_emission x índice x dirección
## Relación señal / ruido SNR (2048) número_receptor x número_misión x índice x dirección
##############################################################################################
printf("SIG2 = Matriz de tamaño Nt x nb_receptor x nb_emission x índice x dirección\n")
size(SIG2)
size(temps)

NR = size(SIG2, 2);           ## NR: Numero de receptores
NE = size(SIG2, 3);           ## NE: Numero de Emisores
Nt = size(SIG2,1);            ## Nt: Numero de puntos de tiempo
Nf = 2048;                    ## Nf: Numero de frecuencias
NK = 256;                     ## Nk: Numero de K
ts = 1/fe;                    ## ts: Tiempo de Sampĺing en  [µs]
t =[0:Nt-1]*ts;               ##  t: Arreglo de tiempos     [µs]
p = 0.8;                      ##  p: Espacio entre sensores [mm]
x = [0:NR-1]*p;               ##  x: Arreglo de posiciones  [mm]
s = squeeze(SIG2(:,:,:,1,1)); ##  s: Señal s en tiempo s(t)

load REF2D_exvivo_Mathilde_Radius_01mm


## s → S 
S = ifft(s,Nf);
U = zeros(Nf,NK,NE);

Nf = length(f);
for nf=1:Nf
  [u, s, v] = svd(squeeze(S(nf,:,:)), NE);
  U(nf,:,:) = fft(u,NK);  
end
suma = 1/NR*sum( abs( U(1:Nf,:,:)).^2 ,3 );

### Problema Inverso
[Imrefs] = valores_ref();

valor = zeros(20,30);
for npd = 1:20
  for ned = 1:30
    valor(npd,ned) = sum(sum(Imrefs(:,:,npd,ned).*suma, 1))/length(f);
  end
end

figure;


subplot(1,2,1)
[m a ] = max(max(valor));
[m b ] = max(max(valor'))
contour(etest(1:30),portest(1:20),valor,[m-0.04:0.01:m-0.01]);colorbar
hold on,plot(etest(a),portest(b),'xr','markersize',10)
title(sprintf('Hola'))

subplot(1,2,2)
imagesc(f,k,suma')
axis('xy')
colorbar

printf( pwd)
cd(start_path)
printf(ls)

