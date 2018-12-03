close all
start_path = "/home/cl/Documents/2018-02/tesis/octave";
data_path1 = '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice = 0;  ## Valor 0 entrega todas las mediciones
unite  = 0;
porte  = 1;
cd(start_path)
list_dir = ls('-d */');

##Load data ref.
load REF2D_exvivo_Mathilde_Radius_01mm

### Valores de referencia
[Imrefs] = valores_ref();

for i = 1:size(list_dir, 1)
  list_dir(i,:)
  cd(strtrim(list_dir(i,:)))
  list_sub_dir = ls('-d */')
  cd(start_path)
  figure;
  for j = 1:size(list_sub_dir, 1)
    list_sub_dir(j,:);
    data_path = strcat(list_dir(i,:), list_sub_dir(j,:))    
    [SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,data_path,indice,unite,porte);
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
    ## s → S 
    ## Time-Fourier
    S = ifft(s,Nf);
    U = zeros(Nf,NK,NE);
    Nf = length(f);
    ## SVD
    for nf=1:Nf
      [u, s, v] = svd(squeeze(S(nf,:,:)), NE);
      U(nf,:,:) = fft(u,NK);  
    end
    suma = 1/NR*sum( abs( U(1:Nf,:,:)).^2 ,3 );
    
    ## Problema Inverso
    valor = zeros(20,30);
    for npd = 1:20
      for ned = 1:30
        valor(npd,ned) = sum(sum(Imrefs(:,:,npd,ned).*suma, 1))/length(f);
      end
    end    
    subplot(size(list_sub_dir, 1),2,2*j-1)
    
    [m a ] = max(max(valor));
    [m b ] = max(max(valor'))
    contour(etest(1:30),portest(1:20),valor,[m-0.04:0.01:m-0.01]);colorbar
    hold on,plot(etest(a),portest(b),'xr','markersize',10)
    title(data_path, 'interpreter', 'none')

    subplot(size(list_sub_dir, 1),2,2*j)
    imagesc(f,k,suma')
    axis('xy')
    colorbar   
  endfor
  cd(start_path)
endfor



