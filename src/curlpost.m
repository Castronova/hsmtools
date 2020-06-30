function [ response ] = curlpost( url, headers, filepath )
% curlpost: posts file to url using cURL
%     takes: url, array of formatted header strings, full path to file. 
%            assumes that server response will be json
%
% example:
%   url = 'https://www.hydroshare.org/hsapi/resource/<resid>/files/';
%   dataFile = fullfile('myfile.zip');
%   headers = [strcat("Authorization: Bearer ", access_token)];
%
%   resp = curlpost(url, headers, dataFile);
%   


% wrap header string in quotes
for i=1:length(headers)
   headers(i) = strcat("'",headers(i),"'");
end

% create header string
header_str = strjoin(["", headers], ' -H ');
 
% upload via curl
command = strcat("!curl -X POST ", header_str, " -F file='@", filepath, "' ", url);
res = evalc(command);

% decode the response
response = jsondecode(res);


