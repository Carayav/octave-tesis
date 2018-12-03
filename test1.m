close all

start_path= "/home/cl/Documents/2018-02/Tesis/octave";
chemin1= '2018_05_16_LARIB014_by_DONATIEN_RADIUS_LEFT/11_14_32';
indice= 1;unite=0;porte=1;


[SIG2,fe,f0,data,temps, RSS, RSB] = ouverture_aza_v5(start_path,chemin1,indice,unite,porte);%

% fe samplig freq en MHz
ts = 1/fe; %% sampling time in micro second
p = 0.8; %% mm betwenn sensores



Nt = size(SIG2,1); %%% number of time points
NR = size(SIG2, 2); %%% number of receivers



s = squeeze(SIG2(:,:,1,1,1)); %%%% one signal in time s(t)



t =[0:Nt-1]*ts;
x = [0:NR-1]*p;


Nf = 2048;

f = [0:Nf-1]*fe/Nf;

%S = fft(s,Nf);



%figure;
%subplot(2,1,1)
%plot(t,s,'o.-')

%subplot(2,1,2)
%plot(f,abs(S),'.-')

sig = squeeze(SIG2(:,:,1,1,1));

figure;
for nr=1:NR
  plot(t,nr+s(:,nr)/10, 'k')
  hold on
  title(nr)
  %%pause(0.3)
end
axis([0 50 -1 25])
figure:imagesc(t,x,sig) %% espacio n sensores tiempo 1024
figure:imagesc(t,x,sig.');colorbar %% espacio tiempo transpose
xlabel('t (µs)')
ylabel('x (mm)')

figure;
for nr = 1:NR
  S(:,nr) = fft(s(:,nr),Nf);
  plot(f, nr+abs(S(:,nr))/200,'k')
  hold on
##  pause(0.1)
endfor
axis([0 2 0 25])
figure:imagesc(abs(S))

figure:imagesc(f,x,abs(S).')


##Nf = 2048;
##f = [0:Nf-1]*fe/Nf;
##S = fft(s(:,1),Nf);
##
##
##Nf1 = Nt;
##f1 = [0:Nf1-1]*fe/Nf1;
##S1 = fft(s(:,1),Nf1);
##
##figure;plot(f,abs(S),'sb-')
##hold on;plot(f1,abs(S1),'or-')

%%nf podemos eligir y cambiar 


