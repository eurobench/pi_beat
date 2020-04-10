function Ynorm=eventsnormalize(Y,DF,np)


c=size(Y,2);
intervals=size(DF,1);
if isempty(DF)|np<=1|isempty(Y)
    Ynorm=[];
    return
else
    Ynorm=zeros(np*intervals,c);
    for i=1:intervals
        l=DF(i,2)-DF(i,1)+1;
        if l>1.5*np
            Ynorm((i-1)*np+1:i*np,:)=resample(Y( DF(i,1):DF(i,2),: ),np,l,0);
        else
            Ynorm((i-1)*np+1:i*np,:)=upresample(Y( DF(i,1):DF(i,2),: ),np,l,2);
        end
    end
end   