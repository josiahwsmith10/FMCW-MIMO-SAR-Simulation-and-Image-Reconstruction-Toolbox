function obj = mult2mono_app(obj,app)
% Y-dimension only multistatic-to-monostatic approximation
if numel(app.sar.sarSize) == 3
    k = reshape(obj.k_vec,1,1,[]);
elseif numel(app.sar.sarSize) == 4
    k = reshape(obj.k_vec,1,1,1,[]);
end

obj.sarData = reshape(obj.sarData,[],size(obj.sarData,3),size(obj.sarData,4),size(obj.sarData,5));

obj.sarData = obj.sarData .* exp(-1j*k .* app.ant.vx.dxy(:,2).^2 / (4*app.ZReferencemEditField.Value));

obj.sarData = reshape(obj.sarData,[],size(obj.sarData,3),size(obj.sarData,4));

end