%% Function STFT
%           Y=STFT(X,FP,W,F)
%   It calculates short time fourier transform of given input signal
%   X:  Input signal
%   FP:  this is number of points used for calculating DFT, should be more
%       toget better resolution.
%   F:  this is offset between frames.
%   W:  its window size used(Blackman window).
%   Y:  Its returned vector equivalant to STFT of input vector

%% Built-in Functions used:
%   FFT 


%% Function :

function Y = STFT(X,FP,W,F)

len = length(X);


hw = (W)/2;
hp = FP/2;   % midpoint of win
eff_hlen = min(hp, hw);

%Hamming window 

 Hwin = 0.5 * ( 1 + cos( pi * (0:hw)/hw));
 win = zeros(1, FP);
 win((hp+1):(hp+eff_hlen)) = Hwin(1:eff_hlen);
 win((hp+1):-1:(hp-eff_hlen+2)) = Hwin(1:eff_hlen);

idx = 1;

% pre-allocate output array
Y = zeros((1+FP/2),1+fix((len-FP)/F));

for i = 0:F:(len-FP)
  u = win.*X((i+1):(i+FP));
  t = fft(u);
  Y(:,idx) = t(1:(1+FP/2))';
  idx = idx+1;
end;


