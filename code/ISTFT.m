%% Function ISTFT
%           X=ISTFT(Y,P,W,F)
%
%   X: Recovered signal form its STFT
%   Y: input STFT of signal
%   P: DFT points
%   W: Window Size
%   F: Offset between frames.
%

%% Built-in Functions Used:
%   IFFT


%% Function Definetion:

function X = ISTFT(Y,FP,W,F)

s = size(Y);
 
cols = s(2);
xlen = FP + cols * (F);
X = zeros(1,xlen);


% Hamming Window
win = zeros(1, FP);

hp = FP/2;   % midpoint of win
hw = (W)/2;
eff_hlen = min(hp, hw);

Hwin = 0.5 * ( 1 + cos( pi * (0:hw)/hw));

win((hp+1):(hp+eff_hlen)) = Hwin(1:eff_hlen);
win((hp+1):-1:(hp-eff_hlen+2)) = Hwin(1:eff_hlen);

for i = 0:F:(F*(cols-1))
  ft = Y(:,1+i/F)';
  ft = [ft, conj(ft([((FP/2)):-1:2]))];
  px = real(ifft(ft));
  X((i+1):(i+FP)) = X((i+1):(i+FP))+px.*win;
end;