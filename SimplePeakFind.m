function peaklist = SimplePeakFind ( environment, data,  thresh)
% ----------------------------------------------------------
%
% function peaklist = SimplePeakFind (  environment, data, thresh)
%
% finds the positions of peaks in a
% given data list. valid peaks
% are searched to be greater than 
% the threshold value.
% peaks are searched to be the maximum in a certain environment
% of values in the list.
%
% from:
% http://cresspahl.blogspot.com/2012/03/simple-algorithm-for-2d-peakfinding.html
%  ----------------------------------------------------------
% 
  listlength = length( data );  
  peaklist = zeros(listlength,1); % create blank output
  SearchEnvHalf = max(1,floor( environment/2));
  %
  % we only have to consider date above the threshold 
  %
  dataAboveThreshIndx = find (data >= thresh);
  for CandidateIndx = 1 : length(dataAboveThreshIndx)
    Indx = dataAboveThreshIndx(CandidateIndx);  
    %
    % consider list boundaries
    %
    minindx = Indx - SearchEnvHalf;
    maxindx = Indx + SearchEnvHalf;
    if (minindx < 1)
      minindx = 1;
    end
    if ( maxindx>listlength)
      maxindx = listlength;
    end
    %
    % data( CandidateIndx ) == maximum in environment?
    %
    if (data(Indx) == max( data( minindx : maxindx)))
      peaklist(Indx) = Indx;      
    end
  end 
  % finally shrink list to non-zero-values
  peaklist = peaklist( find( peaklist));
end