% compute absolute time difference between two files
% return time in seconds
function diffSec = ComputeTimeDiffBtwTwoDateVectorsMatt(dateVector1, dateVector2)
    diffSec = abs(etime(dateVector1,dateVector2));
end
