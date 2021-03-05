function obj = mult2mono(obj)
% Computes the Y-dimension multistatic-to-monostatic approxmiation. Only
% works for MIMO arrays whose elements are colinear 

% Y-dimension only multistatic-to-monostatic approximation
if numel(obj.sar.sarSize) == 3
    k = reshape(obj.k_vec,1,1,[]);
elseif numel(obj.sar.sarSize) == 4
    k = reshape(obj.k_vec,1,1,1,[]);
else
    warning("Could not perform multistatic-to-monostatic approximation!!")
    obj.sarData = single(zeros(size(reshape(obj.sarData,[],size(obj.sarData,3),size(obj.sarData,4)))));
    return;
end

obj.sarData = reshape(obj.sarData,[],size(obj.sarData,3),size(obj.sarData,4),size(obj.sarData,5));

obj.sarData = obj.sarData .* exp(-1j*k .* obj.ant.vx.dxy(:,2).^2 / (4*obj.zRef_m));

obj.sarData = reshape(obj.sarData,[],size(obj.sarData,3),size(obj.sarData,4));

end