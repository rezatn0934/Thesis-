function [ maxRH, maxRHAmp,ij,pknoise ] = peak2noise(f,p,frange)
%this is a perfunctory piece of code that calculates
% peak to noise value.  the noise calculation includes
% the peak.
% also does the RH (meters) for the peak value and 
% its amplitude
% (volts/volts)
% now do noise value
i=find(f > frange(1) & f < frange(2));
if isempty(i)
    tips=msgbox('Please select the appropriate height range!');
    pause(1)
    delete(tips)
    return
end
noisey = mean(p(i));
% divide into the max amplitude
newf=f(i);newp=p(i);
[maxRHAmp,ij] = max(newp); % max amplitude of LSP.
maxRH = newf(ij); % reflector height corresponding to max value
ij=ij+i(1)-1;
pknoise = maxRHAmp/noisey;

end

