function sacV=spearmancor(xV,tauV)
% kacV=kendallcor(xV,tauV)
% spearmancor computes the Spearman autocorrelation on the time series 'xV' 
% for given delays in 'tauV'. 
%========================================================================
%     <spearmancor.m>, v 1.0 2010/02/11 22:09:14  Kugiumtzis & Tsimpiris
%     This is part of the MATS-Toolkit http://eeganalysis.web.auth.gr/

%========================================================================
% Copyright (C) 2010 by Dimitris Kugiumtzis and Alkiviadis Tsimpiris 
%                       <dkugiu@gen.auth.gr>

%========================================================================
% Version: 1.0

% LICENSE:
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 3 of the License, or
%     any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program. If not, see http://www.gnu.org/licenses/>.

%=========================================================================
% Reference : D. Kugiumtzis and A. Tsimpiris, "Measures of Analysis of Time Series (MATS): 
% 	          A Matlab  Toolkit for Computation of Multiple Measures on Time Series Data Bases",
%             Journal of Statistical Software, in press, 2010

% Link      : http://eeganalysis.web.auth.gr/
%========================================================================= 
n = length(xV);
ntau = length(tauV);
sacV = NaN*ones(ntau,1);
for itau=1:ntau
    tau = tauV(itau);
    x1V = xV(1:n-tau);
    x2V = xV(tau+1:n);
    n1=length(x1V);
    [oxV,ixV]=sort(x1V);
    [tmpS,jxV]=sort(ixV);
    [oyV,iyV]=sort(x2V);
    [tmpS,jyV]=sort(iyV);
    djxyV = jxV-jyV;
    sacV(itau) = 1-6*sum(djxyV.^2)/(n1*(n1^2-1));
end
