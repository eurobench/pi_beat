function pf=fillgaps(p)


%FILLGAPS fill gaps by spline interpolation
%   $Revision: 1.0 $  $Date: 2021/01/21


for i=1:size(p,3)
    pf(:,:,i)=fillgapsOne(p(:,:,i));
end

function pf=fillgapsOne(p)

r=size(p,1);
pnanindex=any(isnan(p),2);
if any(pnanindex) 
    x=find(~pnanindex);
    pf=interp1(x,p(x,:),[1:r]','spline');
else
        pf=p;
end
