function Y=upresample(X,P,Q,N)


Af=appendmirror(X);
Y=resample(Af,P,Q,10);
r=size(Y,1)/3;
Y=Y((r+1):(2*r),:);