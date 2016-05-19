function [r] = randomString(sLength)
s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

%find number of random characters to choose from
numRands = length(s); 

%generate random string
r = s( ceil(rand(1,sLength)*numRands) );
end
