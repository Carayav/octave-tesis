


function [Imrefs] = valores_ref()
load REF2D_exvivo_Mathilde_Radius_01mm


Nf = length(f)
Nk = length(k)

Imrefs = zeros(Nf,Nk,20,30);
for npd = 1:20
  for ned = 1:30    
    for nf = 1:Nf
      kth = k_ref2D_coupe_v2(npd).k_ref(nf,:,ned);  
      ind_modes = find(isnan(kth)== 0);
      Nm = length(ind_modes);
      for nk = ind_modes
        indk = max(find (k<kth(nk) ) );          
        if isempty(Nm) == 0
          Imrefs(nf,indk,npd,ned) = 1/Nm;
        end     
      end
    end     
  end
  npd
end



end
